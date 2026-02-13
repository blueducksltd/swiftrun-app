import 'package:flutter/material.dart';
import 'package:swiftrun/core/model/paystack/payment_auth.dart';
import 'package:swiftrun/services/paystack_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayStackPaymentScreen extends StatefulWidget {
  final String reference;
  final String currency;
  final String email;
  final double amount;
  final String? callbackUrl;
  final Object? metadata;
  final Object? channel;
  final Function(Object?) onCompletedTransaction;
  final Function(Object?) onFailedTransaction;

  const PayStackPaymentScreen({
    super.key,
    required this.reference,
    required this.currency,
    required this.email,
    required this.amount,
    this.callbackUrl = 'https://callback.com',
    this.metadata,
    this.channel,
    required this.onCompletedTransaction,
    required this.onFailedTransaction,
  });

  @override
  State<PayStackPaymentScreen> createState() => _PayStackPaymentScreenState();
}

class _PayStackPaymentScreenState extends State<PayStackPaymentScreen> {
  late Future<PaymentAuthorization> _paymentFuture;
  WebViewController? _controller;
  bool _isVerifying = false;
  bool _isLoading = true;
  double _loadProgress = 0;
  bool _userInitiatedClose = false;

  @override
  void initState() {
    super.initState();
    _paymentFuture = PaystackService().initTransaction(
      email: widget.email,
      amount: widget.amount * 100,
      reference: widget.reference,
      currency: widget.currency,
      callbackUrl: widget.callbackUrl,
      metadata: widget.metadata,
    );
  }

  void _verify() {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);
    PaystackService()
        .verifyTransaction(
          widget.reference,
          widget.onCompletedTransaction,
          (error) {
            // Only show error if not user-initiated close
            if (!_userInitiatedClose) {
              widget.onFailedTransaction(error);
            }
          },
          onCancelledTransaction: () {
            // User cancelled - don't show any error
            debugPrint('Payment cancelled by user');
          },
        )
        .then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaymentAuthorization>(
      future: _paymentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.authorizationUrl != null) {
          if (_controller == null) {
            _controller = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setNavigationDelegate(
                NavigationDelegate(
                  onProgress: (int progress) {
                    setState(() {
                      _loadProgress = progress / 100;
                    });
                  },
                  onPageStarted: (String url) {
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onPageFinished: (String url) {
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  onWebResourceError: (WebResourceError error) {
                    debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
                  },
                  onNavigationRequest: (request) {
                    debugPrint('Navigating to: ${request.url}');
                    if (widget.callbackUrl != null &&
                        request.url.startsWith(widget.callbackUrl!)) {
                      _verify();
                      return NavigationDecision.prevent;
                    }

                    // Handle potential app redirects (intents)
                    if (!request.url.startsWith('http')) {
                      return NavigationDecision.prevent;
                    }
                    
                    return NavigationDecision.navigate;
                  },
                ),
              );
            
            // Enable DOM storage for OPay and other modern gateways
            // Set User agent to avoid generic bot detection
            _controller!
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..enableZoom(true)
              ..setUserAgent("Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.119 Mobile Safari/537.36")
              ..loadRequest(Uri.parse(snapshot.data!.authorizationUrl!));
          }
        }

        return PopScope(
          canPop: !_isVerifying,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _userInitiatedClose = true;
            _verify();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text("Paystack Payment"),
              leading: IconButton(
                onPressed: () {
                  _userInitiatedClose = true;
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    _verify();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.close),
              ),
            ),
            body: (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.authorizationUrl != null)
                ? Stack(
                    children: [
                      WebViewWidget(
                        key: const ValueKey('paystack_webview'),
                        controller: _controller!,
                      ),
                      if (_isLoading || _isVerifying)
                        Container(
                          color: Colors.white.withValues(alpha: 0.8),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(value: _isLoading && _loadProgress > 0 ? _loadProgress : null),
                                const SizedBox(height: 16),
                                Text(_isVerifying ? "Verifying Transaction..." : "Loading Payment Page..."),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                : snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text("Initializtion Error: ${snapshot.error.toString()}"),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => setState(() {
                                _paymentFuture = PaystackService().initTransaction(
                                  email: widget.email,
                                  amount: widget.amount * 100,
                                  reference: widget.reference,
                                  currency: widget.currency,
                                  callbackUrl: widget.callbackUrl,
                                  metadata: widget.metadata,
                                );
                              }),
                              child: const Text("Retry"),
                            )
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }
}
