class User {
  final int id;
  final String email;
  final String username;
  final String token;
  final String avatar;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.token,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      token: json['token'] ?? '',
      avatar: json['avatar'] ?? 
             (json['username'] != null && json['username'].isNotEmpty 
                 ? json['username'][0].toUpperCase() 
                 : 'U'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'token': token,
      'avatar': avatar,
    };
  }
}