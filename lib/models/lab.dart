class Lab {
  final String id;
  final String name;
  final String location;
  final DepartmentRef? department;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lab({
    required this.id,
    required this.name,
    required this.location,
    this.department,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lab.fromJson(Map<String, dynamic> json) {
    return Lab(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      department: json['department'] is Map<String, dynamic>
          ? DepartmentRef.fromJson(json['department'])
          : (json['department'] != null
              ? DepartmentRef(id: json['department'], name: "")
              : null),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "location": location,
      "department": department?.id, // backend expects id
    };
  }
}

class DepartmentRef {
  final String id;
  final String name;

  DepartmentRef({required this.id, required this.name});

  factory DepartmentRef.fromJson(Map<String, dynamic> json) {
    return DepartmentRef(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
