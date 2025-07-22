import 'package:cwt_ecommerce_app/features/personalization/models/address_model.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final String? socialProvider;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<AddressModel> addresses;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.socialProvider,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.addresses = const [],
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      profileImage: json['profile_image'],
      socialProvider: json['social_provider'],
      emailVerifiedAt: json['email_verified_at'] != null ? DateTime.parse(json['email_verified_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'social_provider': socialProvider,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static UserModel empty() => UserModel(
    id: '',
    firstName: '',
    lastName: '',
    username: '',
    email: '',
  );

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phoneNumber,
    String? profileImage,
    String? socialProvider,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      socialProvider: socialProvider ?? this.socialProvider,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addresses: addresses ?? this.addresses,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserModel &&
              id == other.id &&
              firstName == other.firstName &&
              lastName == other.lastName &&
              username == other.username &&
              email == other.email &&
              phoneNumber == other.phoneNumber &&
              profileImage == other.profileImage &&
              socialProvider == other.socialProvider &&
              emailVerifiedAt == other.emailVerifiedAt &&
              createdAt == other.createdAt &&
              updatedAt == other.updatedAt &&
              addresses == other.addresses;

  @override
  int get hashCode => Object.hash(
    id,
    firstName,
    lastName,
    username,
    email,
    phoneNumber,
    profileImage,
    socialProvider,
    emailVerifiedAt,
    createdAt,
    updatedAt,
    addresses,
  );
}