import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';

class LoadBalancerController extends GetxController {

  // Mock background server nodes representing a distributed Medicine Cluster
  HttpServer? _nodeA;
  HttpServer? _nodeB;
  HttpServer? _nodeC;

  // Reactive state observables to track request counts per cluster node in real-time UI
  var nodeARequests = 0.obs;
  var nodeBRequests = 0.obs;
  var nodeCRequests = 0.obs;

  // Real-time live network telemetry monitoring metrics (Latency in Milliseconds)
  var nodeALatency = 40.obs;
  var nodeBLatency = 50.obs;
  var nodeCLatency = 60.obs;

  // Active load balancing routing policy strategy, toggled dynamically from the UI viewport
  var selectedAlgorithm = "Round Robin".obs;

  // Central counter for outbound transactional traffic, utilized for modulo arithmetic logic
  var totalRequests = 0;

  // Dynamic system log buffer to feed the in-app terminal console stream
  var lbLogs = <String>[].obs;

  // Periodic daemon timer simulating non-deterministic network fluctuations and telemetry state updates
  Timer? _telemetryTimer;

  @override
  void onInit() {
    super.onInit();
    _startAllNodes();            // Initialize local target infrastructure immediately upon controller creation
    _startTelemetryHeartbeat();  // Fire up the continuous active network polling and profiling loop
  }

  // Deploys the ingress target layer by binding three decoupled back-end instances on separate ports
  Future<void> _startAllNodes() async {
    try {
      // Node A: Represents a high-throughput, low-latency master cluster node on Port 8091
      _nodeA = await HttpServer.bind(InternetAddress.loopbackIPv4, 8091);
      _nodeA!.listen((req) => _handleMockResponse(req, "Node A (Port 8091)", nodeARequests));

      // Node B: Represents a stable baseline cluster replica instance on Port 8092
      _nodeB = await HttpServer.bind(InternetAddress.loopbackIPv4, 8092);
      _nodeB!.listen((req) => _handleMockResponse(req, "Node B (Port 8092)", nodeBRequests));

      // Node C: Represents a highly congested or geographically distant cluster instance on Port 8093
      _nodeC = await HttpServer.bind(InternetAddress.loopbackIPv4, 8093);
      _nodeC!.listen((req) => _handleMockResponse(req, "Node C (Port 8093)", nodeCRequests));

      _addLog("⚖️ [Load Balancer]: Ingress infrastructure deployed. 3 Clusters Active.");
    } catch (e) {
      _addLog("❌ [Setup Error]: Failed to bind nodes: $e");
    }
  }

  // Centralized network I/O handler responding to simulated HTTP connection payloads
  void _handleMockResponse(HttpRequest request, String nodeName, RxInt counter) {
    counter.value++; // Increment the target node's individual transaction counter upon telemetry capture
    request.response
      ..headers.contentType = ContentType.text
      ..write("SUCCESS_PAYLOAD_FROM_$nodeName")
      ..close(); // Safe stream teardown to eliminate client-side socket allocation lockups or memory leaks
  }

  // Simulates a localized telemetry feedback engine running continuously in the background
  void _startTelemetryHeartbeat() {
    _telemetryTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      final rand = Random();

      // Models structural real-world constraints: Node A stays swift, B remains average, C experiences load spikes
      nodeALatency.value = rand.nextInt(30) + 15;  // Fast operational bounds: 15ms - 45ms
      nodeBLatency.value = rand.nextInt(50) + 40;  // Normal standard deviation: 40ms - 90ms
      nodeCLatency.value = rand.nextInt(150) + 80; // High latency network bottleneck: 80ms - 230ms
    });
  }

  // Core programmatic Ingress Router implementing adaptive architectural routing logic
  Future<void> dispatchMedicineRequest() async {
    totalRequests++; // Increment central packet stream tracker
    int targetPort;
    String targetNode;

    // Strategy 1: Classical deterministic Round Robin distribution policy
    if (selectedAlgorithm.value == "Round Robin") {
      // Applies mathematical modulo arithmetic to achieve flawless symmetrical load distribution across clusters
      int index = totalRequests % 3;
      if (index == 0) { targetPort = 8091; targetNode = "Node A"; }
      else if (index == 1) { targetPort = 8092; targetNode = "Node B"; }
      else { targetPort = 8093; targetNode = "Node C"; }
    }
    // Strategy 2: Dynamic Adaptive Telemetry Feedback routing policy
    else {
      // Computes and selects the minimum latency factor across active endpoints to optimize execution speed
      int minLatency = [nodeALatency.value, nodeBLatency.value, nodeCLatency.value].reduce(min);
      if (minLatency == nodeALatency.value) { targetPort = 8091; targetNode = "Node A"; }
      else if (minLatency == nodeBLatency.value) { targetPort = 8092; targetNode = "Node B"; }
      else { targetPort = 8093; targetNode = "Node C"; }
    }

    _addLog("🔀 [Routing]: Strategy [${selectedAlgorithm.value}] -> Dispatching to $targetNode");

    // Instantiates HTTP network client to fire physical transport-layer packets to the routed port
    final client = HttpClient();
    try {
      final req = await client.get('127.0.0.1', targetPort, '/');
      final res = await req.close();
      if (res.statusCode == HttpStatus.ok) {
        _addLog("🎯 [Response]: $targetNode processed request successfully.");
      }
    } catch (e) {
      // Catches infrastructure failure states, demonstrating cluster degradation tracking without app crashes
      _addLog("🚨 [Routing Error]: Failed to communicate with $targetNode");
    } finally {
      client.close(); // Disposes client resource allocation to optimize the application's runtime memory pool
    }
  }

  // Formats system event markers into log rows and outputs them directly to the Flutter terminal debugger
  void _addLog(String msg) {
    final time = DateTime.now().toString().split(' ')[1].substring(0, 8);
    String formattedLog = "[$time] $msg";
    lbLogs.insert(0, formattedLog); // Inserts logs at index 0 to guarantee inverse chronological rendering in UI
    print("LOAD_BALANCER_LOG: $formattedLog");
    if (lbLogs.length > 25) lbLogs.removeLast(); // Trim trace boundary thresholds to sustain optimal RAM balance
  }

  // Resets empirical performance metrics and tracking metrics to facilitate validation runs
  void resetMetrics() {
    nodeARequests.value = 0;
    nodeBRequests.value = 0;
    nodeCRequests.value = 0;
    totalRequests = 0;
    lbLogs.clear();
    _addLog("♻️ [Metrics]: Telemetry counter cleared.");
  }

  // Framework teardown hook to clean up lingering asynchronous loops and prevent port binding lockups
  @override
  void onClose() {
    _telemetryTimer?.cancel();
    _nodeA?.close();
    _nodeB?.close();
    _nodeC?.close();
    super.onClose();
  }
}