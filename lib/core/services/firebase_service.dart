import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/location_model.dart';
import '../models/task_model.dart';
import '../models/authorization_request_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String locationsCollection = 'locations';
  static const String tasksCollection = 'tasks';
  static const String authRequestsCollection = 'authorization_requests';

  // User Management
  static Future<void> createUser(UserModel user) async {
    await _firestore.collection(usersCollection).doc(user.id).set(user.toJson());
  }

  static Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection(usersCollection).doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<void> updateUser(UserModel user) async {
    await _firestore.collection(usersCollection).doc(user.id).update(user.toJson());
  }

  static Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(usersCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromJson(doc.data()))
            .toList());
  }

  static Stream<List<UserModel>> getUsersByRole(UserRole role) {
    return _firestore
        .collection(usersCollection)
        .where('role', isEqualTo: role.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromJson(doc.data()))
            .toList());
  }

  // Location Management
  static Future<void> createLocation(LocationModel location) async {
    await _firestore.collection(locationsCollection).doc(location.id).set(location.toJson());
  }

  static Future<void> updateLocation(LocationModel location) async {
    await _firestore.collection(locationsCollection).doc(location.id).update(location.toJson());
  }

  static Future<void> deleteLocation(String locationId) async {
    await _firestore.collection(locationsCollection).doc(locationId).delete();
  }

  static Stream<List<LocationModel>> getAllLocations() {
    return _firestore
        .collection(locationsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LocationModel.fromJson(doc.data()))
            .toList());
  }

  static Future<List<LocationModel>> getLocationsByProvince(String provincia) async {
    final snapshot = await _firestore
        .collection(locationsCollection)
        .where('provincia', isEqualTo: provincia)
        .get();
    
    return snapshot.docs
        .map((doc) => LocationModel.fromJson(doc.data()))
        .toList();
  }

  // Task Management
  static Future<void> createTask(TaskModel task) async {
    await _firestore.collection(tasksCollection).doc(task.id).set(task.toJson());
  }

  static Future<void> updateTask(TaskModel task) async {
    await _firestore.collection(tasksCollection).doc(task.id).update(task.toJson());
  }

  static Future<void> deleteTask(String taskId) async {
    await _firestore.collection(tasksCollection).doc(taskId).delete();
  }

  static Stream<List<TaskModel>> getAllTasks() {
    return _firestore
        .collection(tasksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  static Stream<List<TaskModel>> getTasksByRepositor(String repositorId) {
    return _firestore
        .collection(tasksCollection)
        .where('repositorId', isEqualTo: repositorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  static Stream<List<TaskModel>> getTasksBySucursal(String sucursalId) {
    return _firestore
        .collection(tasksCollection)
        .where('sucursalId', isEqualTo: sucursalId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  static Stream<List<TaskModel>> getTasksByStatus(TaskStatus status) {
    return _firestore
        .collection(tasksCollection)
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  // Authorization Request Management
  static Future<void> createAuthorizationRequest(AuthorizationRequestModel request) async {
    await _firestore.collection(authRequestsCollection).doc(request.id).set(request.toJson());
  }

  static Future<void> updateAuthorizationRequest(AuthorizationRequestModel request) async {
    await _firestore.collection(authRequestsCollection).doc(request.id).update(request.toJson());
  }

  static Stream<List<AuthorizationRequestModel>> getAuthorizationRequestsBySupervisor(String supervisorId) {
    return _firestore
        .collection(authRequestsCollection)
        .where('supervisorId', isEqualTo: supervisorId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuthorizationRequestModel.fromJson(doc.data()))
            .toList());
  }

  static Stream<List<AuthorizationRequestModel>> getAuthorizationRequestsByRepositor(String repositorId) {
    return _firestore
        .collection(authRequestsCollection)
        .where('repositorId', isEqualTo: repositorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuthorizationRequestModel.fromJson(doc.data()))
            .toList());
  }

  // File Storage
  static Future<String> uploadImage(String path, List<int> imageBytes) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putData(Uint8List.fromList(imageBytes));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  static Future<void> deleteImage(String url) async {
    final ref = _storage.refFromURL(url);
    await ref.delete();
  }

  // Analytics and Reports
  static Future<Map<String, dynamic>> getTaskAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? sucursalId,
  }) async {
    Query query = _firestore.collection(tasksCollection);
    
    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    if (sucursalId != null) {
      query = query.where('sucursalId', isEqualTo: sucursalId);
    }
    
    final snapshot = await query.get();
    final tasks = snapshot.docs.map((doc) => TaskModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    
    return {
      'totalTasks': tasks.length,
      'pendingTasks': tasks.where((t) => t.status == TaskStatus.pending).length,
      'inProgressTasks': tasks.where((t) => t.status == TaskStatus.inProgress).length,
      'completedTasks': tasks.where((t) => t.status == TaskStatus.completed).length,
      'approvedTasks': tasks.where((t) => t.status == TaskStatus.approved).length,
      'rejectedTasks': tasks.where((t) => t.status == TaskStatus.rejected).length,
      'averageCompletionTime': _calculateAverageCompletionTime(tasks),
      'tasksByDay': _groupTasksByDay(tasks),
    };
  }

  static double _calculateAverageCompletionTime(List<TaskModel> tasks) {
    final completedTasks = tasks.where((t) => t.completedAt != null).toList();
    if (completedTasks.isEmpty) return 0.0;
    
    final totalHours = completedTasks.fold<double>(0.0, (sum, task) {
      final duration = task.completedAt!.difference(task.createdAt);
      return sum + duration.inHours;
    });
    
    return totalHours / completedTasks.length;
  }

  static Map<String, int> _groupTasksByDay(List<TaskModel> tasks) {
    final Map<String, int> tasksByDay = {};
    
    for (final task in tasks) {
      final day = task.createdAt.toIso8601String().split('T')[0];
      tasksByDay[day] = (tasksByDay[day] ?? 0) + 1;
    }
    
    return tasksByDay;
  }

  // Batch Operations
  static Future<void> batchUpdateTasks(List<TaskModel> tasks) async {
    final batch = _firestore.batch();
    
    for (final task in tasks) {
      final docRef = _firestore.collection(tasksCollection).doc(task.id);
      batch.update(docRef, task.toJson());
    }
    
    await batch.commit();
  }

  // Real-time listeners cleanup
  static void dispose() {
    // Any cleanup if needed
  }
}
