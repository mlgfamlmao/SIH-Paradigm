import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../models/auth.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000'; // Change to your backend URL
  late Dio _dio;
  String? _accessToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _accessToken = null;
        }
        handler.next(error);
      },
    ));
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  // Authentication
  Future<Token> registerUser(UserCreate user) async {
    try {
      final response = await _dio.post('/auth/register', data: user.toJson());
      return Token.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  Future<Token> loginUser(String deviceId) async {
    try {
      final response = await _dio.post('/auth/login', data: deviceId);
      return Token.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // User operations
  Future<User> getUserProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<User> updateUserProfile(UserUpdate userUpdate) async {
    try {
      final response = await _dio.put('/user/profile', data: userUpdate.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Trip operations
  Future<List<Trip>> getUserTrips({int skip = 0, int limit = 100}) async {
    try {
      final response = await _dio.get('/trips', queryParameters: {
        'skip': skip,
        'limit': limit,
      });
      return (response.data as List)
          .map((json) => Trip.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user trips: $e');
    }
  }

  Future<Trip> getTrip(int tripId) async {
    try {
      final response = await _dio.get('/trips/$tripId');
      return Trip.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get trip: $e');
    }
  }

  Future<Trip> createTrip(TripCreate trip) async {
    try {
      final response = await _dio.post('/trips', data: trip.toJson());
      return Trip.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  Future<Trip> updateTrip(int tripId, TripUpdate tripUpdate) async {
    try {
      final response = await _dio.put('/trips/$tripId', data: tripUpdate.toJson());
      return Trip.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update trip: $e');
    }
  }

  Future<void> deleteTrip(int tripId) async {
    try {
      await _dio.delete('/trips/$tripId');
    } catch (e) {
      throw Exception('Failed to delete trip: $e');
    }
  }

  // Sync operations
  Future<List<Trip>> getPendingSyncTrips() async {
    try {
      final response = await _dio.get('/trips/sync/pending');
      return (response.data as List)
          .map((json) => Trip.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending sync trips: $e');
    }
  }

  Future<void> confirmSyncTrips(List<int> tripIds) async {
    try {
      await _dio.post('/trips/sync/confirm', data: tripIds);
    } catch (e) {
      throw Exception('Failed to confirm sync trips: $e');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data;
    } catch (e) {
      throw Exception('Health check failed: $e');
    }
  }
}
