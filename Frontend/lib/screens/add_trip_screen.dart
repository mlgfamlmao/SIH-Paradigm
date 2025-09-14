import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/trip.dart';
import '../services/location_service.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  
  DateTime? _startTime;
  DateTime? _endTime;
  String? _selectedMode;
  int _numCoTravellers = 0;
  String? _coTravellerRelationships;
  
  bool _isLoading = false;
  bool _isGettingLocation = false;

  final List<String> _travelModes = [
    'Walking',
    'Car',
    'Bus',
    'Train',
    'Bicycle',
    'Motorcycle',
    'Taxi/Rideshare',
    'Other',
  ];

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Trip'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTrip,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick actions
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isGettingLocation ? null : _getCurrentLocation,
                              icon: _isGettingLocation
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.my_location),
                              label: const Text('Use Current Location'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _setCurrentTime,
                              icon: const Icon(Icons.access_time),
                              label: const Text('Now'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Origin
              const Text(
                'Origin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter origin address',
                  prefixIcon: Icon(Icons.radio_button_checked, color: Colors.green),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter origin address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Destination
              const Text(
                'Destination',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter destination address',
                  prefixIcon: Icon(Icons.place, color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter destination address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Time section
              const Text(
                'Trip Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      label: 'Start Time',
                      time: _startTime,
                      onTap: () => _selectStartTime(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeField(
                      label: 'End Time',
                      time: _endTime,
                      onTap: () => _selectEndTime(),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Mode of travel
              const Text(
                'Mode of Travel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedMode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select mode of travel',
                ),
                items: _travelModes.map((String mode) {
                  return DropdownMenuItem<String>(
                    value: mode,
                    child: Row(
                      children: [
                        Icon(_getModeIcon(mode), size: 20),
                        const SizedBox(width: 8),
                        Text(mode),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMode = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select mode of travel';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Co-travellers
              const Text(
                'Co-travellers',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_numCoTravellers > 0) {
                          _numCoTravellers--;
                        }
                      });
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$_numCoTravellers',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _numCoTravellers++;
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Number of co-travellers',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              
              if (_numCoTravellers > 0) ...[
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Describe relationships (e.g., "2 friends, 1 colleague")',
                    prefixIcon: Icon(Icons.people),
                  ),
                  onChanged: (value) {
                    _coTravellerRelationships = value;
                  },
                ),
              ],
              
              const SizedBox(height: 30),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTrip,
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
                          'Save Trip',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required DateTime? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
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
            const SizedBox(height: 4),
            Text(
              time != null 
                  ? DateFormat('MMM dd, HH:mm').format(time)
                  : 'Select time',
              style: TextStyle(
                fontSize: 14,
                color: time != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: _startTime != null 
            ? TimeOfDay.fromDateTime(_startTime!)
            : TimeOfDay.now(),
      );
      
      if (time != null) {
        setState(() {
          _startTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endTime ?? (_startTime ?? DateTime.now()),
      firstDate: _startTime ?? DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: _endTime != null 
            ? TimeOfDay.fromDateTime(_endTime!)
            : TimeOfDay.now(),
      );
      
      if (time != null) {
        setState(() {
          _endTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _setCurrentTime() {
    final now = DateTime.now();
    setState(() {
      _startTime = now.subtract(const Duration(minutes: 30));
      _endTime = now;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      
      if (position != null) {
        final address = await locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (address != null) {
          setState(() {
            _originController.text = address;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      TripCreate tripCreate = TripCreate(
        userId: appProvider.currentUser!.id,
        tripNumber: 0, // Will be set by the service
        originAddress: _originController.text,
        destinationAddress: _destinationController.text,
        startTime: _startTime,
        endTime: _endTime,
        modeOfTravel: _selectedMode,
        numCoTravellers: _numCoTravellers,
        coTravellerRelationships: _coTravellerRelationships,
        isConfirmed: true,
      );

      await appProvider.createTrip(tripCreate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _originController.clear();
        _destinationController.clear();
        setState(() {
          _startTime = null;
          _endTime = null;
          _selectedMode = null;
          _numCoTravellers = 0;
          _coTravellerRelationships = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save trip: $e'),
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

  IconData _getModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'walking':
        return Icons.directions_walk;
      case 'car':
        return Icons.directions_car;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'bicycle':
        return Icons.directions_bike;
      case 'motorcycle':
        return Icons.motorcycle;
      case 'taxi/rideshare':
        return Icons.local_taxi;
      default:
        return Icons.directions;
    }
  }
}
