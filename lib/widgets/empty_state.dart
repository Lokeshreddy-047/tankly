import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating icon with a soft background glow
            // Floating icon with a soft background glow
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 2,
                  )
              ),
              child: Icon(
                icon,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500, // Adapts to light/dark mode well
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}