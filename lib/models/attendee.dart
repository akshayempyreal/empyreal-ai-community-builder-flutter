class Attendee {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String registeredAt;
  final String status; // 'registered', 'confirmed', 'checked-in', 'cancelled'

  Attendee({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.registeredAt,
    required this.status,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      registeredAt: json['registeredAt'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'registeredAt': registeredAt,
      'status': status,
    };
  }
}
