import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/reminder.dart';
import '../services/database_helper.dart';
import '../widgets/empty_state.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  String _selectedType = 'Odometer'; // Default to mileage-based

  @override
  void initState() {
    super.initState();
    _refreshReminders();
  }

  Future<void> _refreshReminders() async {
    final data = await DatabaseHelper.instance.getAllReminders();
    setState(() {
      _reminders = data;
      _isLoading = false;
    });
  }

  void _showAddReminderModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('New Reminder', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title (e.g., PUC, Chain Lube)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: ['Odometer', 'Date'].map((String type) {
                      return DropdownMenuItem(value: type, child: Text('Based on: $type'));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() { _selectedType = newValue!; });
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _valueController,
                    keyboardType: _selectedType == 'Odometer' ? TextInputType.number : TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: _selectedType == 'Odometer' ? 'Target Odometer (km)' : 'Due Date (YYYY-MM-DD)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_titleController.text.isEmpty || _valueController.text.isEmpty) return;

                      final reminder = Reminder(
                        title: _titleController.text,
                        type: _selectedType,
                        dueOdometer: _selectedType == 'Odometer' ? double.parse(_valueController.text) : null,
                        dueDate: _selectedType == 'Date' ? _valueController.text : null,
                      );

                      await DatabaseHelper.instance.insertReminder(reminder);
                      _titleController.clear();
                      _valueController.clear();
                      if (mounted) Navigator.pop(context);
                      _refreshReminders();
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Set Reminder'),
                  ),
                  const SizedBox(height: 16),
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
      appBar: AppBar(title: const Text('Reminders')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
      // --- THE PREMIUM EMPTY STATE ---
          ? const EmptyState(
        icon: Icons.notifications_none,
        title: 'All Caught Up',
        message: 'Add reminders for your insurance renewal, PUC checks, or next scheduled service.',
      )
          : ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          // --- THE ANIMATED CARD ---
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                reminder.type == 'Date' ? Icons.calendar_month : Icons.speed,
                color: Colors.orange,
              ),
              title: Text(reminder.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                reminder.type == 'Date' ? 'Due: ${reminder.dueDate}' : 'Due at: ${reminder.dueOdometer} km',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                onPressed: () async {
                  await DatabaseHelper.instance.deleteReminder(reminder.id!);
                  _refreshReminders();
                },
              ),
            ),
          ).animate().fade(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOutQuad);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderModal,
        child: const Icon(Icons.add_alert),
      ),
    );
  }
}