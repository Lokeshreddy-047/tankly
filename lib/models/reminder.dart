class Reminder {
  final int? id;
  final String title; // e.g., "Insurance Renewal" or "Chain Lube"
  final String type; // 'Date' or 'Odometer'
  final String? dueDate; // For date-based reminders
  final double? dueOdometer; // For mileage-based reminders

  Reminder({
    this.id,
    required this.title,
    required this.type,
    this.dueDate,
    this.dueOdometer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'dueDate': dueDate,
      'dueOdometer': dueOdometer,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      type: map['type'],
      dueDate: map['dueDate'],
      dueOdometer: map['dueOdometer'],
    );
  }
}