class PsuNotification {
  final String id;
  final String psuName;
  final String role;
  final String advtNo;
  final String location;
  final String datePosted;
  final String deadline;
  final bool isStatePsu;
  final String notificationLink; // 1. Added the property

  PsuNotification({
    required this.id,
    required this.psuName,
    required this.role,
    required this.advtNo,
    required this.location,
    required this.datePosted,
    required this.deadline,
    required this.isStatePsu,
    required this.notificationLink, // 2. Added to the constructor
  });

  factory PsuNotification.fromMap(Map<String, dynamic> map, String documentId) {
    return PsuNotification(
      id: documentId,
      psuName: map['psuName'] ?? '',
      role: map['role'] ?? '',
      advtNo: map['advtNo'] ?? 'Not Specified',
      location: map['location'] ?? '',
      datePosted: map['datePosted'] ?? '',
      deadline: map['deadline'] ?? '',
      isStatePsu: map['isStatePsu'] ?? false,
      // 3. Tells Flutter how to read the link from Firebase
      notificationLink: map['notificationLink'] ?? 'https://google.com',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'psuName': psuName,
      'role': role,
      'advtNo': advtNo,
      'location': location,
      'datePosted': datePosted,
      'deadline': deadline,
      'isStatePsu': isStatePsu,
      // 4. Tells Flutter how to save the link to Firebase
      'notificationLink': notificationLink,
    };
  }
}