class AddressModel {
  String id;
  String userId;
  final String name;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phoneNumber;
  bool selectedAddress;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
    required this.selectedAddress,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      name: json['name'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? json['zipCode'] ?? '',
      country: json['country'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNo'] ?? '',
      selectedAddress: json['is_default'] ?? json['selectedAddress'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'phone_number': phoneNumber,
      'is_default': selectedAddress,
    };
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phoneNumber,
    bool? selectedAddress,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }

  static AddressModel empty() => AddressModel(
    id: '',
    userId: '',
    name: '',
    street: '',
    city: '',
    state: '',
    postalCode: '',
    country: '',
    phoneNumber: '',
    selectedAddress: false,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AddressModel &&
              id == other.id &&
              userId == other.userId &&
              name == other.name &&
              street == other.street &&
              city == other.city &&
              state == other.state &&
              postalCode == other.postalCode &&
              country == other.country &&
              phoneNumber == other.phoneNumber &&
              selectedAddress == other.selectedAddress;

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    street,
    city,
    state,
    postalCode,
    country,
    phoneNumber,
    selectedAddress,
  );
}