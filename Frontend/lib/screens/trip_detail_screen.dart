import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/trip.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Trip _trip;
  bool _isEditing = false;
  bool _isLoading = false;

  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  String? _selectedMode;
  int _numCoTravellers = 0;
  String? _coTravellerRelationships;

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
  void initState() {
    super.initState();
    _trip = widget.trip;
    _initializeForm();
  }

  void _initializeForm() {
    _originController.text = _trip.originAddress ?? '';
    _destinationController.text = _trip.destinationAddress ?? '';
    _selectedMode = _trip.modeOfTravel;
    _numCoTravellers = _trip.numCoTravellers;
    _coTravellerRelationships = _trip.coTravellerRelationships;
  }

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
        title: Text('Trip #${_trip.tripNumber}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
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
      body: _isEditing ? _buildEditForm() : _buildDetailView(),
    );
  }

  Widget _buildDetailView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            color: _trip.isConfirmed ? Colors.green[50] : Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _trip.isConfirmed ? Icons.check_circle : Icons.pending,
                    color: _trip.isConfirmed ? Colors.green[600] : Colors.orange[600],
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _trip.isConfirmed ? 'Trip Confirmed' : 'Trip Pending',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _trip.isConfirmed ? Colors.green[800] : Colors.orange[800],
                          ),
                        ),
                        Text(
                          _trip.isSynced ? 'Synced with server' : 'Not synced',
                          style: TextStyle(
                            fontSize: 12,
                            color: _trip.isSynced ? Colors.green[600] : Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Route information
          const Text(
            'Route',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Origin
                  Row(
                    children: [
                      Icon(
                        Icons.radio_button_checked,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Origin',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _trip.originAddress ?? 'Not specified',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            if (_trip.originLat != null && _trip.originLng != null)
                              Text(
                                '${_trip.originLat!.toStringAsFixed(6)}, ${_trip.originLng!.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Arrow
                  Icon(
                    Icons.arrow_downward,
                    color: Colors.grey[400],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Destination
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        color: Colors.red[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Destination',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _trip.destinationAddress ?? 'Not specified',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            if (_trip.destinationLat != null && _trip.destinationLng != null)
                              Text(
                                '${_trip.destinationLat!.toStringAsFixed(6)}, ${_trip.destinationLng!.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Trip details
          const Text(
            'Trip Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Start Time',
                    _trip.startTime != null 
                        ? DateFormat('MMM dd, yyyy - HH:mm').format(_trip.startTime!)
                        : 'Not specified',
                    Icons.access_time,
                  ),
                  _buildDetailRow(
                    'End Time',
                    _trip.endTime != null 
                        ? DateFormat('MMM dd, yyyy - HH:mm').format(_trip.endTime!)
                        : 'Not specified',
                    Icons.access_time,
                  ),
                  _buildDetailRow(
                    'Mode of Travel',
                    _trip.modeOfTravel ?? 'Not specified',
                    _getModeIcon(_trip.modeOfTravel ?? ''),
                  ),
                  _buildDetailRow(
                    'Co-travellers',
                    _trip.numCoTravellers > 0 
                        ? '${_trip.numCoTravellers} people'
                        : 'None',
                    Icons.people,
                  ),
                  if (_trip.coTravellerRelationships != null)
                    _buildDetailRow(
                      'Relationships',
                      _trip.coTravellerRelationships!,
                      Icons.people_outline,
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Trip metadata
          const Text(
            'Trip Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Trip Number',
                    '#${_trip.tripNumber}',
                    Icons.confirmation_number,
                  ),
                  _buildDetailRow(
                    'Created',
                    DateFormat('MMM dd, yyyy - HH:mm').format(_trip.createdAt),
                    Icons.calendar_today,
                  ),
                  _buildDetailRow(
                    'Last Updated',
                    DateFormat('MMM dd, yyyy - HH:mm').format(_trip.updatedAt),
                    Icons.update,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons
          if (!_trip.isConfirmed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _confirmTrip,
                icon: const Icon(Icons.check),
                label: const Text('Confirm Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              prefixIcon: Icon(Icons.radio_button_checked, color: Colors.green),
            ),
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
              prefixIcon: Icon(Icons.place, color: Colors.red),
            ),
          ),
          
          const SizedBox(height: 16),
          
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
          ),
          
          const SizedBox(height: 16),
          
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
            ],
          ),
          
          if (_numCoTravellers > 0) ...[
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _coTravellerRelationships,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe relationships',
                prefixIcon: Icon(Icons.people),
              ),
              onChanged: (value) {
                _coTravellerRelationships = value;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
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

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _initializeForm();
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      TripUpdate tripUpdate = TripUpdate(
        originAddress: _originController.text,
        destinationAddress: _destinationController.text,
        modeOfTravel: _selectedMode,
        numCoTravellers: _numCoTravellers,
        coTravellerRelationships: _coTravellerRelationships,
      );

      await appProvider.updateTrip(_trip.id, tripUpdate);
      
      // Update local trip data
      _trip = _trip.copyWith(
        originAddress: _originController.text,
        destinationAddress: _destinationController.text,
        modeOfTravel: _selectedMode,
        numCoTravellers: _numCoTravellers,
        coTravellerRelationships: _coTravellerRelationships,
        updatedAt: DateTime.now(),
      );

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update trip: $e'),
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

  Future<void> _confirmTrip() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      TripUpdate tripUpdate = TripUpdate(
        isConfirmed: true,
      );

      await appProvider.updateTrip(_trip.id, tripUpdate);
      
      // Update local trip data
      _trip = _trip.copyWith(
        isConfirmed: true,
        updatedAt: DateTime.now(),
      );

      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip confirmed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm trip: $e'),
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
