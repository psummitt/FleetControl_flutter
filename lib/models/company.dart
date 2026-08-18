import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String id;
  final String name;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? phone;
  final String? email;
  final DateTime createdAt;

  Company({
    required this.id,
    required this.name,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zipCode,
    this.phone,
    this.email,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get fullAddress {
    final parts = <String>[];
    if (address1 != null) parts.add(address1!);
    if (address2 != null && address2!.isNotEmpty) parts.add(address2!);
    if (city != null) parts.add(city!);
    if (state != null && zipCode != null) {
      parts.add('$state $zipCode');
    }
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address1': address1,
      'address2': address2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phone': phone,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Company.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Company(
      id: doc.id,
      name: data['name'] ?? '',
      address1: data['address1'],
      address2: data['address2'],
      city: data['city'],
      state: data['state'],
      zipCode: data['zipCode'],
      phone: data['phone'],
      email: data['email'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Company copyWith({
    String? id,
    String? name,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zipCode,
    String? phone,
    String? email,
    bool clearAddress2 = false,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      address1: address1 ?? this.address1,
      address2: clearAddress2 ? null : (address2 ?? this.address2),
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt,
    );
  }
}
