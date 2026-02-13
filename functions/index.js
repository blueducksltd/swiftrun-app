const functions = require('firebase-functions');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const crypto = require('crypto');

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Paystack Webhook Handler
 * 
 * This function receives payment notifications from Paystack and
 * updates the delivery request in Firestore with payment status.
 * 
 * Webhook URL: https://us-central1-vlogx-f4c1f.cloudfunctions.net/paystackWebhook
 */
const { onRequest } = require("firebase-functions/v2/https");

exports.paystackWebhook = onRequest({ secrets: ["PAYSTACK_SECRET_KEY"] }, async (req, res) => {
  try {
    // Only accept POST requests
    if (req.method !== 'POST') {
      return res.status(405).send('Method Not Allowed');
    }

    // Get Paystack secret key from environment variable
    const secretKey = process.env.PAYSTACK_SECRET_KEY;

    if (!secretKey) {
      console.error('Paystack secret key not configured');
      return res.status(500).send('Configuration error');
    }

    // Verify webhook signature
    const hash = crypto
      .createHmac('sha512', secretKey)
      .update(JSON.stringify(req.body))
      .digest('hex');

    const paystackSignature = req.headers['x-paystack-signature'];

    if (hash !== paystackSignature) {
      console.error('Invalid webhook signature');
      return res.status(401).send('Invalid signature');
    }

    // Extract event data
    const event = req.body;
    console.log('Webhook event received:', event.event);

    // Handle different event types
    switch (event.event) {
      case 'charge.success':
        await handleSuccessfulCharge(event.data);
        break;

      case 'charge.failed':
        await handleFailedCharge(event.data);
        break;

      case 'refund.processed':
        await handleRefund(event.data);
        break;

      default:
        console.log('Unhandled event type:', event.event);
    }

    // Send success response to Paystack
    return res.status(200).send('Webhook received');

  } catch (error) {
    console.error('Webhook error:', error);
    return res.status(500).send('Internal server error');
  }
});

/**
 * Handle successful payment
 */
async function handleSuccessfulCharge(data) {
  try {
    const reference = data.reference;
    const amount = data.amount / 100; // Convert from kobo to naira
    const metadata = data.metadata || {};

    console.log('Processing successful payment:', reference);

    // Extract delivery/request ID from metadata
    const deliveryId = metadata.deliveryId || metadata.requestId;

    if (!deliveryId) {
      console.error('No deliveryId found in metadata:', metadata);
      return;
    }

    // Determine collection based on delivery type
    const isScheduled = metadata.isScheduled === 'true' || metadata.isScheduled === true;
    const collection = isScheduled ? 'ScheduleRequest' : 'DeliveryRequests';

    console.log(`Updating ${collection}/${deliveryId}`);

    // Update delivery request in Firestore with essential fields only
    await admin.firestore()
      .collection(collection)
      .doc(deliveryId)
      .update({
        paymentStatus: true,
        paymentVerified: true,
        paymentReference: reference,
        amountPaid: amount,
        paymentDate: admin.firestore.FieldValue.serverTimestamp(),
        paymentMethod: 'card',
      });

    console.log(`Payment verified for ${collection}/${deliveryId}`);

    // Get delivery details for notifications
    const deliveryDoc = await admin.firestore()
      .collection(collection)
      .doc(deliveryId)
      .get();

    const deliveryData = deliveryDoc.data();

    if (deliveryData) {
      const orderId = deliveryData.orderID || deliveryId.substring(0, 6);
      const currency = data.currency === 'NGN' ? '₦' : data.currency;

      // Send notification to customer
      if (deliveryData.userToken) {
        await sendNotification(
          deliveryData.userToken,
          'Payment Successful ✅',
          `${currency}${amount} paid for delivery #${orderId}`,
          {
            type: 'payment_success',
            deliveryId: deliveryId,
            amount: amount.toString(),
            reference: reference,
          }
        );
        console.log('Customer notification sent');
      }

      // Send notification to driver (if assigned)
      const driverId = deliveryData.driverID || deliveryData.assignedDriver;
      if (driverId && driverId !== '') {
        try {
          // Fetch driver's FCM token from drivers collection
          const driverDoc = await admin.firestore()
            .collection('Drivers')
            .doc(driverId)
            .get();

          const driverData = driverDoc.data();
          const driverToken = driverData?.userToken;

          if (driverToken) {
            await sendNotification(
              driverToken,
              'Payment Confirmed ✅',
              `${currency}${amount} received for order #${orderId}`,
              {
                type: 'payment_confirmed',
                deliveryId: deliveryId,
                amount: amount.toString(),
                reference: reference,
              }
            );
            console.log('Driver notification sent');
          } else {
            console.log('Driver token not found');
          }
        } catch (error) {
          console.error('Error getting driver token:', error);
        }
      }
    }

  } catch (error) {
    console.error('Error handling successful charge:', error);
    throw error;
  }
}

