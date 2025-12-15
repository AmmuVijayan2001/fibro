class JunctionAddingData {
  String? name;
  String? latitude;
  String? longitude;
  String? postCode;
  int? id;
  int? officeId;
  JunctionAddingData({
    this.id,
    this.name,
    this.officeId,
    this.postCode,
    this.latitude,
    this.longitude,
  });

  factory JunctionAddingData.fromJson(Map<String, dynamic> json) {
    return JunctionAddingData(
      id: json['id'],
      name: json['name'] ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      postCode: json['post_code']?.toString() ?? '',
      officeId: json['office'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'post_code': postCode,
      'office': officeId,
    };
  }
}
