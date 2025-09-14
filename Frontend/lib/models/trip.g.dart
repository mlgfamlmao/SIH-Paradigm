// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      tripNumber: json['trip_number'] as int,
      originLat: (json['origin_lat'] as num?)?.toDouble(),
      originLng: (json['origin_lng'] as num?)?.toDouble(),
      originAddress: json['origin_address'] as String?,
      destinationLat: (json['destination_lat'] as num?)?.toDouble(),
      destinationLng: (json['destination_lng'] as num?)?.toDouble(),
      destinationAddress: json['destination_address'] as String?,
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      modeOfTravel: json['mode_of_travel'] as String?,
      numCoTravellers: json['num_co_travellers'] as int,
      coTravellerRelationships: json['co_traveller_relationships'] as String?,
      isConfirmed: json['is_confirmed'] as bool,
      isSynced: json['is_synced'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'trip_number': instance.tripNumber,
      'origin_lat': instance.originLat,
      'origin_lng': instance.originLng,
      'origin_address': instance.originAddress,
      'destination_lat': instance.destinationLat,
      'destination_lng': instance.destinationLng,
      'destination_address': instance.destinationAddress,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'mode_of_travel': instance.modeOfTravel,
      'num_co_travellers': instance.numCoTravellers,
      'co_traveller_relationships': instance.coTravellerRelationships,
      'is_confirmed': instance.isConfirmed,
      'is_synced': instance.isSynced,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

TripCreate _$TripCreateFromJson(Map<String, dynamic> json) => TripCreate(
      userId: json['user_id'] as int,
      tripNumber: json['trip_number'] as int,
      originLat: (json['origin_lat'] as num?)?.toDouble(),
      originLng: (json['origin_lng'] as num?)?.toDouble(),
      originAddress: json['origin_address'] as String?,
      destinationLat: (json['destination_lat'] as num?)?.toDouble(),
      destinationLng: (json['destination_lng'] as num?)?.toDouble(),
      destinationAddress: json['destination_address'] as String?,
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      modeOfTravel: json['mode_of_travel'] as String?,
      numCoTravellers: json['num_co_travellers'] as int,
      coTravellerRelationships: json['co_traveller_relationships'] as String?,
      isConfirmed: json['is_confirmed'] as bool,
    );

Map<String, dynamic> _$TripCreateToJson(TripCreate instance) => <String, dynamic>{
      'user_id': instance.userId,
      'trip_number': instance.tripNumber,
      'origin_lat': instance.originLat,
      'origin_lng': instance.originLng,
      'origin_address': instance.originAddress,
      'destination_lat': instance.destinationLat,
      'destination_lng': instance.destinationLng,
      'destination_address': instance.destinationAddress,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'mode_of_travel': instance.modeOfTravel,
      'num_co_travellers': instance.numCoTravellers,
      'co_traveller_relationships': instance.coTravellerRelationships,
      'is_confirmed': instance.isConfirmed,
    };

TripUpdate _$TripUpdateFromJson(Map<String, dynamic> json) => TripUpdate(
      originLat: (json['origin_lat'] as num?)?.toDouble(),
      originLng: (json['origin_lng'] as num?)?.toDouble(),
      originAddress: json['origin_address'] as String?,
      destinationLat: (json['destination_lat'] as num?)?.toDouble(),
      destinationLng: (json['destination_lng'] as num?)?.toDouble(),
      destinationAddress: json['destination_address'] as String?,
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      modeOfTravel: json['mode_of_travel'] as String?,
      numCoTravellers: json['num_co_travellers'] as int?,
      coTravellerRelationships: json['co_traveller_relationships'] as String?,
      isConfirmed: json['is_confirmed'] as bool?,
    );

Map<String, dynamic> _$TripUpdateToJson(TripUpdate instance) => <String, dynamic>{
      'origin_lat': instance.originLat,
      'origin_lng': instance.originLng,
      'origin_address': instance.originAddress,
      'destination_lat': instance.destinationLat,
      'destination_lng': instance.destinationLng,
      'destination_address': instance.destinationAddress,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'mode_of_travel': instance.modeOfTravel,
      'num_co_travellers': instance.numCoTravellers,
      'co_traveller_relationships': instance.coTravellerRelationships,
      'is_confirmed': instance.isConfirmed,
    };
