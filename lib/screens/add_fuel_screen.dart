import 'package:flutter/material.dart';
import '../models/fuel_log.dart';
import '../services/database_helper.dart';

class AddFuelScreen extends StatefulWidget {
  const AddFuelScreen({super.key});

  @override
  State<AddFuelScreen> createState() => _AddFuelScreenState();
}

class _AddFuelScreenState extends State<AddFuelScreen> {
  bool _isQuickLog = false;
  bool _isFullTank = true; // New state variable
  DateTime _selectedDate = DateTime.now();

  final _odometerController = TextEditingController();
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();

  Future<void> _saveLog() async {
    // 1. Validation Checks
    if (!_isQuickLog && _odometerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the odometer reading!'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the total amount spent!'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 2. Logic
    FuelLog log;
    if (_isQuickLog) {
      log = FuelLog(
        totalAmount: double.parse(_amountController.text),
        date: _selectedDate.toIso8601String(),
        isFullTank: false, // Quick logs are never full tanks
      );
    } else {
      double totalAmount = double.parse(_amountController.text);
      double price = _priceController.text.isNotEmpty ? double.parse(_priceController.text) : 100.0;
      double litres = totalAmount / price;

      log = FuelLog(
        odometer: double.parse(_odometerController.text),
        litres: litres,
        pricePerLitre: price,
        totalAmount: totalAmount,
        date: _selectedDate.toIso8601String(),
        isFullTank: _isFullTank,
      );
    }

    await DatabaseHelper.instance.insertFuelLog(log);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Fuel Log'),
        actions: [
          Row(
            children: [
              const Text('Quick Log', style: TextStyle(fontSize: 14)),
              Switch(
                value: _isQuickLog,
                onChanged: (val) => setState(() => _isQuickLog = val),
                activeColor: Theme.of(context).colorScheme.secondary,
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Picker
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 16),
                    Text(
                      'Date: ${_selectedDate.toIso8601String().substring(0, 10)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (!_isQuickLog) ...[
              TextField(
                controller: _odometerController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Current Odometer (km)',
                  prefixIcon: const Icon(Icons.speed),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Amount Paid (₹)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            if (!_isQuickLog) ...[
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price per Litre (Optional)',
                  hintText: 'Default: ₹100.0',
                  prefixIcon: const Icon(Icons.local_gas_station),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Full Tank Toggle
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

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}