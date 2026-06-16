import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'heartbeat_controller.dart';

class HeartbeatScreen extends StatelessWidget {
  HeartbeatScreen({super.key});

  final controller = Get.put(HeartbeatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff12121c),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          "Resilient Microservice Monitor - Task 3",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),
        ),
        backgroundColor: Color(0xff1f1f30),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Text(
              "🛰️ Live Microservices Network Status",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Obx(
              () => Column(
                children: [
                  _buildServerCard(
                    "Warehouse Service (Port 8081)",
                    controller.statusServer1.value,
                    controller.isHealthy1.value,
                  ),
                  _buildServerCard(
                    "Fleet Tracking Service (Port 8082)",
                    controller.statusServer2.value,
                    controller.isHealthy2.value,
                  ),
                  _buildServerCard(
                    "Procurement Service (Port 8083)",
                    controller.statusServer3.value,
                    controller.isHealthy3.value,
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white24, height: 30),

            Text(
              "🔧 Admin Chaos Simulation Panel",
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Simulate killing/reviving microservices to test automated detection",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            SizedBox(height: 12),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAdminButton(
                    "Warehouse",
                    controller.isServer1Running.value,
                    controller.toggleServer1,
                  ),
                  _buildAdminButton(
                    "Fleet",
                    controller.isServer2Running.value,
                    controller.toggleServer2,
                  ),
                  _buildAdminButton(
                    "Procurement",
                    controller.isServer3Running.value,
                    controller.toggleServer3,
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white24, height: 30),


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
                      "📟 Live Heartbeat Output Logs:",
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: Obx(
                        () => ListView.builder(
                          itemCount: controller.logs.length,
                          itemBuilder: (context, index) {
                            String log = controller.logs[index];
                            Color logColor = log.contains("🚨")
                                ? Colors.redAccent
                                : (log.contains("💓")
                                      ? Colors.greenAccent
                                      : Colors.amberAccent);
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

  Widget _buildServerCard(String name, String status, bool isHealthy) {
    return Card(
      color: Color(0xff1f1f30),
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          isHealthy ? Icons.gpp_good : Icons.gpp_bad,
          color: isHealthy ? Colors.green : Colors.red,
          size: 30,
        ),
        title: Text(
          name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isHealthy
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isHealthy ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton(String name, bool isRunning, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isRunning ? Colors.red : Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onPressed: onTap,
      child: Text(
        isRunning ? "Kill $name" : "Revive $name",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 12),
      ),
    );
  }
}
