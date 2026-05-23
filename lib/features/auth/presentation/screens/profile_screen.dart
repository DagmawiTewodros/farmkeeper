import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userName = authState.value?.name ?? 'User';

    return Container(
      color: const Color(0xFFF4F7F1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),

              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFF2E7D32),

                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Farm Manager',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      badge('PREMIUM MEMBER', const Color(0xFF2E7D32)),

                      const SizedBox(width: 10),

                      badge('VERIFIED FARM', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            infoCard('TOTAL ACREAGE', '80,400 KM²', Icons.landscape),

            infoCard(
              'MAIN CROPS',
              'Winter Wheat, Soybeans, Alfalfa',
              Icons.grass,
            ),

            const SizedBox(height: 20),

            settingsTile('Manage Land Assets', Icons.map, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Land assets management saved.')),
              );
            }),

            settingsTile('Change PIN', Icons.lock, () {
              _showChangePinDialog(context);
            }),

            settingsTile('Setup Face ID', Icons.face, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Face ID is not available on this device.'),
                ),
              );
            }),

            settingsTile('Two-Factor Authentication', Icons.security, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Two-factor authentication saved.'),
                ),
              );
            }),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Text(
                'Ensure your security protocols are up to date to protect sensitive crop yield data and financial records.',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog.signOut(
                      route: '/create_account_screen',
                    ),
                  );
                },

                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget infoCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: Icon(icon, color: const Color(0xFF2E7D32), size: 30),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),

          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget settingsTile(String title, IconData icon, VoidCallback? onPressed) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),

        title: Text(title, style: const TextStyle(color: Colors.black)),

        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onPressed,
      ),
    );
  }

  void _showChangePinDialog(BuildContext context) {
    final pinController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change PIN'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'New PIN',
              hintText: 'Enter 6-digit PIN',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinController.text.length == 6) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN changed successfully.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN must be 6 digits.')),
                  );
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
