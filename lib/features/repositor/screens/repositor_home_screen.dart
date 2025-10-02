import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/task_service.dart';
import '../../../core/models/task_model.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

class RepositorHomeScreen extends ConsumerStatefulWidget {
  const RepositorHomeScreen({super.key});

  @override
  ConsumerState<RepositorHomeScreen> createState() => _RepositorHomeScreenState();
}

class _RepositorHomeScreenState extends ConsumerState<RepositorHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    
    return currentUserAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('RepoCheck - Repositor'),
            actions: [
              IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () => context.go('/location-selection'),
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
              _TasksTab(userId: user.id),
              _HistoryTab(userId: user.id),
              _ProfileTab(user: user),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Tareas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Historial',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
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

class _TasksTab extends ConsumerWidget {
  final String userId;
  
  const _TasksTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksForRepositorProvider(userId));
    
    return tasksAsync.when(
      data: (tasks) {
        final pendingTasks = tasks.where((task) => 
          task.status == TaskStatus.pending || 
          task.status == TaskStatus.inProgress
        ).toList();
        
        if (pendingTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay tareas pendientes',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Create sample tasks for testing
                    final taskService = ref.read(taskServiceProvider);
                    // You would need to get the current sucursal ID here
                    // taskService.createSampleTasks(sucursalId);
                  },
                  child: const Text('Cargar tareas de ejemplo'),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingTasks.length,
          itemBuilder: (context, index) {
            final task = pendingTasks[index];
            return TaskCard(
              task: task,
              onTap: () => _navigateToTaskDetail(context, task),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  void _navigateToTaskDetail(BuildContext context, TaskModel task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  final String userId;
  
  const _HistoryTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksForRepositorProvider(userId));
    
    return tasksAsync.when(
      data: (tasks) {
        final completedTasks = tasks.where((task) => 
          task.status == TaskStatus.completed ||
          task.status == TaskStatus.approved ||
          task.status == TaskStatus.rejected
        ).toList();
        
        if (completedTasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No hay tareas completadas',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedTasks.length,
          itemBuilder: (context, index) {
            final task = completedTasks[index];
            return TaskCard(
              task: task,
              onTap: () => _showTaskDetails(context, task),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  void _showTaskDetails(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Task title and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _StatusChip(status: task.status),
                  ],
                ),
                const SizedBox(height: 8),
                
                Text(
                  task.description,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                // Task details
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.cantidadRepuesta != null) ...[
                          _DetailRow(
                            label: 'Cantidad repuesta:',
                            value: task.cantidadRepuesta.toString(),
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        if (task.observaciones != null) ...[
                          _DetailRow(
                            label: 'Observaciones:',
                            value: task.observaciones!,
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        if (task.supervisorComment != null) ...[
                          _DetailRow(
                            label: 'Comentario del supervisor:',
                            value: task.supervisorComment!,
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        if (task.completedAt != null) ...[
                          _DetailRow(
                            label: 'Completado:',
                            value: task.completedAt!.toString(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Photos
                        if (task.fotoAntes != null || task.fotoDespues != null) ...[
                          const Text(
                            'Fotos:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              if (task.fotoAntes != null) ...[
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Antes'),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          task.fotoAntes!,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              
                              if (task.fotoDespues != null) ...[
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Después'),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          task.fotoDespues!,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  final user;
  
  const _ProfileTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Repositor',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
          
          // Menu options
          _MenuOption(
            icon: Icons.location_on,
            title: 'Cambiar ubicación',
            onTap: () => context.go('/location-selection'),
          ),
          _MenuOption(
            icon: Icons.help_outline,
            title: 'Ayuda',
            onTap: () => _showHelpDialog(context),
          ),
          _MenuOption(
            icon: Icons.info_outline,
            title: 'Acerca de',
            onTap: () => _showAboutDialog(context),
          ),
          const Spacer(),
          
          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final authService = ref.read(authServiceProvider);
                await authService.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const Text(
          'Para usar RepoCheck:\n\n'
          '1. Selecciona tu ubicación de trabajo\n'
          '2. Espera la autorización del supervisor\n'
          '3. Completa las tareas asignadas\n'
          '4. Toma fotos antes y después\n'
          '5. Registra la cantidad repuesta\n\n'
          'Si tienes problemas, contacta a tu supervisor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'RepoCheck',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.inventory_2_outlined,
        size: 48,
        color: AppTheme.primaryColor,
      ),
      children: const [
        Text('Control de reposición tercerizada'),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;
  
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    
    switch (status) {
      case TaskStatus.pending:
        color = AppTheme.warningColor;
        text = 'Pendiente';
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        text = 'En progreso';
        break;
      case TaskStatus.completed:
        color = Colors.orange;
        text = 'Completada';
        break;
      case TaskStatus.approved:
        color = AppTheme.secondaryColor;
        text = 'Aprobada';
        break;
      case TaskStatus.rejected:
        color = AppTheme.errorColor;
        text = 'Rechazada';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  
  const _MenuOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
