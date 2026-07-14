import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'add_fuel_screen.dart';
import '../models/fuel_log.dart';
import '../services/database_helper.dart';
import '../utils/stats_helper.dart'; // Import the new math engine
import 'charts_screen.dart';
import 'maintenance_screen.dart';
import 'reminders_screen.dart';
import '../widgets/empty_state.dart';
import '../main.dart'; // Gives us access to themeNotifier
import 'bike_profile_screen.dart';
import '../widgets/empty_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<FuelLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  Future<void> _refreshLogs() async {
    final data = await DatabaseHelper.instance.getAllLogs();
    setState(() {
      _logs = data;
      _isLoading = false;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    // Calculate live stats
    final totalSpent = StatsHelper.getTotalExpense(_logs);
    final avgMileage = StatsHelper.getAverageMileage(_logs);
    final totalDistance = StatsHelper.getTotalDistance(_logs);
    final totalLitres = StatsHelper.getTotalLitres(_logs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tankly'),
        actions: [
          IconButton(
            icon: const Icon(Icons.two_wheeler),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BikeProfileScreen()),
              );
            },
          ),

          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, currentMode, __) {
              IconData icon = currentMode == ThemeMode.light
                  ? Icons.dark_mode
                  : (currentMode == ThemeMode.dark ? Icons.brightness_auto : Icons.light_mode);

              return IconButton(
                icon: Icon(icon),
                onPressed: () {
                  if (currentMode == ThemeMode.system) themeNotifier.value = ThemeMode.dark;
                  else if (currentMode == ThemeMode.dark) themeNotifier.value = ThemeMode.light;
                  else themeNotifier.value = ThemeMode.system;
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // --- THE NEW PREMIUM STATS CARD ---
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withBlue(80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bike Name & Icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.two_wheeler, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Yezdi Roadster',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 4-Grid Stats Layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Total Fuel', '${totalLitres.toStringAsFixed(1)} L', Icons.water_drop),
                    _buildStatItem('Distance', '${totalDistance.toStringAsFixed(0)} km', Icons.route),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Avg Mileage', '${avgMileage.toStringAsFixed(1)} km/L', Icons.speed),
                    _buildStatItem('Total Spent', '₹${totalSpent.toStringAsFixed(0)}', Icons.currency_rupee),
                  ],
                ),
              ],
            ),
          ),

          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                    'Recent Fill-ups',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary
                    )
                ),
              ],
            ),
          ),

          // --- THE ANIMATED LIST ---
          Expanded(
            child: _logs.isEmpty
                ? const EmptyState(
              icon: Icons.local_gas_station_outlined,
              title: 'No Fill-ups Yet',
              message: 'Hit the plus button below to log your first petrol expense and start tracking your mileage.',
            ) // We'll upgrade this to the EmptyState widget next
                : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];

                return Dismissible(
                  key: Key(log.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    await DatabaseHelper.instance.deleteFuelLog(log.id!);
                    _refreshLogs();
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                              log.isFullTank ? Icons.local_gas_station : Icons.ev_station,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24
                          ),
                        ),
                        title: Text(
                            log.litres != null
                                ? '${log.litres} L  •  ₹${log.totalAmount.toStringAsFixed(0)}'
                                : 'Quick Log  •  ₹${log.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                              log.odometer != null
                                  ? 'Odo: ${log.odometer} km ${log.isFullTank ? "(Full)" : "(Partial)"}'
                                  : 'No odometer recorded'
                          ),
                        ),
                        trailing: Text(
                          log.date.substring(0, 10),
                          style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ).animate().fade(duration: 400.ms, delay: (index * 50).ms)
                      .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOutQuad),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFuelScreen()),
          );
          if (result == true) _refreshLogs();
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper widget for the grid items inside the stats card
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}