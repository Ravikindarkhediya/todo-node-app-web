import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_nodejs/lib/controllers/task_controller.dart';
import '../../models/task_model.dart';

class AddEditTaskDialog extends StatelessWidget {
  final Task? task;
  final _formKey = GlobalKey<FormState>();

  AddEditTaskDialog({super.key, this.task}) {
    final controller = Get.put(TaskController());
    controller.initialize(
      title: task?.title,
      dueDate: task?.dueDate,
      category: task?.category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskController>();

    return AlertDialog(
      content: Hero(
        tag: 'add-task-hero',
        child: Material(
          type: MaterialType.transparency,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task == null ? 'Add New Task' : 'Edit Task',
                    style: Get.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: controller.titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        value!.trim().isEmpty ? 'Title cannot be empty' : null,
                  ),
                  TextFormField(
                    controller: controller.messageController,
                    decoration: const InputDecoration(labelText: 'Message'),
                    validator: (value) => value!.trim().isEmpty
                        ? 'Message cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Obx(() => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: Text(
                          controller.selectedDate.value == null
                              ? 'No due date'
                              : DateFormat('MMM d, yyyy HH:mm')
                                  .format(controller.selectedDate.value!),
                        ),
                        trailing: TextButton(
                          onPressed: () => controller.pickDateTime(context),
                          child: const Text('PICK'),
                        ),
                      )),
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedCategory.value,
                        items: controller.categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (newValue) =>
                            controller.selectedCategory.value = newValue!,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                          border: InputBorder.none,
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Get.back();
            Get.delete<TaskController>();
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final newTask = Task(
                id: '',
                title: controller.titleController.text.trim(),
                message: controller.messageController.text.trim(),
                dueDate: controller.selectedDate.value,
                category: controller.selectedCategory.value,
              );

              if (task == null) {
                // ADD TASK
                final addedTask = await controller.addTask(newTask);
                if (addedTask != null) {
                  Get.snackbar('Success', 'Task added successfully');
                  // Get.back();
                }
              } else {
                // EDIT TASK
                final editedTask = await controller.editTask(newTask, task!.id);
                if (editedTask != null) {
                  Get.snackbar('Success', 'Task updated successfully');
                  // Get.back();
                }
              }
              // Get.back();
            }
          },
          child: Text(task == null ? 'ADD' : 'SAVE'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
