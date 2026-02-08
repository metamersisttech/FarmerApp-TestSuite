/// Requestor (farmer) info embedded in vet-side appointment response.
///
/// Unlike `AppointmentVetInfo`, the phone is always visible to the vet.
class AppointmentRequestorInfo {
  final int userId;
  final String name;
  final String phone;

  const AppointmentRequestorInfo({
    required this.userId,
    required this.name,
    required this.phone,
  });

  factory AppointmentRequestorInfo.fromJson(Map<String, dynamic> json) {
    return AppointmentRequestorInfo(
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}
