class AddressModel {
  final String id;
  final String userId;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phoneNo;
  final bool selectedAddress;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phoneNo,
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
      zipCode: json['zipCode'] ?? json['postal_code'] ?? '',
      country: json['country'] ?? '',
      phoneNo: json['phoneNo'] ?? json['phone_number'] ?? '',
      selectedAddress: json['selectedAddress'] ?? json['is_default'] ?? false,
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
      'postal_code': zipCode,
      'country': country,
      'phone_number': phoneNo,
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
    String? zipCode,
    String? country,
    String? phoneNo,
    bool? selectedAddress,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      phoneNo: phoneNo ?? this.phoneNo,
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
    zipCode: '',
    country: '',
    phoneNo: '',
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
              zipCode == other.zipCode &&
              country == other.country &&
              phoneNo == other.phoneNo &&
              selectedAddress == other.selectedAddress;

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    street,
    city,
    state,
    zipCode,
    country,
    phoneNo,
    selectedAddress,
  );
}