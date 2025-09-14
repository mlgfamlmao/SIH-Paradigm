import 'package:json_annotation/json_annotation.dart';

part 'trip.g.dart';

@JsonSerializable()
class Trip {
  final int id;
  final int userId;
  final int tripNumber;
  final double? originLat;
  final double? originLng;
  final String? originAddress;
  final double? destinationLat;
  final double? destinationLng;
  final String? destinationAddress;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? modeOfTravel;
  final int numCoTravellers;
  final String? coTravellerRelationships;
  final bool isConfirmed;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.userId,
    required this.tripNumber,
    this.originLat,
    this.originLng,
    this.originAddress,
    this.destinationLat,
    this.destinationLng,
    this.destinationAddress,
    this.startTime,
    this.endTime,
    this.modeOfTravel,
    required this.numCoTravellers,
    this.coTravellerRelationships,
    required this.isConfirmed,
    required this.isSynced,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  Map<String, dynamic> toJson() => _$TripToJson(this);

  Trip copyWith({
    int? id,
    int? userId,
    int? tripNumber,
    double? originLat,
    double? originLng,
    String? originAddress,
    double? destinationLat,
    double? destinationLng,
    String? destinationAddress,
    DateTime? startTime,
    DateTime? endTime,
    String? modeOfTravel,
    int? numCoTravellers,
    String? coTravellerRelationships,
    bool? isConfirmed,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripNumber: tripNumber ?? this.tripNumber,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      originAddress: originAddress ?? this.originAddress,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      modeOfTravel: modeOfTravel ?? this.modeOfTravel,
      numCoTravellers: numCoTravellers ?? this.numCoTravellers,
      coTravellerRelationships: coTravellerRelationships ?? this.coTravellerRelationships,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class TripCreate {
  final int userId;
  final int tripNumber;
  final double? originLat;
  final double? originLng;
  final String? originAddress;
  final double? destinationLat;
  final double? destinationLng;
  final String? destinationAddress;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? modeOfTravel;
  final int numCoTravellers;
  final String? coTravellerRelationships;
  final bool isConfirmed;

  TripCreate({
    required this.userId,
    required this.tripNumber,
    this.originLat,
    this.originLng,
    this.originAddress,
    this.destinationLat,
    this.destinationLng,
    this.destinationAddress,
    this.startTime,
    this.endTime,
    this.modeOfTravel,
    required this.numCoTravellers,
    this.coTravellerRelationships,
    required this.isConfirmed,
  });

  factory TripCreate.fromJson(Map<String, dynamic> json) => _$TripCreateFromJson(json);
  Map<String, dynamic> toJson() => _$TripCreateToJson(this);
}

@JsonSerializable()
class TripUpdate {
  final double? originLat;
  final double? originLng;
  final String? originAddress;
  final double? destinationLat;
  final double? destinationLng;
  final String? destinationAddress;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? modeOfTravel;
  final int? numCoTravellers;
  final String? coTravellerRelationships;
  final bool? isConfirmed;

  TripUpdate({
    this.originLat,
    this.originLng,
    this.originAddress,
    this.destinationLat,
    this.destinationLng,
    this.destinationAddress,
    this.startTime,
    this.endTime,
    this.modeOfTravel,
    this.numCoTravellers,
    this.coTravellerRelationships,
    this.isConfirmed,
  });

  factory TripUpdate.fromJson(Map<String, dynamic> json) => _$TripUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$TripUpdateToJson(this);
}
