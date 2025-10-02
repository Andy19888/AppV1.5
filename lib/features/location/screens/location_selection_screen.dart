import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/location_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  ConsumerState<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> {
  String? selectedProvincia;
  String? selectedLocalidad;
  String? selectedCadena;
  LocationModel? selectedSucursal;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
            },
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return _buildLocationSelection(user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildLocationSelection(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, ${user.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rol: ${_getRoleText(user.role)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildProvinceDropdown(),
          const SizedBox(height: 16),
          if (selectedProvincia != null) ...[
            _buildLocalidadDropdown(),
            const SizedBox(height: 16),
          ],
          if (selectedLocalidad != null) ...[
            _buildCadenaDropdown(),
            const SizedBox(height: 16),
          ],
          if (selectedCadena != null) ...[
            _buildSucursalDropdown(),
            const SizedBox(height: 24),
          ],
          if (selectedSucursal != null) ...[
            ElevatedButton(
              onPressed: isLoading ? null : () => _handleContinue(user),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Continuar'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    final provincesAsync = ref.watch(provincesProvider);
    return provincesAsync.when(
      data: (provinces) {
        if (provinces.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('No hay ubicaciones disponibles'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final locationService = ref.read(locationServiceProvider);
                      await locationService.addSampleLocations();
                      ref.invalidate(provincesProvider);
                    },
                    child: const Text('Cargar ubicaciones de ejemplo'),
                  ),
                ],
              ),
            ),
          );
        }
        return DropdownButtonFormField<String>(
          value: selectedProvincia,
          decoration: const InputDecoration(
            labelText: 'Provincia',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items: provinces
              .whereType<String>()
              .map((provincia) => DropdownMenuItem<String>(
                    value: provincia,
                    child: Text(provincia),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedProvincia = value;
              selectedLocalidad = null;
              selectedCadena = null;
              selectedSucursal = null;
            });
          },
        );
      },
      loading: () => DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Cargando provincias...',
          prefixIcon: Icon(Icons.location_on_outlined),
        ),
        items: const [],
        onChanged: null,
      ),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildLocalidadDropdown() {
    final localidadesAsync = ref.watch(localidadesProvider(selectedProvincia!));
    return localidadesAsync.when(
      data: (localidades) {
        return DropdownButtonFormField<String>(
          value: selectedLocalidad,
          decoration: const InputDecoration(
            labelText: 'Localidad',
            prefixIcon: Icon(Icons.location_city_outlined),
          ),
          items: localidades
              .whereType<String>()
              .map((localidad) => DropdownMenuItem<String>(
                    value: localidad,
                    child: Text(localidad),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedLocalidad = value;
              selectedCadena = null;
              selectedSucursal = null;
            });
          },
        );
      },
      loading: () => DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Cargando localidades...',
          prefixIcon: Icon(Icons.location_city_outlined),
        ),
        items: const [],
        onChanged: null,
      ),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildCadenaDropdown() {
    final cadenasAsync = ref.watch(cadenasProvider({
      'provincia': selectedProvincia!,
      'localidad': selectedLocalidad!,
    }));
    return cadenasAsync.when(
      data: (cadenas) {
        return DropdownButtonFormField<String>(
          value: selectedCadena,
          decoration: const InputDecoration(
            labelText: 'Cadena',
            prefixIcon: Icon(Icons.store_outlined),
          ),
          items: cadenas
              .whereType<String>()
              .map((cadena) => DropdownMenuItem<String>(
                    value: cadena,
                    child: Text(cadena),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedCadena = value;
              selectedSucursal = null;
            });
          },
        );
      },
      loading: () => DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Cargando cadenas...',
          prefixIcon: Icon(Icons.store_outlined),
        ),
        items: const [],
        onChanged: null,
      ),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildSucursalDropdown() {
    final sucursalesAsync = ref.watch(sucursalesProvider({
      'provincia': selectedProvincia!,
      'localidad': selectedLocalidad!,
      'cadena': selectedCadena!,
    }));
    return sucursalesAsync.when(
      data: (sucursales) {
        return DropdownButtonFormField<LocationModel>(
          value: selectedSucursal,
          decoration: const InputDecoration(
            labelText: 'Sucursal',
            prefixIcon: Icon(Icons.business_outlined),
          ),
          items: sucursales
              .whereType<LocationModel>()
              .map((sucursal) => DropdownMenuItem<LocationModel>(
                    value: sucursal,
                    child: Text(sucursal.sucursal ?? sucursal.name),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedSucursal = value;
            });
          },
        );
      },
      loading: () => DropdownButtonFormField<LocationModel>(
        decoration: const InputDecoration(
          labelText: 'Cargando sucursales...',
          prefixIcon: Icon(Icons.business_outlined),
        ),
        items: const [],
        onChanged: null,
      ),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Future<void> _handleContinue(UserModel user) async {
    if (selectedSucursal == null) return;

    setState(() => isLoading = true);

    try {
      final locationService = ref.read(locationServiceProvider);

      final isAuthorized = await locationService.isAuthorized(
        user.id,
        selectedSucursal!.sucursalId ?? '',
      );

      if (isAuthorized) {
        _navigateToHomeScreen(user.role);
      } else {
        await locationService.requestAuthorization(
          repositorId: user.id,
          repositorName: user.name,
          repositorEmail: user.email,
          location: selectedSucursal!,
        );

        if (mounted) _showAuthorizationRequestDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _navigateToHomeScreen(UserRole role) {
    switch (role) {
      case UserRole.repositor:
        context.go('/repositor');
        break;
      case UserRole.supervisor:
        context.go('/supervisor');
        break;
      case UserRole.admin:
        context.go('/admin');
        break;
    }
  }

  void _showAuthorizationRequestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Solicitud Enviada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 64, color: AppTheme.secondaryColor),
            const SizedBox(height: 16),
            Text(
              'Se ha enviado una solicitud de autorización para trabajar en:\n\n${selectedSucursal?.fullAddress ?? selectedSucursal?.name ?? ''}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Un supervisor debe aprobar tu solicitud antes de que puedas comenzar a trabajar.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                selectedProvincia = null;
                selectedLocalidad = null;
                selectedCadena = null;
                selectedSucursal = null;
              });
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.repositor:
        return 'Repositor';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.admin:
        return 'Administrador';
    }
  }
}
