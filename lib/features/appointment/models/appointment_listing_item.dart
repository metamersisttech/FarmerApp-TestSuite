/// Lightweight listing model for the animal-selection dropdown
/// in the booking form.
class AppointmentListingItem {
  final int listingId;
  final String title;

  const AppointmentListingItem({
    required this.listingId,
    required this.title,
  });

  factory AppointmentListingItem.fromJson(Map<String, dynamic> json) {
    return AppointmentListingItem(
      listingId: json['listing_id'] as int? ?? json['id'] as int? ?? 0,
      title: json['title'] as String? ?? json['name'] as String? ?? 'Unknown',
    );
  }
}
