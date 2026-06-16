import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';

class HeartbeatController extends GetxController {

  HttpServer? _server1;
  HttpServer? _server2;
  HttpServer? _server3;

  var isServer1Running = true.obs;
  var isServer2Running = true.obs;
  var isServer3Running = true.obs;


  var statusServer1 = "Connecting... ⏳".obs;
  var statusServer2 = "Connecting... ⏳".obs;
  var statusServer3 = "Connecting... ⏳".obs;

  var isHealthy1 = false.obs;
  var isHealthy2 = false.obs;
  var isHealthy3 = false.obs;


  var logs = <String>[].obs;

  Timer? _heartbeatTimer;

  @override
  void onInit() {
    super.onInit();
    _startAllMockServers();
    _startHeartbeatMonitor();
  }


  Future<void> _startAllMockServers() async {
    try {
      // Warehouse Service on Port 8081
      _server1 = await HttpServer.bind(InternetAddress.loopbackIPv4, 8081);
      _server1!.listen((HttpRequest request) {
        if (isServer1Running.value) {
          request.response..write("PONG")..close();
        } else {
          request.response..statusCode = HttpStatus.serviceUnavailable..close();
        }
      });

      // Fleet Service on Port 8082
      _server2 = await HttpServer.bind(InternetAddress.loopbackIPv4, 8082);
      _server2!.listen((HttpRequest request) {
        if (isServer2Running.value) {
          request.response..write("PONG")..close();
        } else {
          request.response..statusCode = HttpStatus.serviceUnavailable..close();
        }
      });

      // Procurement Service on Port 8083
      _server3 = await HttpServer.bind(InternetAddress.loopbackIPv4, 8083);
      _server3!.listen((HttpRequest request) {
        if (isServer3Running.value) {
          request.response..write("PONG")..close();
        } else {
          request.response..statusCode = HttpStatus.serviceUnavailable..close();
        }
      });

      _addLog("⚙️ [System]: 3 Microservices started in background.");
    } catch (e) {
      _addLog("❌ [System Error]: Failed to bind servers: $e");
    }
  }


  void _startHeartbeatMonitor() {
    _heartbeatTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      _checkServer(8081, "Warehouse Service", statusServer1, isHealthy1, isServer1Running.value);
      _checkServer(8082, "Fleet Service", statusServer2, isHealthy2, isServer2Running.value);
      _checkServer(8083, "Procurement Service", statusServer3, isHealthy3, isServer3Running.value);
    });
  }


  Future<void> _checkServer(int port, String name, RxString status, RxBool isHealthy, bool isAdminRunning) async {
    final client = HttpClient();
    client.connectionTimeout = Duration(seconds: 2);


    if (!isAdminRunning) {
      status.value = "DEAD 🔴 (Stopped)";
      isHealthy.value = false;
      _addLog("🚨 [Monitor]: $name is not responding! Status -> DEAD");
      client.close();
      return;
    }

    try {
      final request = await client.get('127.0.0.1', port, '/');
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        status.value = "HEALTHY 🟢";
        isHealthy.value = true;
        _addLog("💓 [Heartbeat]: Ping to $name successful. Status -> HEALTHY");
      } else {
        status.value = "DEAD 🔴";
        isHealthy.value = false;
        _addLog("🚨 [Monitor]: $name returned status ${response.statusCode}! Status -> DEAD");
      }
    } catch (e) {
      status.value = "DEAD 🔴";
      isHealthy.value = false;
      _addLog("🚨 [Monitor]: $name connection failed! Status -> DEAD");
    } finally {
      client.close();
    }
  }

  void _addLog(String msg) {
    final time = DateTime.now().toString().split(' ')[1].substring(0, 8);
    String formattedLog = "[$time] $msg";
    logs.insert(0, formattedLog);

    print("HEARTBEAT_LOG: $formattedLog");

    if (logs.length > 30) logs.removeLast();
  }

  void toggleServer1() { isServer1Running.value = !isServer1Running.value; _addLog("🔧 [Admin]: Toggled Warehouse Service to ${isServer1Running.value ? 'ON' : 'OFF'}"); }
  void toggleServer2() { isServer2Running.value = !isServer2Running.value; _addLog("🔧 [Admin]: Toggled Fleet Service to ${isServer2Running.value ? 'ON' : 'OFF'}"); }
  void toggleServer3() { isServer3Running.value = !isServer3Running.value; _addLog("🔧 [Admin]: Toggled Procurement Service to ${isServer3Running.value ? 'ON' : 'OFF'}"); }

  @override
  void onClose() {
    _heartbeatTimer?.cancel();
    _server1?.close();
    _server2?.close();
    _server3?.close();
    super.onClose();
  }
}