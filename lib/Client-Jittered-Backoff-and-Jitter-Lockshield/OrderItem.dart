
import 'package:get/get.dart';

class OrderItem {
  final String id;
  final String medicineName;
  RxString status;

  OrderItem({required this.id, required this.medicineName, required String status})
      : status = status.obs;
}