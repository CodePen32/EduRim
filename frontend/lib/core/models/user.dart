class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final int? learningPathId;
  final int? bacBranchId;
  final String city;
  final String gender;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.learningPathId,
    this.bacBranchId,
    required this.city,
    required this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      learningPathId: json['learning_path_id'] as int?,
      bacBranchId: json['bac_branch_id'] as int?,
      city: json['city'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
    );
  }

  String get displayPath {
    switch (learningPathId) {
      case 1:
        return 'كونكور';
      case 2:
        return 'BEPC';
      case 3:
        return 'BAC';
      default:
        return '';
    }
  }
}
