import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;

  final _ageGroupController = TextEditingController();
  final _genderController = TextEditingController();
  final _householdSizeController = TextEditingController();

  final List<String> _ageGroups = [
    '18-25',
    '26-35',
    '36-45',
    '46-55',
    '56-65',
    '65+',
  ];

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void dispose() {
    _ageGroupController.dispose();
    _genderController.dispose();
    _householdSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  _initializeForm();
                });
              },
              icon: const Icon(Icons.edit),
            ),
          if (_isEditing) ...[
            TextButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: _cancelEdit,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = appProvider.currentUser;
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[600],
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NATPAC Participant',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Device ID: ${user.deviceId}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    user.consentGiven ? Icons.check_circle : Icons.cancel,
                                    color: user.consentGiven ? Colors.green : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.consentGiven ? 'Consent Given' : 'No Consent',
                                    style: TextStyle(
                                      color: user.consentGiven ? Colors.green[700] : Colors.red[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Profile information
                const Text(
                  'Profile Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _isEditing ? _buildEditForm() : _buildProfileInfo(user),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // App statistics
                const Text(
                  'Your Statistics',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Trips',
                        '${appProvider.trips.length}',
                        Icons.directions_car,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Confirmed',
                        '${appProvider.trips.where((t) => t.isConfirmed).length}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        '${appProvider.trips.where((t) => !t.isConfirmed).length}',
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Synced',
                        '${appProvider.trips.where((t) => t.isSynced).length}',
                        Icons.cloud_done,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // App settings
                const Text(
                  'App Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          appProvider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                          color: appProvider.isOnline ? Colors.green : Colors.orange,
                        ),
                        title: const Text('Connection Status'),
                        subtitle: Text(
                          appProvider.isOnline 
                              ? 'Connected to server' 
                              : 'Offline mode',
                        ),
                        trailing: appProvider.isOnline 
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.warning, color: Colors.orange),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('About NATPAC'),
                        subtitle: const Text('Learn more about this study'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showAboutDialog();
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Privacy Policy'),
                        subtitle: const Text('How we protect your data'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showPrivacyDialog();
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Data management
                const Text(
                  'Data Management',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.sync, color: Colors.blue),
                        title: const Text('Sync Data'),
                        subtitle: const Text('Upload pending trips to server'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _syncData();
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.download, color: Colors.green),
                        title: const Text('Export Data'),
                        subtitle: const Text('Download your trip data'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _exportData();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfo(User user) {
    return Column(
      children: [
        _buildInfoRow('Age Group', user.ageGroup ?? 'Not specified', Icons.cake),
        _buildInfoRow('Gender', user.gender ?? 'Not specified', Icons.person),
        _buildInfoRow('Household Size', 
            user.householdSize != null ? '${user.householdSize} people' : 'Not specified', 
            Icons.home),
        _buildInfoRow('Member Since', 
            '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}', 
            Icons.calendar_today),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        // Age Group
        DropdownButtonFormField<String>(
          value: _ageGroupController.text.isEmpty ? null : _ageGroupController.text,
          decoration: const InputDecoration(
            labelText: 'Age Group',
            border: OutlineInputBorder(),
          ),
          items: _ageGroups.map((String ageGroup) {
            return DropdownMenuItem<String>(
              value: ageGroup,
              child: Text(ageGroup),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _ageGroupController.text = newValue ?? '';
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Gender
        DropdownButtonFormField<String>(
          value: _genderController.text.isEmpty ? null : _genderController.text,
          decoration: const InputDecoration(
            labelText: 'Gender',
            border: OutlineInputBorder(),
          ),
          items: _genders.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _genderController.text = newValue ?? '';
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Household Size
        TextFormField(
          controller: _householdSizeController,
          decoration: const InputDecoration(
            labelText: 'Household Size',
            border: OutlineInputBorder(),
            hintText: 'Number of people in household',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _initializeForm() {
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    if (user != null) {
      _ageGroupController.text = user.ageGroup ?? '';
      _genderController.text = user.gender ?? '';
      _householdSizeController.text = user.householdSize?.toString() ?? '';
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      UserUpdate userUpdate = UserUpdate(
        ageGroup: _ageGroupController.text.isEmpty ? null : _ageGroupController.text,
        gender: _genderController.text.isEmpty ? null : _genderController.text,
        householdSize: _householdSizeController.text.isEmpty 
            ? null 
            : int.tryParse(_householdSizeController.text),
      );

      await appProvider.updateUserProfile(userUpdate);

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About NATPAC'),
        content: const Text(
          'The National Transportation Planning and Research Centre (NATPAC) is conducting this travel behavior study to better understand transportation patterns and improve urban mobility.\n\n'
          'Your participation helps researchers develop better transportation solutions for cities.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          '• Your data is anonymized and stored securely\n'
          '• No personal identifiers are collected\n'
          '• Data is used only for research purposes\n'
          '• You can withdraw consent at any time\n'
          '• All data transmission is encrypted\n'
          '• You can delete your data at any time',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _syncData() {
    // Implement sync functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sync functionality will be implemented'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportData() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality will be implemented'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
