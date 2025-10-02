class LocationModel {
  final String id; // lo usamos como doc.id
  final String name;
  final List<String> sucursales;
  final String? provincia;
  final String? localidad;
  final String? cadena;
  final String? sucursal;
  final String? sucursalId;

  LocationModel({
    required this.id,
    required this.name,
    this.sucursales = const [],
    this.provincia,
    this.localidad,
    this.cadena,
    this.sucursal,
    this.sucursalId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String? ?? '', // fallback vacío si no viene
      name: json['name'] as String? ?? '',
      sucursales: (json['sucursales'] != null)
          ? List<String>.from(json['sucursales'])
          : [],
      provincia: json['provincia'] as String?,
      localidad: json['localidad'] as String?,
      cadena: json['cadena'] as String?,
      sucursal: json['sucursal'] as String?,
      sucursalId: json['sucursalId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sucursales': sucursales,
      'provincia': provincia,
      'localidad': localidad,
      'cadena': cadena,
      'sucursal': sucursal,
      'sucursalId': sucursalId,
    };
  }

  String get fullAddress =>
      '${provincia ?? ''}, ${localidad ?? ''} - ${cadena ?? ''} (${sucursal ?? ''})';
}

class DetailedLocationModel {
  final String provincia;
  final String localidad;
  final String cadena;
  final String sucursal;
  final String sucursalId;

  const DetailedLocationModel({
    required this.provincia,
    required this.localidad,
    required this.cadena,
    required this.sucursal,
    required this.sucursalId,
  });

  factory DetailedLocationModel.fromJson(Map<String, dynamic> json) {
    return DetailedLocationModel(
      provincia: json['provincia'] as String? ?? '',
      localidad: json['localidad'] as String? ?? '',
      cadena: json['cadena'] as String? ?? '',
      sucursal: json['sucursal'] as String? ?? '',
      sucursalId: json['sucursalId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provincia': provincia,
      'localidad': localidad,
      'cadena': cadena,
      'sucursal': sucursal,
      'sucursalId': sucursalId,
    };
  }

  String get fullAddress =>
      '${provincia}, ${localidad} - ${cadena} (${sucursal})';
}