/**
 * Handle failed payment
 */
async function handleFailedCharge(data) {
  try {
    const reference = data.reference;
    const metadata = data.metadata || {};
    const deliveryId = metadata.deliveryId || metadata.requestId;

    if (!deliveryId) {
      console.error('No deliveryId found in failed charge metadata');
      return;
    }

    const isScheduled = metadata.isScheduled === 'true' || metadata.isScheduled === true;
    const collection = isScheduled ? 'ScheduleRequest' : 'DeliveryRequests';

    console.log(`Payment failed for ${collection}/${deliveryId}`);

    // Update with failed status
    const updateData = {
      paymentStatus: false,
      paymentVerified: false,
      paymentReference: reference,
      lastPaymentAttempt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Only add failure reason if it exists
    if (data.gateway_response) {
      updateData.paymentFailureReason = data.gateway_response;
    }

    await admin.firestore()
      .collection(collection)
      .doc(deliveryId)
      .update(updateData);

    // Get delivery details for notifications
    const deliveryDoc = await admin.firestore()
      .collection(collection)
      .doc(deliveryId)
      .get();

    const deliveryData = deliveryDoc.data();

    if (deliveryData) {
      const orderId = deliveryData.orderID || deliveryId.substring(0, 6);
      const failureReason = data.gateway_response || 'Payment declined';

      // Send notification to customer
      if (deliveryData.userToken) {
        await sendNotification(
          deliveryData.userToken,
          'Payment Failed ❌',
          `Please retry payment for delivery #${orderId}. ${failureReason}`,
          {
            type: 'payment_failed',
            deliveryId: deliveryId,
            reference: reference,
            reason: failureReason,
          }
        );
        console.log('Customer failure notification sent');
      }

      // Send notification to driver (if assigned)
      const driverId = deliveryData.driverID || deliveryData.assignedDriver;
      if (driverId && driverId !== '') {
        try {
          // Fetch driver's FCM token from drivers collection
          const driverDoc = await admin.firestore()
            .collection('Drivers')
            .doc(driverId)
            .get();

          const driverData = driverDoc.data();
          const driverToken = driverData?.userToken;

          if (driverToken) {
            await sendNotification(
              driverToken,
              'Payment Issue ⚠️',
              `Waiting for customer payment on order #${orderId}`,
              {
                type: 'payment_pending',
                deliveryId: deliveryId,
                reference: reference,
              }
            );
            console.log('Driver pending notification sent');
          } else {
            console.log('Driver token not found');
          }
        } catch (error) {
          console.error('Error getting driver token:', error);
        }
      }
    }

  } catch (error) {
    console.error('Error handling failed charge:', error);
  }
}

/**
 * Handle refund
 */
async function handleRefund(data) {
  try {
    const reference = data.transaction_reference;
    const amount = data.amount / 100;

    console.log('Processing refund for reference:', reference);

    // Find delivery by payment reference
    const deliveriesSnapshot = await admin.firestore()
      .collection('DeliveryRequests')
      .where('paymentReference', '==', reference)
      .limit(1)
      .get();

    if (!deliveriesSnapshot.empty) {
      const deliveryDoc = deliveriesSnapshot.docs[0];
      await deliveryDoc.ref.update({
        paymentStatus: 'refunded',
        refundAmount: amount,
        refundedAt: admin.firestore.FieldValue.serverTimestamp(),
        refundReason: data.refund_reason || 'Customer initiated',
      });
    }

    // Also check scheduled requests
    const scheduledSnapshot = await admin.firestore()
      .collection('ScheduleRequest')
      .where('paymentReference', '==', reference)
      .limit(1)
      .get();

    if (!scheduledSnapshot.empty) {
      const scheduledDoc = scheduledSnapshot.docs[0];
      await scheduledDoc.ref.update({
        paymentStatus: 'refunded',
        refundAmount: amount,
        refundedAt: admin.firestore.FieldValue.serverTimestamp(),
        refundReason: data.refund_reason || 'Customer initiated',
      });
    }

  } catch (error) {
    console.error('Error handling refund:', error);
  }
}

/**
 * Firestore trigger: Send push notification when a message is sent (bidirectional)
 * Listens to new messages in ChatMessages/{chatId}/messages collection
 * Handles both: Driver → Customer and Customer → Driver
 */
exports.onChatMessageCreated = onDocumentCreated('ChatMessages/{chatId}/messages/{messageId}', async (event) => {
  try {
    const snap = event.data;
    if (!snap) {
      console.log('No message data found in event');
      return null;
    }
    const messageData = snap.data();
    const senderID = messageData.senderID;
    const receiverID = messageData.receiverID;
    const content = messageData.content || '';
    const chatId = event.params.chatId;

    console.log(`New message in chat ${chatId} from ${senderID} to ${receiverID}`);

    // Determine if sender is driver or customer
    // Drivers have IDs in the Drivers collection, customers in Customers collection
    const driverDoc = await admin.firestore()
      .collection('Drivers')
      .doc(senderID)
      .get();

    const isDriverMessage = driverDoc.exists;

    // Check if sender is customer
    const customerDoc = await admin.firestore()
      .collection('Customers')
      .doc(senderID)
      .get();

    const isCustomerMessage = customerDoc.exists;

    let senderName = '';
    let receiverToken = null;
    let receiverDoc = null;

    if (isDriverMessage) {
      // Driver sending to Customer
      const driverData = driverDoc.data();
      senderName = driverData
        ? `${driverData.firstName || ''} ${driverData.lastName || ''}`.trim() || 'Driver'
        : 'Driver';

      // Get customer's FCM token
      receiverDoc = await admin.firestore()
        .collection('Customers')
        .doc(receiverID)
        .get();

      if (receiverDoc.exists) {
        const customerData = receiverDoc.data();
        receiverToken = customerData?.userToken;
      }
    } else if (isCustomerMessage) {
      // Customer sending to Driver
      const customerData = customerDoc.data();
      senderName = customerData
        ? `${customerData.firstName || ''} ${customerData.lastName || ''}`.trim() || 'Customer'
        : 'Customer';

      // Get driver's FCM token
      receiverDoc = await admin.firestore()
        .collection('Drivers')
        .doc(receiverID)
        .get();

      if (receiverDoc.exists) {
        const driverData = receiverDoc.data();
        receiverToken = driverData?.userToken;
      }
    } else {
      console.log('Sender is neither driver nor customer, skipping notification');
      return null;
    }

    if (!receiverDoc || !receiverDoc.exists) {
      console.log('Receiver document not found:', receiverID);
      return null;
    }

    if (!receiverToken) {
      console.log('Receiver FCM token not found:', receiverID);
      return null;
    }

    // Prepare notification data
    const notificationData = {
      type: 'chat_message',
      chatId: chatId,
      senderId: senderID,
      senderName: senderName,
      message: content,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    };

    // Add driverId for customer app navigation (if sender is driver)
    if (isDriverMessage) {
      notificationData.driverId = senderID;
    }

    // Convert data values to strings (FCM requires string values)
    const stringifiedData = {};
    for (const [key, value] of Object.entries(notificationData)) {
      stringifiedData[key] = String(value);
    }

    // Send notification
    await sendNotification(
      receiverToken,
      senderName,
      content.length > 50 ? content.substring(0, 50) + '...' : content,
      stringifiedData
    );

    const direction = isDriverMessage ? 'customer' : 'driver';
    console.log(`Chat notification sent to ${direction} ${receiverID} from ${senderName} (${senderID})`);
    return null;

  } catch (error) {
    console.error('Error in onChatMessageCreated:', error);
    return null;
  }
});

/**
 * Send FCM notification
 * @param {string} token - FCM device token
 * @param {string} title - Notification title
 * @param {string} body - Notification body
 * @param {object} data - Additional data payload
 */
async function sendNotification(token, title, body, data = {}) {
  try {
    if (!token) {
      console.log('No FCM token provided, skipping notification');
      return;
    }

    // Convert all data values to strings (FCM requirement)
    const stringifiedData = {};
    for (const [key, value] of Object.entries(data)) {
      stringifiedData[key] = String(value);
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: stringifiedData,
      token: token,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: data.type === 'chat_message' ? 'chat_messages' : 'payment_notifications',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log('Notification sent successfully:', response);
    return response;
  } catch (error) {
    console.error('Error sending notification:', error);
    // Don't throw - notifications are not critical
  }
}

