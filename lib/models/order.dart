class UserOrder {
  final String userId;
  final String userName;
  final String address;
  final List<Map<String, dynamic>> items;
  final double total;
  final String paymentMethod;
  final String orderDate;

  UserOrder({
    required this.userId,
    required this.userName,
    required this.address,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.orderDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'address': address,
      'items': items,
      'total': total,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate,
    };
  }
}
