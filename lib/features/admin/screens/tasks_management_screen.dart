import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/models/task_model.dart';
import '../../../core/models/location_model.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TasksManagementScreen extends ConsumerStatefulWidget {
  const TasksManagementScreen({super.key});

  @override
  ConsumerState<TasksManagementScreen> createState() => _TasksManagementScreenState();
}

class _TasksManagementScreenState extends ConsumerState<TasksManagementScreen> {
  String _searchQuery = '';
  TaskStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(allTasksProvider);

    return Column(
      children: [
        // Barra de búsqueda y filtros
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar tareas...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: () => _showAddTaskDialog(context),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _filterStatus == null,
                      onSelected: (_) => setState(() => _filterStatus = null),
                    ),
                    const SizedBox(width: 8),
                    ...TaskStatus.values.map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getStatusText(status)),
                          selected: _filterStatus == status,
                          onSelected: (_) => setState(() => _filterStatus = status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de tareas
        Expanded(
          child: tasksAsync.when(
            data: (tasks) {
              final filteredTasks = tasks.where((task) {
                final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    task.description.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchesStatus = _filterStatus == null || task.status == _filterStatus;
                return matchesSearch && matchesStatus;
              }).toList();

              if (filteredTasks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No se encontraron tareas',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) => _TaskCard(task: filteredTasks[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendientes';
      case TaskStatus.inProgress:
        return 'En Progreso';
      case TaskStatus.completed:
        return 'Completadas';
      case TaskStatus.approved:
        return 'Aprobadas';
      case TaskStatus.rejected:
        return 'Rechazadas';
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const _AddTaskDialog());
  }

  void _showEditTaskDialog(BuildContext context, TaskModel task) {
    showDialog(context: context, builder: (context) => _EditTaskDialog(task: task));
  }
}

class _TaskCard extends ConsumerWidget {
  final TaskModel task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                _StatusChip(status: task.status),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Editar')]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [Icon(Icons.delete, color: AppTheme.errorColor), SizedBox(width: 8), Text('Eliminar')],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      showDialog(context: context, builder: (_) => _EditTaskDialog(task: task));
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, ref, task);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Creada: ${DateFormat('dd/MM/yyyy HH:mm').format(task.createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                if (task.sucursalId.isNotEmpty) ...[
                  Icon(Icons.store, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('Asignada', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: Text('¿Estás seguro de que quieres eliminar "${task.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                final adminService = ref.read(adminServiceProvider);
                await adminService.deleteTask(task.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea eliminada')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String text;
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
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

// ---------- Add Task Dialog ----------
class _AddTaskDialog extends ConsumerStatefulWidget {
  const _AddTaskDialog();

  @override
  ConsumerState<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<_AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedSucursalId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(allLocationsProvider);

    return AlertDialog(
      title: const Text('Crear Tarea'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
              validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            locationsAsync.when(
              data: (locations) => DropdownButtonFormField<String>(
                value: _selectedSucursalId,
                decoration: const InputDecoration(labelText: 'Sucursal'),
                items: locations.map((location) {
                  return DropdownMenuItem(
                    value: location.sucursalId,
                    child: Text(
                      '${location.provincia} - ${location.localidad} - ${location.cadena} - ${location.sucursal}',
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSucursalId = value),
                validator: (v) => v == null ? 'Campo requerido' : null,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _isLoading ? null : _createTask,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Crear'),
        ),
      ],
    );
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final adminService = ref.read(adminServiceProvider);
      await adminService.createTask(
        title: _titleController.text,
        description: _descriptionController.text,
        sucursalId: _selectedSucursalId!,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea creada exitosamente')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ---------- Edit Task Dialog ----------
class _EditTaskDialog extends ConsumerStatefulWidget {
  final TaskModel task;
  const _EditTaskDialog({required this.task});

  @override
  ConsumerState<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends ConsumerState<_EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _selectedSucursalId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedSucursalId = widget.task.sucursalId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(allLocationsProvider);

    return AlertDialog(
      title: const Text('Editar Tarea'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
              validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            locationsAsync.when(
              data: (locations) => DropdownButtonFormField<String>(
                value: _selectedSucursalId,
                decoration: const InputDecoration(labelText: 'Sucursal'),
                items: locations.map((location) {
                  return DropdownMenuItem(
                    value: location.sucursalId,
                    child: Text(
                      '${location.provincia} - ${location.localidad} - ${location.cadena} - ${location.sucursal}',
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedSucursalId = v),
                validator: (v) => v == null ? 'Campo requerido' : null,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateTask,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Actualizar'),
        ),
      ],
    );
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final adminService = ref.read(adminServiceProvider);
      await adminService.updateTask(
        taskId: widget.task.id,
        title: _titleController.text,
        description: _descriptionController.text,
        sucursalId: _selectedSucursalId!,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea actualizada exitosamente')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
