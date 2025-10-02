import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io'; // Adding dart:io import for File type
import '../models/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // Get tasks for a specific sucursal
  Stream<List<TaskModel>> getTasksForSucursal(String sucursalId) {
    return _firestore
        .collection('tasks')
        .where('sucursalId', isEqualTo: sucursalId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  // Get tasks assigned to a specific repositor
  Stream<List<TaskModel>> getTasksForRepositor(String repositorId) {
    return _firestore
        .collection('tasks')
        .where('repositorId', isEqualTo: repositorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  // Get pending tasks for a sucursal
  Future<List<TaskModel>> getPendingTasks(String sucursalId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('sucursalId', isEqualTo: sucursalId)
          .where('status', isEqualTo: TaskStatus.pending.name)
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching pending tasks: $e');
    }
  }

  // Start a task (assign to repositor)
  Future<void> startTask(String taskId, String repositorId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': TaskStatus.inProgress.name,
        'repositorId': repositorId,
      });
    } catch (e) {
      throw Exception('Error starting task: $e');
    }
  }

  // Complete a task with photos and data
  Future<void> completeTask({
    required String taskId,
    required int cantidadRepuesta,
    String? observaciones,
    required File fotoAntes,
    required File fotoDespues,
  }) async {
    try {
      // Get current location
      Position? position;
      if (!Platform.isWindows) {
        // Get current location only on mobile platforms
        position = await _getCurrentPosition();
      }
      
      // Upload photos
      final fotoAntesUrl = await _uploadPhoto(fotoAntes, 'antes_$taskId');
      final fotoDespuesUrl = await _uploadPhoto(fotoDespues, 'despues_$taskId');

      // Update task
      final updateData = {
        'status': TaskStatus.completed.name,
        'completedAt': DateTime.now().toIso8601String(),
        'cantidadRepuesta': cantidadRepuesta,
        'observaciones': observaciones,
        'fotoAntes': fotoAntesUrl,
        'fotoDespues': fotoDespuesUrl,
      };

      if (position != null) {
        updateData['latitude'] = position.latitude;
        updateData['longitude'] = position.longitude;
      }

      await _firestore.collection('tasks').doc(taskId).update(updateData);
    } catch (e) {
      throw Exception('Error completing task: $e');
    }
  }

  // Upload photo to Firebase Storage
  Future<String> _uploadPhoto(File photo, String fileName) async {
    try {
      final ref = _storage.ref().child('task_photos/$fileName.jpg');
      final uploadTask = await ref.putFile(photo);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading photo: $e');
    }
  }

  // Get current GPS position
  Future<Position> _getCurrentPosition() async {
    if (Platform.isWindows) {
      throw Exception('Servicios de ubicación no disponibles en Windows');
    }

    // Check location permission
    final permission = await Permission.location.request();
    if (permission != PermissionStatus.granted) {
      throw Exception('Permiso de ubicación denegado');
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están deshabilitados');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Create sample tasks for testing
  Future<void> createSampleTasks(String sucursalId) async {
    final sampleTasks = [
      {
        'id': _uuid.v4(),
        'sucursalId': sucursalId,
        'title': 'Reposición Coca-Cola',
        'description': 'Reponer productos Coca-Cola en góndola principal',
        'status': TaskStatus.pending.name,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'sucursalId': sucursalId,
        'title': 'Reposición Pepsi',
        'description': 'Reponer productos Pepsi en heladera',
        'status': TaskStatus.pending.name,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': _uuid.v4(),
        'sucursalId': sucursalId,
        'title': 'Reposición Snacks',
        'description': 'Reponer snacks variados en góndola de dulces',
        'status': TaskStatus.pending.name,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    final batch = _firestore.batch();
    
    for (final task in sampleTasks) {
      final docRef = _firestore.collection('tasks').doc(task['id'] as String);
      batch.set(docRef, task);
    }
    
    await batch.commit();
  }

  // Approve or reject a completed task (supervisor action)
  Future<void> reviewTask({
    required String taskId,
    required TaskStatus status,
    String? supervisorComment,
  }) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': status.name,
        'supervisorComment': supervisorComment,
      });
    } catch (e) {
      throw Exception('Error reviewing task: $e');
    }
  }
}

// Provider for TaskService
final taskServiceProvider = Provider<TaskService>((ref) => TaskService());

// Provider for tasks by sucursal
final tasksForSucursalProvider = StreamProvider.family<List<TaskModel>, String>((ref, sucursalId) {
  final taskService = ref.watch(taskServiceProvider);
  return taskService.getTasksForSucursal(sucursalId);
});

// Provider for tasks by repositor
final tasksForRepositorProvider = StreamProvider.family<List<TaskModel>, String>((ref, repositorId) {
  final taskService = ref.watch(taskServiceProvider);
  return taskService.getTasksForRepositor(repositorId);
});
