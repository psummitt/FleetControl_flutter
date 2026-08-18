import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String companyId;
  final String name;
  final int year;
  final String make;
  final String model;
  final String? vin;
  final String? licenseState;
  final String? licenseNumber;
  final String? color;
  final int odometer;
  final String? keyIgnition;
  final String? keyDoor;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? notes;
  final String status;
  final String? assignedDriverId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.companyId,
    required this.name,
    required this.year,
    required this.make,
    required this.model,
    this.vin,
    this.licenseState,
    this.licenseNumber,
    this.color,
    this.odometer = 0,
    this.keyIgnition,
    this.keyDoor,
    this.purchaseDate,
    this.purchasePrice,
    this.notes,
    this.status = 'active',
    this.assignedDriverId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get displayName => '$year $make $model';
  String get shortName => '$year $make $model';

  bool get isAvailable => status == 'active' && assignedDriverId == null;
  bool get isAssigned => assignedDriverId != null;
  bool get isMaintenance => status == 'maintenance';
  bool get isRetired => status == 'retired';

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'name': name,
      'year': year,
      'make': make,
      'model': model,
      'vin': vin,
      'licenseState': licenseState,
      'licenseNumber': licenseNumber,
      'color': color,
      'odometer': odometer,
      'keyIgnition': keyIgnition,
      'keyDoor': keyDoor,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchasePrice': purchasePrice,
      'notes': notes,
      'status': status,
      'assignedDriverId': assignedDriverId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Vehicle.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      companyId: data['companyId'] ?? '',
      name: data['name'] ?? '',
      year: data['year'] ?? 0,
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      vin: data['vin'],
      licenseState: data['licenseState'],
      licenseNumber: data['licenseNumber'],
      color: data['color'],
      odometer: data['odometer'] ?? 0,
      keyIgnition: data['keyIgnition'],
      keyDoor: data['keyDoor'],
      purchaseDate: data['purchaseDate'] != null
          ? DateTime.parse(data['purchaseDate'])
          : null,
      purchasePrice: (data['purchasePrice'] as num?)?.toDouble(),
      notes: data['notes'],
      status: data['status'] ?? 'active',
      assignedDriverId: data['assignedDriverId'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Vehicle copyWith({
    String? id,
    String? companyId,
    String? name,
    int? year,
    String? make,
    String? model,
    String? vin,
    String? licenseState,
    String? licenseNumber,
    String? color,
    int? odometer,
    String? keyIgnition,
    String? keyDoor,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? notes,
    String? status,
    String? assignedDriverId,
    bool clearAssignedDriver = false,
  }) {
    return Vehicle(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      year: year ?? this.year,
      make: make ?? this.make,
      model: model ?? this.model,
      vin: vin ?? this.vin,
      licenseState: licenseState ?? this.licenseState,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      color: color ?? this.color,
      odometer: odometer ?? this.odometer,
      keyIgnition: keyIgnition ?? this.keyIgnition,
      keyDoor: keyDoor ?? this.keyDoor,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      assignedDriverId:
          clearAssignedDriver ? null : (assignedDriverId ?? this.assignedDriverId),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
