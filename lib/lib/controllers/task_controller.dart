import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_nodejs/models/task_model.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class TaskController extends GetxController {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final selectedTaskId = Rxn<String>();
  final selectedDate = Rxn<DateTime>();
  final selectedCategory = 'Personal'.obs;
  final categories = ['Personal', 'Work', 'Urgent'];
  final searchText = ''.obs;
  final filteredTasks = <Task>[].obs;
  final Connectivity _connectivity = Connectivity();
  late final Stream<ConnectivityResult> _connectivityStream;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        fetchTasks(); // Auto-fetch when network comes back
      }
    });
  }

  void initialize({String? title, DateTime? dueDate, String? category}) {
    titleController.text = title ?? '';
    selectedDate.value = dueDate;
    selectedCategory.value = category ?? 'Personal';
  }

  void toggleExpandedTask(String taskId) {
    if (selectedTaskId.value == taskId) {
      selectedTaskId.value = null;
    } else {
      selectedTaskId.value = taskId;
    }
  }

  void filterTasks(String query) {
    searchText.value = query;

    if (query.isEmpty) {
      filteredTasks.assignAll(tasks);
    } else {
      filteredTasks.assignAll(
        tasks.where((task) =>
            task.title.toLowerCase().contains(query.toLowerCase()) ||
            task.message.toLowerCase().contains(query.toLowerCase())),
      );
    }
  }

  Future<void> pickDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate.value ?? DateTime.now()),
    );
    if (time == null) return;

    selectedDate.value =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void clearController() {
    titleController.clear();
    messageController.clear();
  }

  // Todo ---------------------------------- Crud Operation  ----------------------------------

  final Dio _dio = Dio(
    BaseOptions(
        baseUrl: 'https://todo-node-kybc.onrender.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'}),
  );

  RxBool isAddLoading = false.obs;
  RxBool isFetchLoading = false.obs;
  RxBool isDeleteLoading = false.obs;

  // todo: Add Task
  Future<Task?> addTask(Task task) async {

    try {
      isAddLoading.value = true;
      final response = await _dio.post('/add', data: {
        'title': task.title,
        'message': task.message,
        'category': task.category,
        'dueDate': task.dueDate?.toIso8601String(),
      });

      if (response.statusCode == 201) {
        final newTask = Task.fromJson(response.data['task']);

        fetchTasks();
        Get.back();
        clearController();
        return newTask;
      } else {
        Get.snackbar('Error', response.statusCode.toString());
        return null;
      }
    } catch (e) {
      Get.snackbar('Exception', 'Something went wrong');
      print('Add Task Error: $e');
      return null;
    } finally {
      isAddLoading.value = false;
    }
  }

  // todo: Delete Task
  Future<void> deleteTask(String id) async {
    try {
      isAddLoading.value = true;
      final response = await _dio.delete('/delete/$id');

      if (response.statusCode == 200) {
        tasks.removeWhere((t) => t.id == id);
        Get.snackbar('Success', response.data['message']);
      } else {
        Get.snackbar('Error', response.statusCode.toString());
      }
    } catch (e) {
      Get.snackbar('Exception', 'Something went wrong');
      print('Delete Task Error: $e');
    } finally {
      isAddLoading.value = false;
    }
  }

//   TOdo: Fetch Task
  final tasks = <Task>[].obs;

  Future<void> fetchTasks() async {
    try {
      isFetchLoading.value = true;

      final response = await _dio.get('/fetch');

      if (response.statusCode == 200) {
        print('fetch task call');
        final data = (response.data as List)
            .map((json) => Task.fromJson(json as Map<String, dynamic>))
            .toList();
        tasks.assignAll(data);
        filterTasks(searchText.value);
      } else {
        Get.snackbar('Error', 'Failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Data fetched Exception : $e');
    } finally {
      isFetchLoading.value = false;
    }
  }

  // Todo: Edit task

  final isEditLoading = false.obs;

  Future<Task?> editTask(Task task, String id) async {
    try {
      isEditLoading.value = true;

      final response = await _dio.patch('/edit/$id', data: {
        'title': task.title,
        'message': task.message,
        'category': task.category,
        'dueDate': task.dueDate?.toIso8601String(),
      });

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Task Edited.');
        fetchTasks();
        Get.back();
        return Task.fromJson(response.data);
      } else {
        Get.snackbar('Error', 'Something went wrong');
        Get.back();
        print('******** ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Edit Task Exception: $e');
      return null;
    } finally {
      isEditLoading.value = false;
    }
  }

//   Todo: is Task completed...
  Future<void> isTaskComplete(Task task) async {
    try {
      final response = await _dio.patch('/toggle/${task.id}', data: {
        'isDone': !task.isDone,
      });

      if (response.statusCode == 200) {
        Get.back();
        clearController();
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          final updatedTask = Task(
            id: task.id,
            title: task.title,
            message: task.message,
            category: task.category,
            dueDate: task.dueDate,
            isDone: !task.isDone,
          );
          tasks[index] = updatedTask;
          tasks.refresh();

          // Refresh filteredTasks as well
          filterTasks(searchText.value);
        }
      } else {
        Get.snackbar('Error', 'Failed to update data.');
      }
    } catch (e) {
      print('isTaskComplete Exception: $e');
    }
  }
}
