class Deviceportdata {
  String? portnumber;
  String? porttype;
  int? deviceId;
  int? id;
  String? speed;
  Deviceportdata({this.portnumber, this.porttype, this.deviceId, this.speed});

  Deviceportdata.fromJson(Map<String, dynamic> json) {
    portnumber = json['port_number']?.toString() ?? '';
    porttype = json['port_type']?.toString() ?? '';
    deviceId = json['device']?.toInt() ?? '';
    speed = json['speed']?.toString() ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'port_number': portnumber,
      'port_type': porttype,
      'device': deviceId,
      'speed': speed,
    };
  }
}
