import 'package:flutter/material.dart';
import '../../../core/models/task_model.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TaskReviewCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  
  const TaskReviewCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusChip(status: task.status),
                ],
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                task.description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Repositor info (if assigned)
              if (task.repositorId != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Repositor: ${task.repositorId}', // Would show actual name
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Footer with date and action
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(task.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  
                  // Action indicator based on status
                  if (task.status == TaskStatus.completed) ...[
                    const Icon(
                      Icons.rate_review,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Revisar',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ] else if (task.status == TaskStatus.approved) ...[
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.secondaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Aprobada',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ] else if (task.status == TaskStatus.rejected) ...[
                    const Icon(
                      Icons.cancel,
                      color: AppTheme.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Rechazada',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
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
