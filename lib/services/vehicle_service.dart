import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _vehiclesCollection(String companyId) =>
      _firestore.collection('companies').doc(companyId).collection('vehicles');

  Stream<List<Vehicle>> getVehicles(String companyId) {
    return _vehiclesCollection(companyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vehicle.fromDocument(doc))
            .toList());
  }

  Stream<List<Vehicle>> getVehiclesByStatus(String companyId, String status) {
    return _vehiclesCollection(companyId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vehicle.fromDocument(doc))
            .toList());
  }

  Future<Vehicle?> getVehicle(String companyId, String vehicleId) async {
    final doc = await _vehiclesCollection(companyId).doc(vehicleId).get();
    if (!doc.exists) return null;
    return Vehicle.fromDocument(doc);
  }

  Future<String> addVehicle(String companyId, Vehicle vehicle) async {
    final docRef = await _vehiclesCollection(companyId).add(vehicle.toMap());
    return docRef.id;
  }

  Future<void> updateVehicle(String companyId, Vehicle vehicle) async {
    await _vehiclesCollection(companyId).doc(vehicle.id).update(vehicle.toMap());
  }

  Future<void> deleteVehicle(String companyId, String vehicleId) async {
    await _vehiclesCollection(companyId).doc(vehicleId).delete();
  }

  Future<int> getVehicleCount(String companyId) async {
    final snapshot = await _vehiclesCollection(companyId).count().get();
    return snapshot.count ?? 0;
  }

  Future<Map<String, int>> getVehicleStatusCounts(String companyId) async {
    final snapshot = await _vehiclesCollection(companyId).get();
    final counts = <String, int>{
      'active': 0,
      'maintenance': 0,
      'retired': 0,
    };
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'active';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }
}
