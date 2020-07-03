class OrderedMenuModel {
  String id;
  String ownerID;
  String foodImageURL;
  String name;
  int price;
  int amount;

  OrderedMenuModel({
    this.id,
    this.ownerID,
    this.foodImageURL,
    this.name,
    this.price,
    this.amount,
  });

  OrderedMenuModel.fromJson(Map<String, dynamic> json) {
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
