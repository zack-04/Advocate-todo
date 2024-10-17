class User {
  String name;
  String userId;

  User({required this.name, required this.userId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      userId: json['user_id'],
    );
  }
}

class UserDataResponse {
  List<User> data;

  UserDataResponse({required this.data});

  factory UserDataResponse.fromJson(Map<String, dynamic> json) {
    return UserDataResponse(
      data: List<User>.from(json['data'].map((user) => User.fromJson(user))),
    );
  }
}
