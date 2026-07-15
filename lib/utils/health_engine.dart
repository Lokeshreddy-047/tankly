import '../models/fuel_log.dart';
import '../models/maintenance_log.dart';
import '../models/reminder.dart';
import 'stats_helper.dart';

class HealthEngine {
  static Map<String, dynamic> calculateHealth({
    required List<FuelLog> fuelLogs,
    required List<MaintenanceLog> maintLogs,
    required List<Reminder> reminders,
  }) {
    int score = 100;
    List<String> warnings = [];

    // --- 1. Fuel Efficiency Check ---
    // The Yezdi Roadster should average around 28-32 km/L.
    double avgMileage = StatsHelper.getAverageMileage(fuelLogs);
    if (avgMileage > 0) {
      if (avgMileage < 25) {
        score -= 15;
        warnings.add('Low fuel efficiency (Check tyre pressure or engine)');
      } else if (avgMileage < 28) {
        score -= 5;
      }
    }

    // --- 2. Maintenance Check ---
    // Find the latest odometer reading
    double currentOdo = 0;
    if (fuelLogs.isNotEmpty && fuelLogs.last.odometer != null) {
      currentOdo = fuelLogs.last.odometer!;
    }

    // Find the last Oil Change or General Service
    final criticalServices = maintLogs.where((log) =>
    log.serviceType == 'Oil Change' || log.serviceType == 'General Service'
    ).toList();

    if (criticalServices.isNotEmpty && currentOdo > 0) {
      criticalServices.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
      double lastServiceOdo = criticalServices.last.odometer;

      // If it's been more than 3500km since the last oil change
      if ((currentOdo - lastServiceOdo) > 3500) {
        score -= 20;
        warnings.add('Overdue for an Oil Change');
      }
    } else if (currentOdo > 3500) {
      // If they've driven a lot but never logged a service
      score -= 10;
      warnings.add('No recent service records found');
    }

    // --- 3. Overdue Reminders Check ---
    final now = DateTime.now();
    for (var reminder in reminders) {
      if (reminder.type == 'Date' && reminder.dueDate != null) {
        final dueDate = DateTime.parse(reminder.dueDate!);
        if (now.isAfter(dueDate)) {
          score -= 10;
          warnings.add('${reminder.title} is overdue');
        }
      } else if (reminder.type == 'Odometer' && reminder.dueOdometer != null && currentOdo > 0) {
        if (currentOdo >= reminder.dueOdometer!) {
          score -= 10;
          warnings.add('${reminder.title} mileage reached');
        }
      }
    }

    // Floor the score at 0
    if (score < 0) score = 0;

    // Determine Status
    String status = 'Excellent';
    if (score < 70) status = 'Needs Attention';
    if (score < 40) status = 'Critical';

    return {
      'score': score,
      'status': status,
      'warnings': warnings,
    };
  }
}