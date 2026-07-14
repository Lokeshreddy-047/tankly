import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/fuel_log.dart';
import '../services/database_helper.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  List<FuelLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getAllLogs();
    setState(() {
      // Reverse the list so it's chronological (oldest to newest) for left-to-right graphs
      _logs = data.reversed.toList();
      _isLoading = false;
    });
  }

  List<FlSpot> _getMileageSpots() {
    List<FlSpot> spots = [];

    // Filter out Quick Logs: Only keep logs that have odometer and litres data
    final validLogs = _logs.where((l) => l.odometer != null && l.litres != null).toList();

    for (int i = 1; i < validLogs.length; i++) {
      // The '!' tells Dart we guarantee these aren't null because of our filter above
      double distance = validLogs[i].odometer! - validLogs[i - 1].odometer!;
      double mileage = distance / validLogs[i].litres!;

      // Cap unrealistic mileage (e.g., from typos) for chart scaling
      if (mileage > 0 && mileage < 100) {
        spots.add(FlSpot(i.toDouble(), double.parse(mileage.toStringAsFixed(1))));
      }
    }
    return spots.isEmpty ? [const FlSpot(0, 0)] : spots;
  }

  List<FlSpot> _getPriceSpots() {
    List<FlSpot> spots = [];

    // Filter out Quick Logs: Only keep logs that have price data
    final validLogs = _logs.where((l) => l.pricePerLitre != null).toList();

    for (int i = 0; i < validLogs.length; i++) {
      spots.add(FlSpot(i.toDouble(), validLogs[i].pricePerLitre!));
    }
    return spots.isEmpty ? [const FlSpot(0, 0)] : spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.length < 2
          ? const Center(child: Text('Need at least 2 logs to show charts.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mileage Trend (km/l)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _buildLineChart(_getMileageSpots(), Colors.green),
            ),
            const SizedBox(height: 40),
            const Text('Petrol Price Trend (₹)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _buildLineChart(_getPriceSpots(), Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> spots, Color lineColor) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide bottom numbers to keep it clean
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}