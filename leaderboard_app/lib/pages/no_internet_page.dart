import 'package:flutter/material.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 96, color: Colors.grey),
              const SizedBox(height: 24),
              const Text('No Internet Connection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Please check your connection. The app will continue once you are back online.', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  // Simply trigger a rebuild; actual status is managed by provider listening.
                  (context as Element).markNeedsBuild();
                },
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}