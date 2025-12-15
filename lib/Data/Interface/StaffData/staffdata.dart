class StaffData {
  String? staffId;
  String? staffName;
  String? staffEmail;
  String? staffRole;
  String? staffPasssword;
  final bool? isActive;
  final String? joinedOn;
  final int? company;
  StaffData({
    this.staffId,
    this.staffName,
    this.staffEmail,
    this.staffPasssword,
    this.staffRole,
    this.company,
    this.isActive,
    this.joinedOn,
  });

  factory StaffData.fromJson(Map<String, dynamic> json) {
    return StaffData(
      staffId: json['id']?.toString() ?? '',
      staffName: json['name'] ?? '',
      staffEmail: json['email'] ?? '',
      staffRole: json['role'] ?? '',
      staffPasssword: json['password'] ?? '',
      isActive: json['is_active'],
      joinedOn: json['joined_on'],
      company: json['company'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': staffName,
      'email': staffEmail,
      'role': staffRole,
      'password': staffPasssword,
    };
  }

  @override
  String toString() {
    return 'StaffData(id: $staffId, name: $staffName, email: $staffEmail, role: $staffRole)';
  }
}
