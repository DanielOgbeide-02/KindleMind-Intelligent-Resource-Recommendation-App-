import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../provider/admin_model.dart';
import '../../provider/resource_model/resource_model.dart';

class AdminRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen for admin auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Admin Sign In
  Future<AdminModel?> adminSignIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Check if user is admin
        DocumentSnapshot adminDoc = await _firestore
            .collection('admins')
            .doc(user.uid)
            .get();

        if (!adminDoc.exists) {
          // Not an admin, sign out
          await _auth.signOut();
          throw Exception('Access denied: Admin privileges required');
        }

        // Safely get document data
        final data = adminDoc.data();
        if (data == null) {
          await _auth.signOut();
          throw Exception('Admin data not found');
        }

        // Update last login
        try {
          await _firestore.collection('admins').doc(user.uid).update({
            'lastLogin': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('Warning: Could not update last login: $e');
          // Don't throw here, as login can still proceed
        }

        // Ensure uid is included in the data
        final adminData = Map<String, dynamic>.from(data as Map<String, dynamic>);
        adminData['uid'] = user.uid; // Ensure uid is always present

        return AdminModel.fromMap(adminData);
      }
      return null;
    } catch (e) {
      print('Admin sign in error: $e');
      throw Exception(e.toString());
    }
  }

  // Admin Sign Out
  Future<void> adminSignOut() async {
    await _auth.signOut();
  }

  // Get Admin Details
  Future<AdminModel?> getAdminDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('admins').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
        data['uid'] = uid; // Ensure uid is always present
        return AdminModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Get admin details error: $e');
      throw Exception('Failed to get admin details: ${e.toString()}');
    }
  }

  // Create Admin (only for initial setup or super admin use)
  Future<AdminModel?> createAdmin({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        final adminModel = AdminModel(
          uid: user.uid,
          email: email,
          name: name,
        );

        await _firestore.collection('admins').doc(user.uid).set(adminModel.toMap());
        return adminModel;
      }
      return null;
    } catch (e) {
      print('Create admin error: $e');
      throw Exception(e.toString());
    }
  }

  // Upload Resource to Firestore
  Future<String> uploadResource(ResourceModel resource) async {
    try {
      // Generate a unique ID for the resource
      String resourceId = _firestore.collection('resources').doc().id;

      await _firestore.collection('resources').doc(resourceId).set({
        'id': resourceId,
        ...resource.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      });

      return 'Resource uploaded successfully';
    } catch (e) {
      print('Upload resource error: $e');
      throw Exception('Failed to upload resource: ${e.toString()}');
    }
  }

  // Upload Multiple Resources
  Future<String> uploadMultipleResources(List<ResourceModel> resources) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (ResourceModel resource in resources) {
        String resourceId = _firestore.collection('resources').doc().id;
        DocumentReference docRef = _firestore.collection('resources').doc(resourceId);

        batch.set(docRef, {
          'id': resourceId,
          ...resource.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _auth.currentUser?.uid,
        });
      }

      await batch.commit();
      return '${resources.length} resources uploaded successfully';
    } catch (e) {
      print('Upload multiple resources error: $e');
      throw Exception('Failed to upload resources: ${e.toString()}');
    }
  }

  // Get All Resources (for admin management)
  Future<List<Map<String, dynamic>>> getAllResources() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('resources')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data != null) {
          return {
            'id': doc.id,
            ...data as Map<String, dynamic>
          };
        }
        return {'id': doc.id}; // Return at least the ID if data is null
      }).toList();
    } catch (e) {
      print('Get all resources error: $e');
      throw Exception('Failed to fetch resources: ${e.toString()}');
    }
  }

  // Delete Resource
  Future<String> deleteResource(String resourceId) async {
    try {
      await _firestore.collection('resources').doc(resourceId).delete();
      return 'Resource deleted successfully';
    } catch (e) {
      print('Delete resource error: $e');
      throw Exception('Failed to delete resource: ${e.toString()}');
    }
  }

  // Update Resource
  Future<String> updateResource(String resourceId, ResourceModel updatedResource) async {
    try {
      await _firestore.collection('resources').doc(resourceId).update({
        ...updatedResource.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.uid,
      });
      return 'Resource updated successfully';
    } catch (e) {
      print('Update resource error: $e');
      throw Exception('Failed to update resource: ${e.toString()}');
    }
  }

  // Get Resource Statistics
  Future<Map<String, int>> getResourceStatistics() async {
    try {
      QuerySnapshot resourcesSnapshot = await _firestore.collection('resources').get();
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      // Get resource types count
      Map<String, int> typeCount = {};
      for (var doc in resourcesSnapshot.docs) {
        final data = doc.data();
        String type = 'Unknown';
        if (data is Map<String, dynamic>) {
          type = data['articleType']?.toString() ?? 'Unknown';
        }
        typeCount[type] = (typeCount[type] ?? 0) + 1;
      }

      return {
        'totalResources': resourcesSnapshot.docs.length,
        'totalUsers': usersSnapshot.docs.length,
        ...typeCount,
      };
    } catch (e) {
      print('Get statistics error: $e');
      throw Exception('Failed to get statistics: ${e.toString()}');
    }
  }

  // Search Resources
  Future<List<Map<String, dynamic>>> searchResources(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('resources')
          .where('quote', isGreaterThanOrEqualTo: query)
          .where('quote', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data != null) {
          return {
            'id': doc.id,
            ...data as Map<String, dynamic>
          };
        }
        return {'id': doc.id}; // Return at least the ID if data is null
      }).toList();
    } catch (e) {
      print('Search resources error: $e');
      throw Exception('Failed to search resources: ${e.toString()}');
    }
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      DocumentSnapshot doc = await _firestore.collection('admins').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      print('Check admin status error: $e');
      return false;
    }
  }
}