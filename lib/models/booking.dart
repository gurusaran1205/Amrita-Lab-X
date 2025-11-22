class BookingUserInfo {
  final String id;
  final String name;
  final String email;

  BookingUserInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory BookingUserInfo.fromJson(Map<String, dynamic> json) {
    return BookingUserInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? 'no-email@provided.com',
    );
  }
}

class BookingEquipmentInfo {
  final String id;
  final String name;
  final String labId;

  BookingEquipmentInfo({
    required this.id,
    required this.name,
    required this.labId,
  });

  factory BookingEquipmentInfo.fromJson(Map<String, dynamic> json) {
    return BookingEquipmentInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Equipment',
      labId: json['lab'] ?? '',
    );
  }
}

class Booking {
  final String id;
  final BookingUserInfo user;
  final BookingEquipmentInfo equipment;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String purpose;

  Booking({
    required this.id,
    required this.user,
    required this.equipment,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.purpose,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    BookingUserInfo userInfo;
    if (json['user'] is String) {
      userInfo = BookingUserInfo(
        id: json['user'],
        name: 'Current User', // Placeholder as API only returns ID
        email: '',
      );
    } else {
      userInfo = BookingUserInfo.fromJson(json['user']);
    }

    return Booking(
      id: json['_id'],
      user: userInfo,
      equipment: BookingEquipmentInfo.fromJson(json['equipment']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status'],
      purpose: json['purpose'],
    );
  }
}