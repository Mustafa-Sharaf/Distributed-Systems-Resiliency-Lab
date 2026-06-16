import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'CircuitBreaker/CircuitBreakerScreen.dart';
import 'Client-Jittered-Backoff-and-Jitter-Lockshield/JitterBackoffScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Distributed Systems Practical Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DistributedTasksDashboard(),
    );
  }
}

class DistributedTasksDashboard extends StatelessWidget {
  const DistributedTasksDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distributed Systems Lab', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.hub_outlined, size: 80, color: Colors.indigo),
            const SizedBox(height: 16),
            const Text(
              'Practical Lab Assignments',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const Text(
              'Select a simulation task to review core resiliency patterns',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            Card(
              elevation: 4,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  child: Text('1'),
                ),
                title: const Text('Client Jittered Backoff', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Optimistic UI, Exponential Backoff, Full Jitter, Lock Shield'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.to(() => JitterBackoffScreen()),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  child: const Text('2'),
                ),
                title: const Text('Circuit Breaker Pattern', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Closed/Open/Half-Open States, Load Shedding, Failover Cache'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.to(() => CircuitBreakerScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}