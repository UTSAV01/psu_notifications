class PsuNotification {
  final String id;
  final String psuName;
  final String role;
  final String location;
  final String datePosted;
  final String deadline;
  final bool isStatePsu;

  PsuNotification({
    required this.id,
    required this.psuName,
    required this.role,
    required this.location,
    required this.datePosted,
    required this.deadline,
    required this.isStatePsu,
  });

  factory PsuNotification.fromMap(Map<String, dynamic> map, String documentId) {
    return PsuNotification(
      id: documentId,
      psuName: map['psuName'] ?? '',
      role: map['role'] ?? '',
      location: map['location'] ?? '',
      datePosted: map['datePosted'] ?? '',
      deadline: map['deadline'] ?? '',
      isStatePsu: map['isStatePsu'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'psuName': psuName,
      'role': role,
      'location': location,
      'datePosted': datePosted,
      'deadline': deadline,
      'isStatePsu': isStatePsu,
    };
  }
}