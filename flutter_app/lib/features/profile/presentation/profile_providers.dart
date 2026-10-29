import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikanku/features/profile/domain/profile.dart';

class AddressNotifier extends Notifier<List<Address>> {
  @override
  List<Address> build() => const [
        Address(id: 'a1', recipient: 'Miftahul Fazra', phone: '6285274088734', street: 'Jl. Nusantara No. 12', area: Kecamatan('Sekupang', 'Batam', '29425'), isPrimary: true),
      ];

  Address? get primary {
    for (final a in state) {
      if (a.isPrimary) return a;
    }
    return state.isEmpty ? null : state.first;
  }

  void add(Address a) {
    var list = List.of(state);
    if (a.isPrimary || list.isEmpty) {
      list = [for (final x in list) x.copyWith(isPrimary: false)];
      list.add(a.copyWith(isPrimary: true));
    } else {
      list.add(a);
    }
    state = list;
  }

  void setPrimary(String id) => state = [for (final a in state) a.copyWith(isPrimary: a.id == id)];

  void remove(String id) {
    final list = state.where((a) => a.id != id).toList();
    if (list.isNotEmpty && !list.any((a) => a.isPrimary)) list[0] = list[0].copyWith(isPrimary: true);
    state = list;
  }
}

final addressProvider = NotifierProvider<AddressNotifier, List<Address>>(AddressNotifier.new);

/// Alamat yang dipilih untuk checkout (null = pakai alamat utama).
class SelectedAddressNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

final selectedAddressIdProvider = NotifierProvider<SelectedAddressNotifier, String?>(SelectedAddressNotifier.new);

/// Kecamatan yang baru dipilih dari layar "Pilih Kecamatan".
class PickedKecamatanNotifier extends Notifier<Kecamatan?> {
  @override
  Kecamatan? build() => null;
  void pick(Kecamatan? k) => state = k;
}

final pickedKecamatanProvider = NotifierProvider<PickedKecamatanNotifier, Kecamatan?>(PickedKecamatanNotifier.new);
