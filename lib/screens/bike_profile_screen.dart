import 'package:flutter/material.dart';

class BikeProfileScreen extends StatelessWidget {
  const BikeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bike Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bike Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.two_wheeler, size: 64, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Yezdi Roadster', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Bloodrush Maroon • 334cc • 12.5L Tank', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Documents Section
            Text('Important Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 12),

            _buildDocCard(
                context,
                'Registration (RC)',
                'TG07AT0646',
                Icons.badge_outlined,
                Colors.blue,
                'assets/images/rc.png'
            ),
            _buildDocCard(
                context,
                'Insurance (Tata AIG)',
                'Valid till Feb 25, 2027',
                Icons.shield_outlined,
                Colors.green,
                'assets/images/insurance.png'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, String title, String subtitle, IconData icon, Color iconColor, String imagePath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.visibility, color: Colors.grey),
        onTap: () => _showDocumentModal(context, title, subtitle, imagePath),
      ),
    );
  }

  void _showDocumentModal(BuildContext context, String title, String subtitle, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
            Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey.withOpacity(0.1),
                  child: Center(
                    child: Text('Image not found.\nSave as $imagePath', textAlign: TextAlign.center,),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}