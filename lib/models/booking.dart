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
    String labId = '';
    if (json['lab'] is String) {
      labId = json['lab'];
    } else if (json['lab'] is Map) {
      labId = json['lab']['_id'] ?? '';
    }

    return BookingEquipmentInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Equipment',
      labId: labId,
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
    if (json['user'] == null) {
      userInfo = BookingUserInfo(
        id: 'unknown',
        name: 'Unknown User',
        email: '',
      );
    } else if (json['user'] is String) {
      userInfo = BookingUserInfo(
        id: json['user'],
        name: 'Current User', // Placeholder as API only returns ID
        email: '',
      );
    } else {
      userInfo = BookingUserInfo.fromJson(json['user']);
    }

    BookingEquipmentInfo equipmentInfo;
    if (json['equipment'] == null) {
      equipmentInfo = BookingEquipmentInfo(
        id: 'unknown',
        name: 'Unknown Equipment',
        labId: '',
      );
    } else {
      equipmentInfo = BookingEquipmentInfo.fromJson(json['equipment']);
    }

    return Booking(
      id: json['_id'] ?? '',
      user: userInfo,
      equipment: equipmentInfo,
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'unknown',
      purpose: json['purpose'] ?? '',
    );
  }
}