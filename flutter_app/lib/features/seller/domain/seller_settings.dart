class BankAccount {
  const BankAccount({required this.bank, required this.number, required this.holder});
  final String bank;
  final String number;
  final String holder;
}

class SellerSettings {
  const SellerSettings({
    this.shopName = 'Tibelat Farm',
    this.shippingFee = 10000,
    this.freeShippingMin = 0,
    this.transferEnabled = true,
    this.codEnabled = true,
    this.deliveryEnabled = true,
    this.pickupEnabled = true,
    this.banks = const [BankAccount(bank: 'BCA', number: '9834762649', holder: 'Tibelat Farm')],
  });

  final String shopName;
  final int shippingFee;

  /// Subtotal minimum untuk gratis ongkir; 0 = nonaktif.
  final int freeShippingMin;
  final bool transferEnabled;
  final bool codEnabled;
  final bool deliveryEnabled;
  final bool pickupEnabled;
  final List<BankAccount> banks;

  int feeFor(int subtotal) => (freeShippingMin > 0 && subtotal >= freeShippingMin) ? 0 : shippingFee;

  SellerSettings copyWith({String? shopName, int? shippingFee, int? freeShippingMin, bool? transferEnabled, bool? codEnabled, bool? deliveryEnabled, bool? pickupEnabled, List<BankAccount>? banks}) => SellerSettings(
        shopName: shopName ?? this.shopName,
        shippingFee: shippingFee ?? this.shippingFee,
        freeShippingMin: freeShippingMin ?? this.freeShippingMin,
        transferEnabled: transferEnabled ?? this.transferEnabled,
        codEnabled: codEnabled ?? this.codEnabled,
        deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
        pickupEnabled: pickupEnabled ?? this.pickupEnabled,
        banks: banks ?? this.banks,
      );
}
