import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'CircuitBreakerController.dart';
import 'CircuitState.dart';

class CircuitBreakerScreen extends StatelessWidget {
  CircuitBreakerScreen({super.key});

  final CircuitBreakerController controller = Get.put(
    CircuitBreakerController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Circuit Breaker - Task 2',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
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
              color: Colors.blueGrey.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Central server status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Obx(
                      () => Switch(
                        value: controller.isServerHealthy.value,
                        onChanged: (val) => controller.toggleServerHealth(),
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.isServerHealthy.value
                            ? 'connected 🟢'
                            : 'collapsed 🔴',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.isServerHealthy.value
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              Color stateColor;
              String stateText;
              IconData stateIcon;

              switch (controller.circuitState.value) {
                case CircuitState.Closed:
                  stateColor = Colors.green;
                  stateText = "CLOSED (Natural - Allows passage)";
                  stateIcon = Icons.check_circle_outline;
                  break;
                case CircuitState.Open:
                  stateColor = Colors.red;
                  stateText = "OPEN (Cut off - Orders blocked)";
                  stateIcon = Icons.block;
                  break;
                case CircuitState.HalfOpen:
                  stateColor = Colors.orange;
                  stateText = "HALF-OPEN (Test - Only one request)";
                  stateIcon = Icons.warning_amber_rounded;
                  break;
              }

              return Card(
                elevation: 4,
                color: stateColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: stateColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(stateIcon, size: 40, color: stateColor),
                      const SizedBox(height: 8),
                      Text(
                        'Circuit breaker status:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        stateText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: stateColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => controller.fetchInventoryData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.cloud_download),
              label: const Text(
                'Retrieving warehouse data (Client Request)',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Text(
                  controller.fetchedData.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const Divider(height: 24, thickness: 2),

            const Text(
              '🖥️ Distributed system logs (Interceptor Logs):',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(() {
                  if (controller.logs.isEmpty) {
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
                    itemCount: controller.logs.length,
                    itemBuilder: (context, index) {
                      String log = controller.logs[index];
                      Color logColor = Colors.white;
                      if (log.contains('❌') ||
                          log.contains('🛑') ||
                          log.contains('💥') ||
                          log.contains('🚨'))
                        logColor = Colors.redAccent;
                      if (log.contains('✅') ||
                          log.contains('💚') ||
                          log.contains('CLOSED'))
                        logColor = Colors.greenAccent;
                      if (log.contains('⚠️') || log.contains('HALF-OPEN'))
                        logColor = Colors.amberAccent;
                      if (log.contains('🔄') || log.contains('⏱️'))
                        logColor = Colors.lightBlueAccent;

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
