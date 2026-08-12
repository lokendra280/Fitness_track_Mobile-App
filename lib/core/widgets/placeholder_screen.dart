import 'package:flutter/material.dart';

/// Generic "coming soon" destination used by quick actions / list tiles
/// that don't have a real feature screen yet, so every push in the app
/// actually navigates somewhere instead of failing silently.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_outlined,
                  size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('$title screen coming soon',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
