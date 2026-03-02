import 'package:flutter/material.dart';

/// Navigation service for vet dashboard screens.
class VetDashboardNavigationService {
  static void toVetAppointments(BuildContext context) {
    Navigator.pushNamed(context, '/vet-appointments');
  }

  static void toVetAvailability(BuildContext context) {
    Navigator.pushNamed(context, '/vet-availability');
  }

  static void toVetPricing(BuildContext context) {
    Navigator.pushNamed(context, '/vet-pricing');
  }

  static void toVetProfile(BuildContext context) {
    Navigator.pushNamed(context, '/vet-profile');
  }

  static void toVetDashboardProfile(BuildContext context) {
    Navigator.pushNamed(context, '/vet-dashboard-profile');
  }
}
