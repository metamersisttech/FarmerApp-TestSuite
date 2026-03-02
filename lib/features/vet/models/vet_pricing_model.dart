/// Vet pricing model
///
/// Maps the response from GET /api/vets/me/pricing/
class VetPricingModel {
  final String? consultationFee;
  final String? videoConsultationFee;
  final String? homeVisitFee;
  final String? emergencyFeeMultiplier;

  const VetPricingModel({
    this.consultationFee,
    this.videoConsultationFee,
    this.homeVisitFee,
    this.emergencyFeeMultiplier,
  });

  factory VetPricingModel.fromJson(Map<String, dynamic> json) {
    return VetPricingModel(
      consultationFee: json['consultation_fee']?.toString(),
      videoConsultationFee: json['video_consultation_fee']?.toString(),
      homeVisitFee: json['home_visit_fee']?.toString(),
      emergencyFeeMultiplier: json['emergency_fee_multiplier']?.toString(),
    );
  }

  /// toJson for PATCH — only includes non-null, non-empty fields
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (consultationFee != null && consultationFee!.isNotEmpty) {
      data['consultation_fee'] = consultationFee;
    }
    if (videoConsultationFee != null && videoConsultationFee!.isNotEmpty) {
      data['video_consultation_fee'] = videoConsultationFee;
    }
    if (homeVisitFee != null && homeVisitFee!.isNotEmpty) {
      data['home_visit_fee'] = homeVisitFee;
    }
    if (emergencyFeeMultiplier != null && emergencyFeeMultiplier!.isNotEmpty) {
      data['emergency_fee_multiplier'] = emergencyFeeMultiplier;
    }
    return data;
  }
}
