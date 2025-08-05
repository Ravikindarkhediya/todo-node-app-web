import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_nodejs/lib/controllers/task_controller.dart';
import 'package:todo_nodejs/views/widgets/add_edit_task_dialog.dart';
import 'package:todo_nodejs/views/widgets/task_tile.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.isFetchLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (controller.filteredTasks.isEmpty) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No Task available'),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            foregroundColor: Theme.of(context).primaryColor
                          ),
                          onPressed: () {
                            controller.fetchTasks();
                          },
                          child: const Text('Reload')
                        ),
                      ],
                    ));
                  }
                  return ListView.builder(
                    itemCount: controller.filteredTasks.length,
                    itemBuilder: (context, index) {
                      return TaskTile(task: controller.filteredTasks[index]);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-task-hero',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddEditTaskDialog(),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('My Tasks'),
      actions: [
        IconButton(
          onPressed: () {
            Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
          },
          icon: Icon(
            Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (val) => controller.filterTasks(val),
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Get.theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
