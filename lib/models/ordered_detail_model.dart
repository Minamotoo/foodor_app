class OrdersDetailModel {
  String customerPhone;
  String finishStatus;
  String customerID;
  String orderDetail;
  String id;
  String ownerID;
  String customerName;
  String paymentStatus;

  OrdersDetailModel(
      {this.customerPhone,
      this.finishStatus,
      this.customerID,
      this.orderDetail,
      this.id,
      this.ownerID,
      this.customerName,
      this.paymentStatus});

  OrdersDetailModel.fromJson(Map<String, dynamic> json) {
    customerPhone = json['customerPhone'];
    finishStatus = json['finishStatus'];
    customerID = json['customerID'];
    orderDetail = json['orderDetail'];
    id = json['id'];
    ownerID = json['ownerID'];
    customerName = json['customerName'];
    paymentStatus = json['paymentStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerPhone'] = this.customerPhone;
    data['finishStatus'] = this.finishStatus;
    data['customerID'] = this.customerID;
    data['orderDetail'] = this.orderDetail;
    data['id'] = this.id;
    data['ownerID'] = this.ownerID;
    data['customerName'] = this.customerName;
    data['paymentStatus'] = this.paymentStatus;
    return data;
  }
}
