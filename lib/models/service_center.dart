import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceCenter {
  final String id;
  final String companyId;
  final String name;
  final String address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? phone;
  final String? email;
  final String? website;
  final List<String> serviceTypes;
  final double? rating;
  final bool isPreferred;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceCenter({
    required this.id,
    required this.companyId,
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.zipCode,
    this.phone,
    this.email,
    this.website,
    this.serviceTypes = const [],
    this.rating,
    this.isPreferred = false,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get fullAddress {
    final parts = [address];
    if (city != null) parts.add(city!);
    if (state != null && zipCode != null) {
      parts.add('$state $zipCode');
    } else if (state != null) {
      parts.add(state!);
    } else if (zipCode != null) {
      parts.add(zipCode!);
    }
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phone': phone,
      'email': email,
      'website': website,
      'serviceTypes': serviceTypes,
      'rating': rating,
      'isPreferred': isPreferred,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ServiceCenter.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceCenter(
      id: doc.id,
      companyId: data['companyId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'],
      state: data['state'],
      zipCode: data['zipCode'],
      phone: data['phone'],
      email: data['email'],
      website: data['website'],
      serviceTypes: List<String>.from(data['serviceTypes'] ?? []),
      rating: (data['rating'] as num?)?.toDouble(),
      isPreferred: data['isPreferred'] ?? false,
      notes: data['notes'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  ServiceCenter copyWith({
    String? id,
    String? companyId,
    String? name,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? phone,
    String? email,
    String? website,
    List<String>? serviceTypes,
    double? rating,
    bool? isPreferred,
    String? notes,
    bool clearWebsite = false,
    bool clearRating = false,
  }) {
    return ServiceCenter(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: clearWebsite ? null : (website ?? this.website),
      serviceTypes: serviceTypes ?? this.serviceTypes,
      rating: clearRating ? null : (rating ?? this.rating),
      isPreferred: isPreferred ?? this.isPreferred,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
