import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_center.dart';

class ServiceCenterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _centersCollection(String companyId) =>
      _firestore
          .collection('companies')
          .doc(companyId)
          .collection('serviceCenters');

  Stream<List<ServiceCenter>> getServiceCenters(String companyId) {
    return _centersCollection(companyId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceCenter.fromDocument(doc))
            .toList());
  }

  Stream<List<ServiceCenter>> getPreferredCenters(String companyId) {
    return _centersCollection(companyId)
        .where('isPreferred', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceCenter.fromDocument(doc))
            .toList());
  }

  Future<ServiceCenter?> getCenter(String companyId, String centerId) async {
    final doc = await _centersCollection(companyId).doc(centerId).get();
    if (!doc.exists) return null;
    return ServiceCenter.fromDocument(doc);
  }

  Future<String> addCenter(String companyId, ServiceCenter center) async {
    final docRef = await _centersCollection(companyId).add(center.toMap());
    return docRef.id;
  }

  Future<void> updateCenter(String companyId, ServiceCenter center) async {
    await _centersCollection(companyId).doc(center.id).update(center.toMap());
  }

  Future<void> deleteCenter(String companyId, String centerId) async {
    await _centersCollection(companyId).doc(centerId).delete();
  }

  Future<int> getCenterCount(String companyId) async {
    final snapshot = await _centersCollection(companyId).count().get();
    return snapshot.count ?? 0;
  }
}
