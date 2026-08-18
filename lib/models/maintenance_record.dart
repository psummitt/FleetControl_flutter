import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceRecord {
  final String id;
  final String companyId;
  final String vehicleId;
  final String type;
  final String title;
  final String description;
  final String? serviceCenterId;
  final String? serviceCenterName;
  final double cost;
  final int odometerAtService;
  final DateTime serviceDate;
  final DateTime? nextServiceDate;
  final int? nextServiceOdometer;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceRecord({
    required this.id,
    required this.companyId,
    required this.vehicleId,
    required this.type,
    required this.title,
    this.description = '',
    this.serviceCenterId,
    this.serviceCenterName,
    this.cost = 0,
    this.odometerAtService = 0,
    required this.serviceDate,
    this.nextServiceDate,
    this.nextServiceOdometer,
    this.status = 'completed',
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isOverdue =>
      nextServiceDate != null && nextServiceDate!.isBefore(DateTime.now());
  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'vehicleId': vehicleId,
      'type': type,
      'title': title,
      'description': description,
      'serviceCenterId': serviceCenterId,
      'serviceCenterName': serviceCenterName,
      'cost': cost,
      'odometerAtService': odometerAtService,
      'serviceDate': serviceDate.toIso8601String(),
      'nextServiceDate': nextServiceDate?.toIso8601String(),
      'nextServiceOdometer': nextServiceOdometer,
      'status': status,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory MaintenanceRecord.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MaintenanceRecord(
      id: doc.id,
      companyId: data['companyId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      type: data['type'] ?? 'general',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      serviceCenterId: data['serviceCenterId'],
      serviceCenterName: data['serviceCenterName'],
      cost: (data['cost'] as num?)?.toDouble() ?? 0,
      odometerAtService: data['odometerAtService'] ?? 0,
      serviceDate: data['serviceDate'] != null
          ? DateTime.parse(data['serviceDate'])
          : DateTime.now(),
      nextServiceDate: data['nextServiceDate'] != null
          ? DateTime.parse(data['nextServiceDate'])
          : null,
      nextServiceOdometer: data['nextServiceOdometer'],
      status: data['status'] ?? 'completed',
      notes: data['notes'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  MaintenanceRecord copyWith({
    String? id,
    String? companyId,
    String? vehicleId,
    String? type,
    String? title,
    String? description,
    String? serviceCenterId,
    String? serviceCenterName,
    double? cost,
    int? odometerAtService,
    DateTime? serviceDate,
    DateTime? nextServiceDate,
    int? nextServiceOdometer,
    String? status,
    String? notes,
    bool clearNextServiceDate = false,
    bool clearServiceCenter = false,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      serviceCenterId:
          clearServiceCenter ? null : (serviceCenterId ?? this.serviceCenterId),
      serviceCenterName: clearServiceCenter
          ? null
          : (serviceCenterName ?? this.serviceCenterName),
      cost: cost ?? this.cost,
      odometerAtService: odometerAtService ?? this.odometerAtService,
      serviceDate: serviceDate ?? this.serviceDate,
      nextServiceDate:
          clearNextServiceDate ? null : (nextServiceDate ?? this.nextServiceDate),
      nextServiceOdometer: nextServiceOdometer ?? this.nextServiceOdometer,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
