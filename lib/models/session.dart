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
      id: json['_id']?.toString() ?? '',
      user: (json['user'] != null && json['user'] is Map<String, dynamic>)
          ? User.fromJson(json['user'])
          : const User(
              id: 'unknown',
              name: 'Unknown User',
              email: 'unknown',
              isBlocked: false),
      loginTime: json['loginTime'] != null
          ? DateTime.tryParse(json['loginTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      logoutTime: json['logoutTime'] != null
          ? DateTime.tryParse(json['logoutTime'].toString())
          : null,
      status: json['status']?.toString() ?? 'active',
      equipmentId: json['equipment'] is Map 
          ? json['equipment']['_id']?.toString() 
          : json['equipment']?.toString(),
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
