import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user.dart';
import 'onboarding_screen.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _consentGiven = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NATPAC Travel Data Collection'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Welcome to NATPAC Travel Data Collection',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'About This Study',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'The National Transportation Planning and Research Centre (NATPAC) is conducting a travel behavior study to better understand transportation patterns and improve urban mobility.',
            ),
            const SizedBox(height: 20),
            const Text(
              'What We Collect',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Your travel trips (origin, destination, time, mode of transport)\n'
              '• Basic demographic information (age group, gender, household size)\n'
              '• Number and relationship of co-travellers\n'
              '• GPS location data for trip detection',
            ),
            const SizedBox(height: 20),
            const Text(
              'Privacy & Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Your data is anonymized and stored securely\n'
              '• No personal identifiers are collected\n'
              '• Data is used only for research purposes\n'
              '• You can withdraw consent at any time\n'
              '• All data transmission is encrypted',
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Rights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• You can skip any questions you prefer not to answer\n'
              '• You can delete your data at any time\n'
              '• You can opt out of location tracking\n'
              '• You can contact us with any questions',
            ),
            const Spacer(),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _consentGiven,
                          onChanged: (value) {
                            setState(() {
                              _consentGiven = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'I have read and understood the information above and consent to participate in this study.',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'By checking this box, you agree to:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Text(
                      '• Allow the app to collect your travel data\n'
                      '• Use GPS location for trip detection\n'
                      '• Store data locally and sync with research servers\n'
                      '• Receive notifications for trip confirmations',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _consentGiven && !_isLoading
                    ? () => _proceedToOnboarding(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'I Consent - Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _proceedToOnboarding(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      // Create user with consent
      UserCreate userCreate = UserCreate(
        deviceId: await _getDeviceId(),
        consentGiven: true,
      );

      await appProvider.registerUser(userCreate);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getDeviceId() async {
    // This should match the device ID generation in AppProvider
    // For now, we'll use a simple approach
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }
}
