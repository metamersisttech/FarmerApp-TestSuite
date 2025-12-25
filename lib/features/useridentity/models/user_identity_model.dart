import 'package:flutter/material.dart';

/// Represents a user identity/role option with metadata
class UserIdentityModel {
  final String code;
  final String name;
  final IconData icon;

  const UserIdentityModel({
    required this.code,
    required this.name,
    required this.icon,
  });

  /// Predefined list of supported user identities
  static const List<UserIdentityModel> supportedIdentities = [
    UserIdentityModel(
      code: 'farmer',
      name: 'Farmer',
      icon: Icons.agriculture,
    ),
    UserIdentityModel(
      code: 'broker',
      name: 'Broker',
      icon: Icons.handshake,
    ),
    UserIdentityModel(
      code: 'veterinarian',
      name: 'Veterinarian',
      icon: Icons.medical_services,
    ),
    UserIdentityModel(
      code: 'transporter',
      name: 'Transporter',
      icon: Icons.local_shipping,
    ),
    UserIdentityModel(
      code: 'buyer',
      name: 'Buyer/Company',
      icon: Icons.business,
    ),
  ];
}

