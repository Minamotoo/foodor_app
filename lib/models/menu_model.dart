class MenuModel {
  String id;
  String ownerID;
  String foodImageURL;
  String name;
  String price;
  String description;
  String foodType;
  String promotionStatus;
  String promotionDetail;

  MenuModel({
    this.id,
    this.ownerID,
    this.foodImageURL,
    this.name,
    this.price,
    this.description,
    this.foodType,
    this.promotionStatus,
    this.promotionDetail,
  });

  MenuModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerID = json['ownerID'];
    foodImageURL = json['foodImageURL'];
    name = json['name'];
    price = json['price'];
    description = json['description'];
    foodType = json['foodType'];
    promotionStatus = json['promotionStatus'];
    promotionDetail = json['promotionDetail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ownerID'] = this.ownerID;
    data['foodImageURL'] = this.foodImageURL;
    data['name'] = this.name;
    data['price'] = this.price;
    data['description'] = this.description;
    data['foodType'] = this.foodType;
    data['promotionStatus'] = this.promotionStatus;
    data['promotionDetail'] = this.promotionDetail;
    return data;
  }
}
