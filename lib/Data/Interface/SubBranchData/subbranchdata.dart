class SucbOfficeAddingData {
  String? name;
  String? latitude;
  String? longitude;
  String? address;
  int? officeId;
  int? id;

  SucbOfficeAddingData({
    this.name,
    this.latitude,
    this.longitude,
    this.address,
    this.officeId,
    this.id,
  });

  factory SucbOfficeAddingData.fromJson(Map<String, dynamic> json) {
    return SucbOfficeAddingData(
      name: json['name'] ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['logitude']?.toString() ?? '',
      address: json['address'] ?? '',
      officeId: json["office"],
      id: json["id"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'logitude': longitude,
      'address': address,
      "office": officeId,
    };
  }
}
