import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:swiftrun/common/styles/colors.dart';

class AppUpdateChecker {
  /// Check for app updates and show a friendly dialog
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // Check if update is available
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Get current app version
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;

        // Show friendly dialog with version info
        if (context.mounted) {
          _showUpdateDialog(context, currentVersion);
        }
      }
    } catch (e) {
      // Silently fail - don't bother user if update check fails
      debugPrint('Error checking for update: $e');
    }
  }

  /// Show update dialog with version information
  static void _showUpdateDialog(BuildContext context, String currentVersion) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: AppColor.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Update Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current version: $currentVersion',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A new version with improvements and new features is available for Pulse!',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColor.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'You can continue using the app',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColor.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Update downloads in background',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColor.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Install when you\'re ready',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _startFlexibleUpdate(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Download Update'),
          ),
        ],
      ),
    );
  }

  /// Start flexible update (background download)
  static Future<void> _startFlexibleUpdate(BuildContext context) async {
    try {
      // Start flexible update
      await InAppUpdate.startFlexibleUpdate();

      // Show snackbar to inform user download started
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Update downloading in background... You can continue using the app.'),
            duration: const Duration(seconds: 4),
            backgroundColor: AppColor.primaryColor,
          ),
        );
      }

      // Complete the update when download finishes
      await InAppUpdate.completeFlexibleUpdate();

      // Show install prompt when ready
      if (context.mounted) {
        _showInstallPrompt(context);
      }
    } catch (e) {
      debugPrint('Error during flexible update: $e');

      // Show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to download update. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show prompt to install the downloaded update
  static void _showInstallPrompt(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.download_done,
              color: Colors.green,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Update Ready',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Update downloaded successfully!\n\n'
          'Would you like to restart the app now to install the update?',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Later',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Complete the flexible update (restarts app)
              await InAppUpdate.completeFlexibleUpdate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Restart Now'),
          ),
        ],
      ),
    );
  }
}
