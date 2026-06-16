import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';

import 'OrderItem.dart';

class JitterBackoffController extends GetxController {
  var orders = <OrderItem>[].obs;
  var networkLogs = <String>[].obs;
  var activeLocks = <String, bool>{}.obs;
  final Random _random = Random();

  void placeOrderOptimistic(String medicineName) async {
    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    //We immediately inject the request into the local request list and
    // give it an initial success status so that it appears to the user
    // immediately without waiting for a server response.
    final newOrder = OrderItem(
      id: orderId,
      medicineName: medicineName,
      status: 'Success (Optimistic)',
    );
    orders.insert(0, newOrder);

    //We activate the lock for this request to prevent it from being modified
    // or sent again if the user repeatedly taps the screen randomly.
    _addLog(
      "[Optimistic UI]: The interface was updated immediately upon request $medicineName",
    );

    activeLocks[orderId] = true;

    //We call the function that will attempt to connect to the server in the background
    // and apply the rollback and distraction algorithm,
    // and we wait for the result (complete success or failure after the attempts).
    bool isServerUpdated = await _sendRequestWithJitterBackoff(
      orderId,
      medicineName,
    );

    //If the four attempts go through and fail completely,
    // the application acknowledges the failure of the operation and
    // immediately cancels the optimistic state and changes it to Failure to inform the user of the truth and correct the local state.
    if (!isServerUpdated) {
      newOrder.status.value = 'Failed (Rolled Back)';
      _addLog(
        "❌ [Rollback]: All attempts failed. The request status has been rolled back. $orderId",
      );
    } else {
      newOrder.status.value = 'Confirmed by Server';
    }

    activeLocks[orderId] = false;
  }

  Future<bool> _sendRequestWithJitterBackoff(
    String orderId,
    String medicineName,
  ) async {
    int maxAttempts = 4;
    double baseWaitTimeInSeconds = 1.5;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      _addLog(
        "📡 Demand $orderId: Attempt number ($attempt) from ($maxAttempts)...",
      );

      bool success = await _mockServerRpc();

      if (success) {
        _addLog(
          "✅ Demand $orderId: The server responded successfully on attempt number $attempt!",
        );
        return true;
      }

      if (attempt == maxAttempts) break;

      double maxCalculatedBackoff = baseWaitTimeInSeconds * pow(2, attempt);

      double jitteredWaitTime = _random.nextDouble() * maxCalculatedBackoff;

      _addLog(
        "⏳ The attempt failed. $attempt. A regression with Jitter: waiting ${jitteredWaitTime.toStringAsFixed(2)} One second before the next attempt...",
      );

      await Future.delayed(
        Duration(milliseconds: (jitteredWaitTime * 1000).toInt()),
      );
    }

    return false;
  }

  Future<bool> _mockServerRpc() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _random.nextDouble() > 0.75;
  }

  void _addLog(String message) {
    String logEntry = "[${DateTime.now().toString().split(' ').last.substring(0, 8)}] $message";
    networkLogs.insert(0, logEntry);
    print("DISTRIBUTED_LOG: $logEntry");
  }

  void clearLogs() {
    networkLogs.clear();
    orders.clear();
  }
}
