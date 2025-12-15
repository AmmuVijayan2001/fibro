class Userdata {
  int? id;
  String? name;
  String? email;
  String? profileImage;
  Userdata({this.email, this.id, this.name, this.profileImage});

  factory Userdata.fromJson(Map<String, dynamic> json) {
    return Userdata(
      name: json['name'] ?? '',
      id: json['id'],
      email: json["email"] ?? '',
      profileImage: json["profile_picture"],
    );
  }
  Map<String, dynamic> toJson() {
    return {'name': name, "email": email, "profile_picture": profileImage};
  }
}
