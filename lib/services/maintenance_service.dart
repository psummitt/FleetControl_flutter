import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maintenance_record.dart';

class MaintenanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _maintenanceCollection(String companyId) =>
      _firestore
          .collection('companies')
          .doc(companyId)
          .collection('maintenance');

  Stream<List<MaintenanceRecord>> getMaintenanceRecords(String companyId) {
    return _maintenanceCollection(companyId)
        .orderBy('serviceDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceRecord.fromDocument(doc))
            .toList());
  }

  Stream<List<MaintenanceRecord>> getMaintenanceByVehicle(
      String companyId, String vehicleId) {
    return _maintenanceCollection(companyId)
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('serviceDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceRecord.fromDocument(doc))
            .toList());
  }

  Stream<List<MaintenanceRecord>> getUpcomingMaintenance(String companyId) {
    final now = DateTime.now().toIso8601String();
    return _maintenanceCollection(companyId)
        .where('status', isEqualTo: 'scheduled')
        .where('nextServiceDate', isGreaterThanOrEqualTo: now)
        .orderBy('nextServiceDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceRecord.fromDocument(doc))
            .toList());
  }

  Stream<List<MaintenanceRecord>> getOverdueMaintenance(String companyId) {
    final now = DateTime.now().toIso8601String();
    return _maintenanceCollection(companyId)
        .where('status', isEqualTo: 'scheduled')
        .where('nextServiceDate', isLessThan: now)
        .orderBy('nextServiceDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceRecord.fromDocument(doc))
            .toList());
  }

  Future<MaintenanceRecord?> getRecord(String companyId, String recordId) async {
    final doc = await _maintenanceCollection(companyId).doc(recordId).get();
    if (!doc.exists) return null;
    return MaintenanceRecord.fromDocument(doc);
  }

  Future<String> addRecord(String companyId, MaintenanceRecord record) async {
    final docRef =
        await _maintenanceCollection(companyId).add(record.toMap());
    return docRef.id;
  }

  Future<void> updateRecord(
      String companyId, MaintenanceRecord record) async {
    await _maintenanceCollection(companyId)
        .doc(record.id)
        .update(record.toMap());
  }

  Future<void> deleteRecord(String companyId, String recordId) async {
    await _maintenanceCollection(companyId).doc(recordId).delete();
  }

  Future<double> getTotalMaintenanceCost(
      String companyId, DateTime start, DateTime end) async {
    final snapshot = await _maintenanceCollection(companyId)
        .where('serviceDate',
            isGreaterThanOrEqualTo: start.toIso8601String())
        .where('serviceDate',
            isLessThanOrEqualTo: end.toIso8601String())
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['cost'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  Future<int> getMaintenanceCount(String companyId) async {
    final snapshot = await _maintenanceCollection(companyId).count().get();
    return snapshot.count ?? 0;
  }
}
