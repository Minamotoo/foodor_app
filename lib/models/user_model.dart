class UserModel {
  String id;
  String name;
  String username;
  String password;
  String userType;
  String restaurantName;
  String restaurantPhone;
  String restaurantAddress;
  String restaurantDescription;
  String imageURL;
  String lat;
  String lng;
  String token;

  UserModel(
      {this.id,
      this.name,
      this.username,
      this.password,
      this.userType,
      this.restaurantName,
      this.restaurantPhone,
      this.restaurantAddress,
      this.restaurantDescription,
      this.imageURL,
      this.lat,
      this.lng,
      this.token});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    password = json['password'];
    userType = json['userType'];
    restaurantName = json['restaurantName'];
    restaurantPhone = json['restaurantPhone'];
    restaurantAddress = json['restaurantAddress'];
    restaurantDescription = json['restaurantDescription'];
    imageURL = json['imageURL'];
    lat = json['lat'];
    lng = json['lng'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['password'] = this.password;
    data['userType'] = this.userType;
    data['restaurantName'] = this.restaurantName;
    data['restaurantPhone'] = this.restaurantPhone;
    data['restaurantAddress'] = this.restaurantAddress;
    data['restaurantDescription'] = this.restaurantDescription;
    data['imageURL'] = this.imageURL;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['token'] = this.token;
    return data;
  }
}
