import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';

class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _driversCollection(String companyId) =>
      _firestore.collection('companies').doc(companyId).collection('drivers');

  Stream<List<Driver>> getDrivers(String companyId) {
    return _driversCollection(companyId)
        .orderBy('lastName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Driver.fromDocument(doc))
            .toList());
  }

  Stream<List<Driver>> getDriversByStatus(String companyId, String status) {
    return _driversCollection(companyId)
        .where('status', isEqualTo: status)
        .orderBy('lastName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Driver.fromDocument(doc))
            .toList());
  }

  Future<Driver?> getDriver(String companyId, String driverId) async {
    final doc = await _driversCollection(companyId).doc(driverId).get();
    if (!doc.exists) return null;
    return Driver.fromDocument(doc);
  }

  Future<String> addDriver(String companyId, Driver driver) async {
    final docRef = await _driversCollection(companyId).add(driver.toMap());
    return docRef.id;
  }

  Future<void> updateDriver(String companyId, Driver driver) async {
    await _driversCollection(companyId).doc(driver.id).update(driver.toMap());
  }

  Future<void> deleteDriver(String companyId, String driverId) async {
    await _driversCollection(companyId).doc(driverId).delete();
  }

  Future<int> getDriverCount(String companyId) async {
    final snapshot = await _driversCollection(companyId).count().get();
    return snapshot.count ?? 0;
  }

  Future<Map<String, int>> getDriverStatusCounts(String companyId) async {
    final snapshot = await _driversCollection(companyId).get();
    final counts = <String, int>{
      'active': 0,
      'inactive': 0,
    };
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'active';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }
}
