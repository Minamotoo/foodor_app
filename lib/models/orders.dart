class Orders {
  String id;
  String customerID;
  String customerName;
  String customerPhone;
  String ownerID;
  String paymentStatus;
  String finishStatus;
  List<OrderDetail> orderDetail;

  Orders(
      {this.id,
      this.customerID,
      this.customerName,
      this.customerPhone,
      this.ownerID,
      this.paymentStatus,
      this.finishStatus,
      this.orderDetail});

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerID = json['customerID'];
    customerName = json['customerName'];
    customerPhone = json['customerPhone'];
    ownerID = json['ownerID'];
    paymentStatus = json['paymentStatus'];
    finishStatus = json['finishStatus'];
    if (json['orderDetail'] != null) {
      orderDetail = new List<OrderDetail>();
      json['orderDetail'].forEach((v) {
        orderDetail.add(new OrderDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customerID'] = this.customerID;
    data['customerName'] = this.customerName;
    data['customerPhone'] = this.customerPhone;
    data['ownerID'] = this.ownerID;
    data['paymentStatus'] = this.paymentStatus;
    data['finishStatus'] = this.finishStatus;
    if (this.orderDetail != null) {
      data['orderDetail'] = this.orderDetail.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderDetail {
  String id;
  String ownerID;
  String foodImageURL;
  String name;
  int price;
  int amount;

  OrderDetail(
      {this.id,
      this.ownerID,
      this.foodImageURL,
      this.name,
      this.price,
      this.amount});

  OrderDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerID = json['ownerID'];
    foodImageURL = json['foodImageURL'];
    name = json['name'];
    price = json['price'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ownerID'] = this.ownerID;
    data['foodImageURL'] = this.foodImageURL;
    data['name'] = this.name;
    data['price'] = this.price;
    data['amount'] = this.amount;
    return data;
  }
}
