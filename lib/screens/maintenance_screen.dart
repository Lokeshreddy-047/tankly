import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/maintenance_log.dart';
import '../services/database_helper.dart';
import '../widgets/empty_state.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  List<MaintenanceLog> _logs = [];
  bool _isLoading = true;

  final List<String> _serviceTypes = ['Oil Change', 'Chain Lube', 'Brake Pads', 'General Service', 'Tyre Change'];
  String _selectedService = 'Oil Change';
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  Future<void> _refreshLogs() async {
    final data = await DatabaseHelper.instance.getAllMaintenanceLogs();
    setState(() {
      _logs = data;
      _isLoading = false;
    });
  }

  void _showAddServiceModal() {
    // Reset date when opening the modal
    _selectedDate = DateTime.now();
    _odometerController.clear();
    _costController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('Log Service', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),

                  // --- New Date Picker UI inside Modal ---
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.blueGrey,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != _selectedDate) {
                        setModalState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blueGrey),
                          const SizedBox(width: 16),
                          Text(
                            'Date: ${_selectedDate.toIso8601String().substring(0, 10)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedService,
                    items: _serviceTypes.map((String type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() { _selectedService = newValue!; });
                    },
                    decoration: InputDecoration(
                      labelText: 'Service Type',
                      prefixIcon: const Icon(Icons.build, color: Colors.blueGrey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _odometerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Odometer (km)',
                      prefixIcon: const Icon(Icons.speed, color: Colors.blueGrey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cost (₹)',
                      prefixIcon: const Icon(Icons.currency_rupee, color: Colors.blueGrey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_odometerController.text.isEmpty) return;
                        final log = MaintenanceLog(
                          serviceType: _selectedService,
                          odometer: double.parse(_odometerController.text),
                          cost: double.parse(_costController.text.isEmpty ? "0" : _costController.text),
                          date: _selectedDate.toIso8601String(),
                        );
                        await DatabaseHelper.instance.insertMaintenanceLog(log);
                        if (mounted) Navigator.pop(context);
                        _refreshLogs();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance History'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
      // --- THE PREMIUM EMPTY STATE ---
          ? const EmptyState(
        icon: Icons.build_outlined,
        title: 'No Service Records',
        message: 'Keep track of your oil changes, chain lube, and tyre replacements here.',
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return Dismissible(
            key: Key('maint_${log.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) async {
              await DatabaseHelper.instance.deleteMaintenanceLog(log.id!);
              _refreshLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${log.serviceType} record deleted')),
              );
            },
            // --- THE ANIMATED CARD ---
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.build, color: Colors.blueGrey, size: 24),
                  ),
                  title: Text(log.serviceType, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('Odo: ${log.odometer} km'),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${log.cost}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      const SizedBox(height: 4),
                      Text(log.date.substring(0, 10), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ).animate().fade(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOutQuad),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceModal,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}