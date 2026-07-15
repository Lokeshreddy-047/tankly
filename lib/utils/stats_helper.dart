import '../models/fuel_log.dart';

class StatsHelper {
  static double getTotalExpense(List<FuelLog> logs) {
    return logs.fold(0, (sum, log) => sum + log.totalAmount);
  }

  static double getTotalLitres(List<FuelLog> logs) {
    return logs.where((l) => l.litres != null).fold(0, (sum, log) => sum + log.litres!);
  }

  static double getTotalDistance(List<FuelLog> logs) {
    final validLogs = logs.where((l) => l.odometer != null).toList();
    if (validLogs.length < 2) return 0.0;

    validLogs.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    return validLogs.last.odometer! - validLogs.first.odometer!;
  }

  static double getAverageMileage(List<FuelLog> logs) {
    if (logs.length < 2) return 0.0;

    var sortedLogs = List<FuelLog>.from(logs);
    sortedLogs.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

    int firstFullIndex = sortedLogs.indexWhere((log) => log.isFullTank && log.odometer != null);
    if (firstFullIndex == -1) return 0.0;

    int lastFullIndex = sortedLogs.lastIndexWhere((log) => log.isFullTank && log.odometer != null);
    if (lastFullIndex <= firstFullIndex) return 0.0;

    double startOdo = sortedLogs[firstFullIndex].odometer!;
    double endOdo = sortedLogs[lastFullIndex].odometer!;
    double totalDistance = endOdo - startOdo;

    double totalLitresUsed = 0.0;
    for (int i = firstFullIndex + 1; i <= lastFullIndex; i++) {
      if (sortedLogs[i].litres != null) {
        totalLitresUsed += sortedLogs[i].litres!;
      }
    }

    if (totalLitresUsed == 0) return 0.0;
    return totalDistance / totalLitresUsed;
  }
}