class UserModel {
  final String id;
  final String name;
  final String email;
  final String about;
  final String image;
  final bool isOnline;
  final String pushToken;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.about,
    required this.image,
    required this.isOnline,
    required this.pushToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      about: json['about'] ?? '',
      image: json['image'] ?? '',
      isOnline: json['isOnline'] ?? false,
      pushToken: json['pushToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'about': about,
      'image': image,
      'isOnline': isOnline,
      'pushToken': pushToken,
    };
  }
}
