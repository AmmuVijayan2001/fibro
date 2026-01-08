class OfficeAddingData {
  String? name;
  String? latitude;
  String? longitude;
  String? address;
  int? id;
  OfficeAddingData({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory OfficeAddingData.fromJson(Map<String, dynamic> json) {
    return OfficeAddingData(
      id: json['id'],
      name: json['name'] ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
