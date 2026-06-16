import 'dart:async';
import 'package:get/get.dart';
import 'CircuitState.dart';

class CircuitBreakerController extends GetxController {
  var circuitState = CircuitState.Closed.obs;
  var isServerHealthy = true.obs;
  final int maxFailures = 3;
  final int coolDownSeconds = 5;
  int _failureCount = 0;
  var logs = <String>[].obs;
  var fetchedData = "Waiting for the warehouse data to be retrieved...".obs;

  Future<void> fetchInventoryData() async {
    _addLog("📥 New request to retrieve data...");

    if (circuitState.value == CircuitState.Open) {
      _addLog(
        "🛑 [Circuit OPEN]: Request rejected immediately! Server crashed.",
      );
      _addLog("🔄 [Fail-over Policy]: Fetch data from local memory (Cache).");
      fetchedData.value =
          "📦 Temporary data (Cached): 500 Paracetamol, 200 Aspirin";
      return;
    }

    if (circuitState.value == CircuitState.HalfOpen) {
      _addLog("⚠️ [Circuit HALF-OPEN]: Allow one test request (Probe)...");
    }

    bool success = await _mockApiCall();

    if (success) {
      _handleSuccess();
    } else {
      _handleFailure();
    }
  }

  void _handleSuccess() {
    _addLog("✅ [Network]: Successful response from the server.");
    fetchedData.value = "🏥 Live data: 850 Paracetamol, 410 Aspirin";

    if (circuitState.value == CircuitState.HalfOpen) {
      _addLog("💚 [Recovery]: Test passed! Circuit closed.");
      circuitState.value = CircuitState.Closed;
    }

    _failureCount = 0;
  }

  void _handleFailure() {
    _failureCount++;
    _addLog(
      "❌ [Network]: Connection failed! (Failure number $_failureCount from $maxFailures)",
    );
    fetchedData.value = "⚠️ Unable to retrieve live data.";

    if (circuitState.value == CircuitState.HalfOpen) {
      _addLog("💔 [Relapse]: Test failed! Reopen circuit (Circuit OPEN).");
      _tripBreaker();
      return;
    }

    if (_failureCount >= maxFailures) {
      _addLog(
        "💥 [Threshold Reached]: The allowed limit for errors has been exceeded!",
      );
      _tripBreaker();
    }
  }

  void _tripBreaker() {
    circuitState.value = CircuitState.Open;
    _addLog(
      "🚨 [Circuit TRIPPED]: The circuit is now (OPEN). All incoming requests are blocked.",
    );

    Timer(Duration(seconds: coolDownSeconds), () {
      if (circuitState.value == CircuitState.Open) {
        circuitState.value = CircuitState.HalfOpen;
        _addLog(
          "⏱️ [Cooldown Over]: The circuit is now (HALF-OPEN). Awaiting a test request. ",
        );
      }
    });
  }

  Future<bool> _mockApiCall() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return isServerHealthy.value;
  }

  void toggleServerHealth() {
    isServerHealthy.value = !isServerHealthy.value;
    _addLog(
      "🔧 [Admin]: The server status has become -> ${isServerHealthy.value ? 'Healthy 🟢' : 'Down 🔴'}",
    );
  }

  void _addLog(String message) {
    String logEntry =
        "[${DateTime.now().toString().split(' ').last.substring(0, 8)}] $message";
    logs.insert(0, logEntry);
    print("🚀 CIRCUIT_LOG: $logEntry");
  }

  void clearLogs() {
    logs.clear();
    _failureCount = 0;
    circuitState.value = CircuitState.Closed;
    fetchedData.value = "Waiting for the warehouse data to be retrieved...";
  }
}
