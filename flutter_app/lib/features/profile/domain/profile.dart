class Kecamatan {
  const Kecamatan(this.name, this.city, this.postalCode);
  final String name;
  final String city;
  final String postalCode;
  @override
  String toString() => '$city, $name, $postalCode';
}

/// Data mock; Kotlin mengambilnya dari GET api/kecamatan dan api/kodepos/{id}.
const mockKecamatan = [
  Kecamatan('Sekupang', 'Batam', '29425'),
  Kecamatan('Batam Kota', 'Batam', '29444'),
  Kecamatan('Lubuk Baja', 'Batam', '29432'),
  Kecamatan('Nongsa', 'Batam', '29466'),
  Kecamatan('Bengkong', 'Batam', '29457'),
  Kecamatan('Batu Ampar', 'Batam', '29452'),
];

class Address {
  const Address({required this.id, required this.recipient, required this.phone, required this.street, required this.area, this.isPrimary = false});
  final String id;
  final String recipient;
  final String phone;
  final String street;
  final Kecamatan area;
  final bool isPrimary;

  String get full => '$street, ${area.name}, ${area.city} ${area.postalCode}';

  Address copyWith({bool? isPrimary}) => Address(id: id, recipient: recipient, phone: phone, street: street, area: area, isPrimary: isPrimary ?? this.isPrimary);
}
