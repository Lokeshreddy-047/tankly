class MaintenanceLog {
  final int? id;
  final String serviceType; // e.g., Oil Change, Chain Lube, General Service
  final double odometer;
  final double cost;
  final String date;
  final String notes;

  MaintenanceLog({
    this.id,
    required this.serviceType,
    required this.odometer,
    required this.cost,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceType': serviceType,
      'odometer': odometer,
      'cost': cost,
      'date': date,
      'notes': notes,
    };
  }

  factory MaintenanceLog.fromMap(Map<String, dynamic> map) {
    return MaintenanceLog(
      id: map['id'],
      serviceType: map['serviceType'],
      odometer: map['odometer'],
      cost: map['cost'],
      date: map['date'],
      notes: map['notes'],
    );
  }
}
