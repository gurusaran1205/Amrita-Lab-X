class Equipment {
  final String id;
  final String name;
  final String type; // e.g. major/minor
  final String modelNumber;
  final String description;
  final String status; // e.g. available/unavailable
  final LabRef? lab;
  final DateTime createdAt;
  final DateTime updatedAt;

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.modelNumber,
    required this.description,
    required this.status,
    this.lab,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      modelNumber: json['modelNumber'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      lab: json['lab'] is Map<String, dynamic>
          ? LabRef.fromJson(json['lab'])
          : (json['lab'] != null ? LabRef(id: json['lab'], name: "") : null),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type,
      "lab": lab?.id, // backend expects only lab ID
      "modelNumber": modelNumber,
      "description": description,
      "status": status,
    };
  }
}

class LabRef {
  final String id;
  final String name;

  LabRef({required this.id, required this.name});

  factory LabRef.fromJson(Map<String, dynamic> json) {
    return LabRef(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
