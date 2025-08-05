class Task {
  String id;
  String title;
  String message;
  bool isDone;
  DateTime? dueDate;
  String category;

  Task({
    required this.id,
    required this.title,
    required this.message,
    this.isDone = false,
    this.dueDate,
    this.category = 'Personal',
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isDone: json['isDone'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      category: json['category'] ?? 'Personal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id':id,
      'title': title,
      'message': message,
      'isDone': isDone,
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
    };
  }
}
