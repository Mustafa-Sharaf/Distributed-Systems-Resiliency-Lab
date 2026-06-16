import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'JitterBackoffController.dart';

class JitterBackoffScreen extends StatelessWidget {
  JitterBackoffScreen({super.key});

  final JitterBackoffController controller = Get.put(JitterBackoffController());

  final List<String> medicinesSample = [
    "Paracetamol 500mg",
    "Amoxicillin 250mg",
    "Lipitor 20mg",
    "Metformin 800mg",
    "Panadol Extra",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Distributed Systems - Task 1',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => controller.clearLogs(),
            tooltip: 'Surveying records',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Simulating a pharmacy order distribution system',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upon pressing, the interface will be updated immediately (Optimistic UI), and if the network fails, the Backoff will automatically start with Jitter in the background.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        String randomMedicine =
                            medicinesSample[Random().nextInt(
                              medicinesSample.length,
                            )];
                        controller.placeOrderOptimistic(randomMedicine);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text(
                        'Send an optimistic medicine request immediately',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: const Text(
                'Local State:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              flex: 2,
              child: Obx(() {
                if (controller.orders.isEmpty) {
                  return const Center(
                    child: Text('There are no orders at the moment. Press the button above.'),
                  );
                }
                return ListView.builder(
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) {
                    final order = controller.orders[index];
                    return Obx(() {
                      Color statusColor = Colors.orange;
                      if (order.status.value.contains('Confirmed')) {
                        statusColor = Colors.green;
                      }
                      if (order.status.value.contains('Failed')) {
                        statusColor = Colors.red;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.2),
                            child: Icon(Icons.medication, color: statusColor),
                          ),
                          title: Text(
                            order.medicineName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('ID: ${order.id}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              order.status.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),
            const Divider(height: 20, thickness: 2),

           Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Distributed Systems Algorithm Monitoring Panel (Live):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
                Obx(
                  () => controller.activeLocks.values.contains(true)
                      ? const Card(
                          color: Colors.amber,
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Text(
                              'Lock Shield Active',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(() {
                  if (controller.networkLogs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Waiting for network activity...',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: controller.networkLogs.length,
                    itemBuilder: (context, index) {
                      String log = controller.networkLogs[index];
                      Color logColor = Colors.white;
                      if (log.contains('❌') || log.contains('Failed')) {
                        logColor = Colors.redAccent;
                      }
                      if (log.contains('✅') || log.contains('Confirmed')) {
                        logColor = Colors.greenAccent;
                      }
                      if (log.contains('⏳')) logColor = Colors.amberAccent;
                      if (log.contains('📱')) logColor = Colors.lightBlueAccent;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: logColor,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
