import 'package:flutter/material.dart';
import '../models/fuel_log.dart';
import '../services/database_helper.dart';

class AddFuelScreen extends StatefulWidget {
  const AddFuelScreen({super.key});

  @override
  State<AddFuelScreen> createState() => _AddFuelScreenState();
}

class _AddFuelScreenState extends State<AddFuelScreen> {
  bool _isQuickLog = false; // The new toggle state
  bool _isFullTank = true; // New state variable

  final _odometerController = TextEditingController();
  final _litresController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalAmountController = TextEditingController(); // New controller for quick log
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
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
      setState(() { _selectedDate = picked; });
    }
  }

  Future<void> _saveLog() async {
    FuelLog log;

    if (_isQuickLog) {
      // Quick Log: Only save Total Amount and Date
      if (_totalAmountController.text.isEmpty) return;
      log = FuelLog(
        totalAmount: double.parse(_totalAmountController.text),
        date: _selectedDate.toIso8601String(),
        // odometer, litres, and pricePerLitre remain null
      );
    } else {
      // Full Log: Save everything and calculate total amount automatically
      if (_odometerController.text.isEmpty || _litresController.text.isEmpty) return;

      double litres = double.parse(_litresController.text);
      double price = double.parse(_priceController.text.isEmpty ? "0" : _priceController.text);

      log = FuelLog(
        odometer: double.parse(_odometerController.text),
        litres: litres,
        pricePerLitre: price,
        totalAmount: litres * price, // Auto-calculated
        date: _selectedDate.toIso8601String(),
        isFullTank: _isFullTank, // Add this line!
      );
    }

    await DatabaseHelper.instance.insertFuelLog(log);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Fuel'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Log Toggle
            SwitchListTile(
              title: const Text('Amount Only (Past Log)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('I don\'t know the odometer or litres.'),
              activeColor: Colors.blueGrey,
              value: _isQuickLog,
              onChanged: (bool value) {
                setState(() { _isQuickLog = value; });
              },
            ),
            const Divider(height: 30),

            // Date Picker (Always visible)
            InkWell(
              onTap: _pickDate,
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
            const SizedBox(height: 20),

            // Dynamic Form Inputs
            if (_isQuickLog) ...[
              _buildTextField(_totalAmountController, 'Total Amount Spent (₹)', Icons.currency_rupee),
            ] else ...[
              _buildTextField(_odometerController, 'Current Odometer (km)', Icons.speed),
              const SizedBox(height: 16),
              _buildTextField(_litresController, 'Litres Filled', Icons.water_drop_outlined),
              const SizedBox(height: 16),
              _buildTextField(_priceController, 'Price per Litre (₹)', Icons.currency_rupee),
            ],

            // --- NEW FULL TANK TOGGLE ---
            if (!_isQuickLog) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                ),
                child: CheckboxListTile(
                  title: const Text('Full Tank', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Required for accurate mileage math'),
                  value: _isFullTank,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (bool? value) {
                    setState(() { _isFullTank = value ?? true; });
                  },
                ),
              ),
            ],

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}