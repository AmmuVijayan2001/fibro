class Customerdata {
  int? customerID;
  String? customerName;
  String? customerEmail;
  String? customerPhone;
  String? address;
  int? staff;
  int? office;
  double? latitude;
  double? longitude;
  Customerdata({
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.address,
    this.office,
    this.staff,
    this.customerID,
    this.latitude,
    this.longitude,
  });
  Customerdata.fromJson(Map<String, dynamic> json) {
    customerID = json["id"] ?? "";
    customerName = json['name'] ?? '';
    customerEmail = json['email'] ?? '';
    customerPhone = json['phone'] ?? '';
    address = json['address'] ?? '';
    staff = json['staff'];
    office = json['office'];
    latitude = json['latitude'] ?? '';
    longitude = json['longitude'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': customerName,
      'email': customerEmail,
      'phone': customerPhone,
      'address': address,
      'office': office,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}
