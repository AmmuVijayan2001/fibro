class NetworkDeviceData {
  String? modelName;
  String? latitude;
  String? longitude;
  String? deviceType;
  int? id;
  int? officeId;
  String? description;
  String? ratio;
  int? maxSpeed;
  String? colorCoding;
  double? insertionLoss;
  double? returnLoss;
  int? portCount;
  String? supportProtocol;
  int? staff;

  NetworkDeviceData({
    this.id,
    this.officeId,
    this.deviceType,
    this.latitude,
    this.longitude,
    this.modelName,
    this.description,
    this.colorCoding,
    this.insertionLoss,
    this.maxSpeed,
    this.portCount,
    this.ratio,
    this.returnLoss,
    this.supportProtocol,
    this.staff,
  });

  factory NetworkDeviceData.fromJson(Map<String, dynamic> json) {
    return NetworkDeviceData(
      id: json['id'],
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['logitutde']?.toString() ?? '',
      deviceType: json['device_type']?.toString() ?? '',
      officeId: json['office'] ?? '',
      description: json['description'] ?? '',
      modelName: json['model_name'] ?? '',
      staff: json['staff'] ?? '',
      colorCoding: json["color_coding"],
      insertionLoss: json["insertion_loss"],
      maxSpeed: json["max_speed"],
      portCount: json["port_count"],
      ratio: json["ratio"],
      returnLoss: json["return_loss"],
      supportProtocol: json["supported_protocols"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "device_type": deviceType,
      "model_name": modelName,
      "description": description,
      "ratio": ratio,
      "max_speed": maxSpeed,
      "color_coding": colorCoding,
      "insertion_loss": insertionLoss,
      "port_count": portCount,
      "return_loss": returnLoss,
      "supported_protocols": supportProtocol,
      'latitude': latitude,
      'logitutde': longitude,
      'office': officeId,
      "staff": staff,
    };
  }
}
