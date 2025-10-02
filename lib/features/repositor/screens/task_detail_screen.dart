import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Adding dart:io import for File type
import '../../../core/models/task_model.dart';
import '../../../core/services/task_service.dart';
import '../../../core/theme/app_theme.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final TaskModel task;
  
  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  File? _fotoAntes;
  File? _fotoDespues;
  bool _isLoading = false;
  bool _taskStarted = false;

  @override
  void initState() {
    super.initState();
    _taskStarted = widget.task.status == TaskStatus.inProgress;
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Task info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.task.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Start task button (if not started)
              if (!_taskStarted) ...[
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _startTask,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Tarea'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Task completion form (if started)
              if (_taskStarted) ...[
                // Photo antes
                _PhotoSection(
                  title: 'Foto Antes',
                  subtitle: 'Toma una foto del estado inicial',
                  photo: _fotoAntes,
                  onTakePhoto: () => _takePhoto(isAntes: true),
                  isRequired: true,
                ),
                const SizedBox(height: 24),

                // Cantidad field
                TextFormField(
                  controller: _cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad repuesta *',
                    prefixIcon: Icon(Icons.inventory),
                    helperText: 'Ingresa la cantidad de productos repuestos',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa la cantidad repuesta';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Ingresa un número válido';
                    }
                    if (int.parse(value) < 0) {
                      return 'La cantidad no puede ser negativa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Observaciones field
                TextFormField(
                  controller: _observacionesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones (opcional)',
                    prefixIcon: Icon(Icons.note),
                    helperText: 'Agrega cualquier observación relevante',
                  ),
                ),
                const SizedBox(height: 24),

                // Photo despues
                _PhotoSection(
                  title: 'Foto Después',
                  subtitle: 'Toma una foto del resultado final',
                  photo: _fotoDespues,
                  onTakePhoto: () => _takePhoto(isAntes: false),
                  isRequired: true,
                ),
                const SizedBox(height: 32),

                // Complete task button
                ElevatedButton.icon(
                  onPressed: _canCompleteTask() && !_isLoading 
                      ? _completeTask 
                      : null,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Completar Tarea'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startTask() async {
    setState(() => _isLoading = true);

    try {
      final taskService = ref.read(taskServiceProvider);
      // You would need to get the current user ID here
      // await taskService.startTask(widget.task.id, currentUserId);
      
      setState(() => _taskStarted = true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea iniciada'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _takePhoto({required bool isAntes}) async {
    try {
      if (Platform.isWindows) {
        final XFile? photo = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (photo != null) {
          setState(() {
            if (isAntes) {
              _fotoAntes = File(photo.path);
            } else {
              _fotoDespues = File(photo.path);
            }
          });
        }
      } else {
        final XFile? photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (photo != null) {
          setState(() {
            if (isAntes) {
              _fotoAntes = File(photo.path);
            } else {
              _fotoDespues = File(photo.path);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  bool _canCompleteTask() {
    return _fotoAntes != null && 
           _fotoDespues != null && 
           _cantidadController.text.isNotEmpty;
  }

  Future<void> _completeTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canCompleteTask()) return;

    setState(() => _isLoading = true);

    try {
      final taskService = ref.read(taskServiceProvider);
      await taskService.completeTask(
        taskId: widget.task.id,
        cantidadRepuesta: int.parse(_cantidadController.text),
        observaciones: _observacionesController.text.isEmpty 
            ? null 
            : _observacionesController.text,
        fotoAntes: _fotoAntes!,
        fotoDespues: _fotoDespues!,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea completada exitosamente'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _PhotoSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final File? photo;
  final VoidCallback onTakePhoto;
  final bool isRequired;
  
  const _PhotoSection({
    required this.title,
    required this.subtitle,
    required this.photo,
    required this.onTakePhoto,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: photo != null ? AppTheme.secondaryColor : Colors.grey,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: photo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    photo!,
                    fit: BoxFit.cover,
                  ),
                )
              : InkWell(
                  onTap: onTakePhoto,
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Platform.isWindows 
                            ? 'Toca para seleccionar imagen'
                            : 'Toca para tomar foto',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        
        if (photo != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTakePhoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                Platform.isWindows 
                    ? 'Seleccionar nueva imagen'
                    : 'Tomar nueva foto'
              ),
            ),
          ),
        ],
      ],
    );
  }
}
