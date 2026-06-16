import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Widget/CustomAppBar.dart';
import 'NodeCard.dart';
import 'load_balancer_controller.dart';

class LoadBalancerScreen extends StatelessWidget {
  LoadBalancerScreen({super.key});
  final controller = Get.put(LoadBalancerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: "Adaptive Load Balancer Engine",
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedAlgorithm.value,
                    dropdownColor: Colors.orange,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    items: ["Round Robin", "Adaptive Telemetry Feedback"].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedAlgorithm.value = val;
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            Text(
              "📊 Active Cluster Topology Load",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Obx(
              () => Column(
                children: [
                  NodeCard(
                    title: "Node A (Fast Cluster)",
                    requests: controller.nodeARequests.value,
                    latency: controller.nodeALatency.value,
                    accentColor: Colors.green,
                  ),
                  NodeCard(
                    title: "Node B (Medium Cluster)",
                    requests: controller.nodeBRequests.value,
                    latency: controller.nodeBLatency.value,
                    accentColor: Colors.pink,
                  ),

                  NodeCard(
                    title: "Node C (Congested Cluster)",
                    requests: controller.nodeCRequests.value,
                    latency: controller.nodeCLatency.value,
                    accentColor: Colors.blue,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => controller.dispatchMedicineRequest(),
                  icon: Icon(Icons.send, color: Colors.white),
                  label: Text(
                    "Dispatch Request",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => controller.resetMetrics(),
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text("Reset", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            Divider(color: Colors.white12, height: 30),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📟 Ingress Routing Live Streams:",
                      style: TextStyle(
                        color: Colors.cyan,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: Obx(
                        () => ListView.builder(
                          itemCount: controller.lbLogs.length,
                          itemBuilder: (context, index) {
                            String log = controller.lbLogs[index];
                            Color logColor = log.contains("🎯")
                                ? Colors.greenAccent
                                : (log.contains("🔀")
                                      ? Colors.cyanAccent
                                      : Colors.white60);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Text(
                                log,
                                style: TextStyle(
                                  color: logColor,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
