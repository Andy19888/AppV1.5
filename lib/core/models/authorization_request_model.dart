import 'location_model.dart'; // Asegúrate que la ruta sea correcta

enum AuthorizationStatus { pending, approved, rejected }

class AuthorizationRequestModel {
  final String id;
  final String repositorId;
  final String repositorName;
  final String repositorEmail;
  final String sucursalId;
  final LocationModel location;
  final AuthorizationStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? supervisorId;
  final String? comment;

  const AuthorizationRequestModel({
    required this.id,
    required this.repositorId,
    required this.repositorName,
    required this.repositorEmail,
    required this.sucursalId,
    required this.location,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.supervisorId,
    this.comment,
  });

  factory AuthorizationRequestModel.fromJson(Map<String, dynamic> json) {
    return AuthorizationRequestModel(
      id: json['id'] as String,
      repositorId: json['repositorId'] as String,
      repositorName: json['repositorName'] as String,
      repositorEmail: json['repositorEmail'] as String,
      sucursalId: json['sucursalId'] as String,
      location: LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      status: AuthorizationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AuthorizationStatus.pending,
      ),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt'] as String) 
          : null,
      supervisorId: json['supervisorId'] as String?,
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repositorId': repositorId,
      'repositorName': repositorName,
      'repositorEmail': repositorEmail,
      'sucursalId': sucursalId,
      'location': location.toJson(),
      'status': status.name,
      'requestedAt': requestedAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'supervisorId': supervisorId,
      'comment': comment,
    };
  }
}
