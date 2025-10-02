enum TaskStatus { pending, inProgress, completed, approved, rejected }

class TaskModel {
  final String id;
  final String sucursalId;
  final String title;
  final String description;
  final TaskStatus status;
  final String? repositorId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? cantidadRepuesta;
  final String? observaciones;
  final String? fotoAntes;
  final String? fotoDespues;
  final double? latitude;
  final double? longitude;
  final String? supervisorComment;

  const TaskModel({
    required this.id,
    required this.sucursalId,
    required this.title,
    required this.description,
    required this.status,
    this.repositorId,
    required this.createdAt,
    this.completedAt,
    this.cantidadRepuesta,
    this.observaciones,
    this.fotoAntes,
    this.fotoDespues,
    this.latitude,
    this.longitude,
    this.supervisorComment,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      sucursalId: json['sucursalId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      repositorId: json['repositorId'] as String?,
      createdAt: _parseDate(json['createdAt']),
      completedAt: json['completedAt'] != null ? _parseDate(json['completedAt']) : null,
      cantidadRepuesta: json['cantidadRepuesta'] is int ? json['cantidadRepuesta'] as int? : null,
      observaciones: json['observaciones'] as String?,
      fotoAntes: json['fotoAntes'] as String?,
      fotoDespues: json['fotoDespues'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      supervisorComment: json['supervisorComment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sucursalId': sucursalId,
      'title': title,
      'description': description,
      'status': status.name,
      'repositorId': repositorId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cantidadRepuesta': cantidadRepuesta,
      'observaciones': observaciones,
      'fotoAntes': fotoAntes,
      'fotoDespues': fotoDespues,
      'latitude': latitude,
      'longitude': longitude,
      'supervisorComment': supervisorComment,
    };
  }

  // 👇 Helper para manejar Timestamp de Firestore o String ISO
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is dynamic && value.toDate != null) return value.toDate(); // para Timestamp de Firestore
    throw Exception('Formato de fecha no soportado: $value');
  }
}
