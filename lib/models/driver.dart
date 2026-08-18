import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String id;
  final String companyId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? licenseNumber;
  final String? licenseState;
  final DateTime? licenseExpiry;
  final String status;
  final String? assignedVehicleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Driver({
    required this.id,
    required this.companyId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.licenseNumber,
    this.licenseState,
    this.licenseExpiry,
    this.status = 'active',
    this.assignedVehicleId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';
  bool get isActive => status == 'active';
  bool get isAssigned => assignedVehicleId != null;

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'licenseState': licenseState,
      'licenseExpiry': licenseExpiry?.toIso8601String(),
      'status': status,
      'assignedVehicleId': assignedVehicleId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Driver.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Driver(
      id: doc.id,
      companyId: data['companyId'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      licenseNumber: data['licenseNumber'],
      licenseState: data['licenseState'],
      licenseExpiry: data['licenseExpiry'] != null
          ? DateTime.parse(data['licenseExpiry'])
          : null,
      status: data['status'] ?? 'active',
      assignedVehicleId: data['assignedVehicleId'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Driver copyWith({
    String? id,
    String? companyId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? licenseNumber,
    String? licenseState,
    DateTime? licenseExpiry,
    String? status,
    String? assignedVehicleId,
    bool clearAssignedVehicle = false,
  }) {
    return Driver(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseState: licenseState ?? this.licenseState,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      status: status ?? this.status,
      assignedVehicleId: clearAssignedVehicle
          ? null
          : (assignedVehicleId ?? this.assignedVehicleId),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
