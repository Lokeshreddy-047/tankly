import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'maintenance_screen.dart';
import 'charts_screen.dart';
import 'reminders_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The screens we will navigate between
  final List<Widget> _screens = [
    const DashboardScreen(),
    const MaintenanceScreen(),
    const ChartsScreen(),
    const RemindersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the selected screen
      // Wrap the navigation bar in a padded container to make it float
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: NavigationBar(
              height: 60,
              elevation: 0, // Remove default elevation, we use our own shadow
              backgroundColor: Colors.transparent, // Let the container color show
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Cleaner look without text
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.local_gas_station_outlined, color: Colors.grey.shade500),
                  selectedIcon: Icon(Icons.local_gas_station, color: Theme.of(context).colorScheme.primary),
                  label: 'Fuel',
                ),
                NavigationDestination(
                  icon: Icon(Icons.build_outlined, color: Colors.grey.shade500),
                  selectedIcon: Icon(Icons.build, color: Theme.of(context).colorScheme.primary),
                  label: 'Service',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined, color: Colors.grey.shade500),
                  selectedIcon: Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.primary),
                  label: 'Stats',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade500),
                  selectedIcon: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
                  label: 'Alerts',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}