// lib/views/widgets/task_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_nodejs/lib/controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import 'add_edit_task_dialog.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return AppColors.work;
      case 'Personal':
        return AppColors.personal;
      case 'Urgent':
        return AppColors.urgent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              showDialog(
                context: context,
                builder: (_) => AddEditTaskDialog(task: task),
              );
            },
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        dismissible: DismissiblePane(
          onDismissed: () async {
            final controller = Get.find<TaskController>();

            // 1. Immediately remove from local list to avoid build errors
            controller.tasks.removeWhere((t) => t.id == task.id);
            controller.filteredTasks.removeWhere((t) => t.id == task.id);
            await controller.deleteTask(task.id);
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context) async {
              final controller = Get.find<TaskController>();
              controller.tasks.removeWhere((t) => t.id == task.id);
              controller.filteredTasks.removeWhere((t) => t.id == task.id);
              await controller.deleteTask(task.id);
            },

            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.find<TaskController>().toggleExpandedTask(task.id);
                  },
                  child: Obx(() {
                    final isExpanded =
                        Get.find<TaskController>().selectedTaskId.value ==
                            task.id;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: task.isDone,
                                  onChanged: (_) => Get.find<TaskController>()
                                      .isTaskComplete(task),
                                  activeColor: _getCategoryColor(task.category),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: task.isDone
                                        ? Colors.grey
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Chip(
                                  label: Text(task.category),
                                  backgroundColor:
                                      _getCategoryColor(task.category)
                                          .withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: _getCategoryColor(task.category),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            Text(task.message, style: TextStyle(fontSize: 14)),
                            if (task.dueDate != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM d, yyyy HH:mm')
                                        .format(task.dueDate!),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ]
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
