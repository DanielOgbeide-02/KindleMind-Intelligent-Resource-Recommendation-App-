import 'package:cloud_firestore/cloud_firestore.dart';

class ResourcesModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 1️⃣ Fetch one random motivational quote
  Future<Map<String, dynamic>?> getDailyMotivation() async {
    final snapshot = await _firestore.collection('motivational').get();

    if (snapshot.docs.isNotEmpty) {
      final randomDoc = (snapshot.docs..shuffle()).first;
      return randomDoc.data();
    }

    return null;
  }

  /// 2️⃣ Fetch ALL motivational quotes
  Future<List<Map<String, dynamic>>> getAllMotivationalQuotes() async {
    final snapshot = await _firestore.collection('motivational').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// 3️⃣ Fetch one random coping strategy
  Future<Map<String, dynamic>?> getRandomCopingStrategy() async {
    final snapshot = await _firestore.collection('coping').get();

    if (snapshot.docs.isNotEmpty) {
      final randomDoc = (snapshot.docs..shuffle()).first;
      return randomDoc.data();
    }

    return null;
  }

  /// 4️⃣ Fetch ALL coping strategies
  Future<List<Map<String, dynamic>>> getAllCopingStrategies() async {
    final snapshot = await _firestore.collection('coping').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// 5️⃣ Fetch ALL articles
  Future<List<Map<String, dynamic>>> getAllArticles() async {
    final snapshot = await _firestore.collection('article').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
