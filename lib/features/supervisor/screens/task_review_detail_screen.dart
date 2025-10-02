import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/task_model.dart';
import '../../../core/services/task_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TaskReviewDetailScreen extends ConsumerStatefulWidget {
  final TaskModel task;
  
  const TaskReviewDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskReviewDetailScreen> createState() => _TaskReviewDetailScreenState();
}

class _TaskReviewDetailScreenState extends ConsumerState<TaskReviewDetailScreen> {
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar Tarea'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.task.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _StatusChip(status: widget.task.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Task details
                    _DetailRow(
                      label: 'Creada:',
                      value: DateFormat('dd/MM/yyyy HH:mm').format(widget.task.createdAt),
                    ),
                    if (widget.task.completedAt != null) ...[
                      const SizedBox(height: 8),
                      _DetailRow(
                        label: 'Completada:',
                        value: DateFormat('dd/MM/yyyy HH:mm').format(widget.task.completedAt!),
                      ),
                    ],
                    if (widget.task.repositorId != null) ...[
                      const SizedBox(height: 8),
                      _DetailRow(
                        label: 'Repositor:',
                        value: widget.task.repositorId!, // Would show actual name
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Task completion data (if completed)
            if (widget.task.status == TaskStatus.completed || 
                widget.task.status == TaskStatus.approved || 
                widget.task.status == TaskStatus.rejected) ...[
              
              // Completion details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Datos de Reposición',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (widget.task.cantidadRepuesta != null) ...[
                        _DetailRow(
                          label: 'Cantidad repuesta:',
                          value: widget.task.cantidadRepuesta.toString(),
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      if (widget.task.observaciones != null) ...[
                        _DetailRow(
                          label: 'Observaciones:',
                          value: widget.task.observaciones!,
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      if (widget.task.latitude != null && widget.task.longitude != null) ...[
                        _DetailRow(
                          label: 'Ubicación GPS:',
                          value: '${widget.task.latitude!.toStringAsFixed(6)}, ${widget.task.longitude!.toStringAsFixed(6)}',
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showLocationOnMap(),
                          icon: const Icon(Icons.map),
                          label: const Text('Ver en mapa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Photos
              if (widget.task.fotoAntes != null || widget.task.fotoDespues != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Evidencia Fotográfica',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            if (widget.task.fotoAntes != null) ...[
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Antes',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _showFullScreenImage(widget.task.fotoAntes!),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          widget.task.fotoAntes!,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 150,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.error),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            
                            if (widget.task.fotoDespues != null) ...[
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Después',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _showFullScreenImage(widget.task.fotoDespues!),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          widget.task.fotoDespues!,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 150,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.error),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Supervisor comment (if exists)
              if (widget.task.supervisorComment != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comentario del Supervisor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.task.supervisorComment!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Review actions (if task is completed and needs review)
              if (widget.task.status == TaskStatus.completed) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Revisar Tarea',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Comment field
                        TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            labelText: 'Comentario (opcional)',
                            hintText: 'Agrega un comentario sobre la tarea...',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : () => _reviewTask(TaskStatus.rejected),
                                icon: const Icon(Icons.close),
                                label: const Text('Rechazar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.errorColor,
                                  side: const BorderSide(color: AppTheme.errorColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : () => _reviewTask(TaskStatus.approved),
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
                                label: const Text('Aprobar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _reviewTask(TaskStatus status) async {
    setState(() => _isLoading = true);

    try {
      final taskService = ref.read(taskServiceProvider);
      await taskService.reviewTask(
        taskId: widget.task.id,
        status: status,
        supervisorComment: _commentController.text.isEmpty ? null : _commentController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == TaskStatus.approved ? 'Tarea aprobada' : 'Tarea rechazada'
            ),
            backgroundColor: status == TaskStatus.approved 
                ? AppTheme.secondaryColor 
                : AppTheme.errorColor,
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

  void _showLocationOnMap() {
    // This would open a map view with the GPS coordinates
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de mapa no implementada aún')),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 64,
                  );
                },
              ),
            ),
          ),
        ),
      ),
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
        text = 'Para revisar';
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
