import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  User? _currentUser;
  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;
  bool _isOnline = false;

  User? get currentUser => _currentUser;
  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Initialize services
      await _notificationService.initialize();
      await _requestPermissions();

      // Get device ID
      String deviceId = await _getDeviceId();

      // Try to get user from local database
      _currentUser = await _databaseService.getUserByDeviceId(deviceId);

      if (_currentUser != null) {
      // Load user trips
      await loadUserTrips();
        
        // Try to sync with backend
        await _syncWithBackend();
      }

      _setError(null);
    } catch (e) {
      _setError('Initialization failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _requestPermissions() async {
    await _locationService.requestLocationPermission();
    await _notificationService.requestNotificationPermission();
  }

  Future<String> _getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    
    if (deviceId == null) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      } else {
        deviceId = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      await prefs.setString('device_id', deviceId);
    }
    
    return deviceId;
  }

  Future<void> registerUser(UserCreate userCreate) async {
    _setLoading(true);
    try {
      // Create user in local database
      User user = User(
        id: 0, // Will be set by database
        deviceId: userCreate.deviceId,
        ageGroup: userCreate.ageGroup,
        gender: userCreate.gender,
        householdSize: userCreate.householdSize,
        consentGiven: userCreate.consentGiven,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      int userId = await _databaseService.insertUser(user);
      user = user.copyWith(id: userId);

      // Try to register with backend
      try {
        Token token = await _apiService.registerUser(userCreate);
        _apiService.setAccessToken(token.accessToken);
        _isOnline = true;
      } catch (e) {
        print('Backend registration failed: $e');
        _isOnline = false;
      }

      _currentUser = user;
      _setError(null);
    } catch (e) {
      _setError('Registration failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile(UserUpdate userUpdate) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      User updatedUser = _currentUser!.copyWith(
        ageGroup: userUpdate.ageGroup ?? _currentUser!.ageGroup,
        gender: userUpdate.gender ?? _currentUser!.gender,
        householdSize: userUpdate.householdSize ?? _currentUser!.householdSize,
        consentGiven: userUpdate.consentGiven ?? _currentUser!.consentGiven,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateUser(updatedUser);

      // Try to sync with backend
      if (_isOnline) {
        try {
          updatedUser = await _apiService.updateUserProfile(userUpdate);
        } catch (e) {
          print('Backend update failed: $e');
        }
      }

      _currentUser = updatedUser;
      _setError(null);
    } catch (e) {
      _setError('Profile update failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserTrips() async {
    if (_currentUser == null) return;

    try {
      _trips = await _databaseService.getUserTrips(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load trips: $e');
    }
  }

  Future<void> createTrip(TripCreate tripCreate) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      // Get next trip number
      int tripNumber = await _databaseService.getNextTripNumber(_currentUser!.id);

      Trip trip = Trip(
        id: 0, // Will be set by database
        userId: _currentUser!.id,
        tripNumber: tripNumber,
        originLat: tripCreate.originLat,
        originLng: tripCreate.originLng,
        originAddress: tripCreate.originAddress,
        destinationLat: tripCreate.destinationLat,
        destinationLng: tripCreate.destinationLng,
        destinationAddress: tripCreate.destinationAddress,
        startTime: tripCreate.startTime,
        endTime: tripCreate.endTime,
        modeOfTravel: tripCreate.modeOfTravel,
        numCoTravellers: tripCreate.numCoTravellers,
        coTravellerRelationships: tripCreate.coTravellerRelationships,
        isConfirmed: tripCreate.isConfirmed,
        isSynced: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      int tripId = await _databaseService.insertTrip(trip);
      trip = trip.copyWith(id: tripId);

      // Try to sync with backend
      if (_isOnline) {
        try {
          tripCreate.userId = _currentUser!.id;
          Trip syncedTrip = await _apiService.createTrip(tripCreate);
          trip = trip.copyWith(
            id: syncedTrip.id,
            isSynced: true,
          );
          await _databaseService.updateTrip(trip);
        } catch (e) {
          print('Backend sync failed: $e');
        }
      }

      _trips.insert(0, trip);
      _setError(null);
    } catch (e) {
      _setError('Failed to create trip: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTrip(int tripId, TripUpdate tripUpdate) async {
    _setLoading(true);
    try {
      Trip? trip = _trips.firstWhere((t) => t.id == tripId);
      if (trip == null) {
        _setError('Trip not found');
        return;
      }

      Trip updatedTrip = trip.copyWith(
        originLat: tripUpdate.originLat ?? trip.originLat,
        originLng: tripUpdate.originLng ?? trip.originLng,
        originAddress: tripUpdate.originAddress ?? trip.originAddress,
        destinationLat: tripUpdate.destinationLat ?? trip.destinationLat,
        destinationLng: tripUpdate.destinationLng ?? trip.destinationLng,
        destinationAddress: tripUpdate.destinationAddress ?? trip.destinationAddress,
        startTime: tripUpdate.startTime ?? trip.startTime,
        endTime: tripUpdate.endTime ?? trip.endTime,
        modeOfTravel: tripUpdate.modeOfTravel ?? trip.modeOfTravel,
        numCoTravellers: tripUpdate.numCoTravellers ?? trip.numCoTravellers,
        coTravellerRelationships: tripUpdate.coTravellerRelationships ?? trip.coTravellerRelationships,
        isConfirmed: tripUpdate.isConfirmed ?? trip.isConfirmed,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateTrip(updatedTrip);

      // Try to sync with backend
      if (_isOnline) {
        try {
          updatedTrip = await _apiService.updateTrip(tripId, tripUpdate);
        } catch (e) {
          print('Backend sync failed: $e');
        }
      }

      int index = _trips.indexWhere((t) => t.id == tripId);
      if (index != -1) {
        _trips[index] = updatedTrip;
      }

      _setError(null);
    } catch (e) {
      _setError('Failed to update trip: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _syncWithBackend() async {
    if (_currentUser == null) return;

    try {
      // Try to login with backend
      Token token = await _apiService.loginUser(_currentUser!.deviceId);
      _apiService.setAccessToken(token.accessToken);
      _isOnline = true;

      // Sync unsynced trips
      List<Trip> unsyncedTrips = await _databaseService.getUnsyncedTrips(_currentUser!.id);
      for (Trip trip in unsyncedTrips) {
        try {
          TripCreate tripCreate = TripCreate(
            userId: trip.userId,
            tripNumber: trip.tripNumber,
            originLat: trip.originLat,
            originLng: trip.originLng,
            originAddress: trip.originAddress,
            destinationLat: trip.destinationLat,
            destinationLng: trip.destinationLng,
            destinationAddress: trip.destinationAddress,
            startTime: trip.startTime,
            endTime: trip.endTime,
            modeOfTravel: trip.modeOfTravel,
            numCoTravellers: trip.numCoTravellers,
            coTravellerRelationships: trip.coTravellerRelationships,
            isConfirmed: trip.isConfirmed,
          );

          Trip syncedTrip = await _apiService.createTrip(tripCreate);
          Trip updatedTrip = trip.copyWith(
            id: syncedTrip.id,
            isSynced: true,
          );
          await _databaseService.updateTrip(updatedTrip);
        } catch (e) {
          print('Failed to sync trip ${trip.id}: $e');
        }
      }
    } catch (e) {
      print('Backend sync failed: $e');
      _isOnline = false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
