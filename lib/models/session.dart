import 'user.dart';

class Session {
  final String id;
  final User user;
  final DateTime loginTime;
  final DateTime? logoutTime;
  final String status; // 'active', 'pending_approval', 'completed'
  final String? equipmentId; // Optional, if session is tied to equipment

  const Session({
    required this.id,
    required this.user,
    required this.loginTime,
    this.logoutTime,
    required this.status,
    this.equipmentId,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['_id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      loginTime: DateTime.parse(json['loginTime'] as String),
      logoutTime: json['logoutTime'] != null
          ? DateTime.parse(json['logoutTime'] as String)
          : null,
      status: json['status'] as String,
      equipmentId: json['equipment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'loginTime': loginTime.toIso8601String(),
      'logoutTime': logoutTime?.toIso8601String(),
      'status': status,
      'equipment': equipmentId,
    };
  }
}
