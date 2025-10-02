import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/analytics_card.dart';
import 'users_management_screen.dart';
import 'locations_management_screen.dart';
import 'tasks_management_screen.dart';
import 'reports_screen.dart';
import '../../../core/models/user_model.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _selectedIndex = 0;

  void _changeTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (UserModel? user) {
        if (user == null) return const SizedBox.shrink();

        return Scaffold(
          appBar: AppBar(
            title: const Text('RepoCheck - Administrador'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(analyticsProvider);
                  ref.invalidate(allUsersProvider);
                  ref.invalidate(allLocationsProvider);
                  ref.invalidate(allTasksProvider);
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final authService = ref.read(authServiceProvider);
                  await authService.signOut();
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _DashboardTab(user: user, onNavigate: _changeTab),
              const UsersManagementScreen(),
              const LocationsManagementScreen(),
              const TasksManagementScreen(),
              const ReportsScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _changeTab,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Usuarios',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on),
                label: 'Ubicaciones',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Tareas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Reportes',
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  final UserModel user;
  final void Function(int index) onNavigate;

  const _DashboardTab({required this.user, required this.onNavigate, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
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
                        const Text(
                          'Administrador del Sistema',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Analytics
          analyticsAsync.when(
            data: (analytics) => _buildAnalytics(context, analytics),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error cargando estadísticas: $error'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick actions
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _QuickActionCard(
                title: 'Gestionar Usuarios',
                icon: Icons.people,
                color: AppTheme.primaryColor,
                onTap: () => onNavigate(1),
              ),
              _QuickActionCard(
                title: 'Gestionar Ubicaciones',
                icon: Icons.location_on,
                color: AppTheme.secondaryColor,
                onTap: () => onNavigate(2),
              ),
              _QuickActionCard(
                title: 'Gestionar Tareas',
                icon: Icons.assignment,
                color: AppTheme.warningColor,
                onTap: () => onNavigate(3),
              ),
              _QuickActionCard(
                title: 'Ver Reportes',
                icon: Icons.analytics,
                color: Colors.purple,
                onTap: () => onNavigate(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics(BuildContext context, Map<String, dynamic> analytics) {
    final users = analytics['users'] as Map<String, dynamic>;
    final tasks = analytics['tasks'] as Map<String, dynamic>;
    final locations = analytics['locations'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas del Sistema',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: AnalyticsCard(
                title: 'Total Usuarios',
                value: users['total'].toString(),
                icon: Icons.people,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsCard(
                title: 'Usuarios Activos',
                value: users['active'].toString(),
                icon: Icons.person,
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnalyticsCard(
                title: 'Repositores',
                value: users['repositors'].toString(),
                icon: Icons.inventory,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsCard(
                title: 'Supervisores',
                value: users['supervisors'].toString(),
                icon: Icons.supervisor_account,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnalyticsCard(
                title: 'Total Tareas',
                value: tasks['total'].toString(),
                icon: Icons.assignment,
                color: AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsCard(
                title: 'Pendientes',
                value: tasks['pending'].toString(),
                icon: Icons.pending_actions,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnalyticsCard(
                title: 'Aprobadas',
                value: tasks['approved'].toString(),
                icon: Icons.check_circle,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsCard(
                title: 'Ubicaciones',
                value: locations['total'].toString(),
                icon: Icons.location_city,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
