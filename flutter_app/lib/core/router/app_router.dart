import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/router/tab_reselect.dart';
import 'package:ikanku/core/widgets/widgets.dart';
import 'package:ikanku/features/orders/domain/orders.dart';
import 'package:ikanku/features/orders/presentation/order_providers.dart';
import 'package:ikanku/features/admin/presentation/admin_screens.dart';
import 'package:ikanku/features/auth/domain/auth.dart';
import 'package:ikanku/features/auth/presentation/auth_providers.dart';
import 'package:ikanku/features/auth/presentation/auth_screens.dart';
import 'package:ikanku/features/cart/presentation/cart_screen.dart';
import 'package:ikanku/features/catalog/presentation/catalog_screens.dart';
import 'package:ikanku/features/common/presentation/common_screens.dart';
import 'package:ikanku/features/orders/presentation/buyer_order_screens.dart';
import 'package:ikanku/features/orders/presentation/checkout_screens.dart';
import 'package:ikanku/features/profile/presentation/profile_screens.dart';
import 'package:ikanku/features/seller/presentation/seller_order_screens.dart';
import 'package:ikanku/features/seller/presentation/seller_product_screens.dart';
import 'package:ikanku/features/seller/presentation/seller_settings_screens.dart';

const _publicPaths = {'/', '/login', '/register', '/register/otp', '/register/data', '/forgot', '/offline', '/pick-kecamatan', '/pick-location'};
const _guestOnly = {'/', '/login', '/register', '/register/otp', '/register/data', '/forgot'};
const _buyerPrefixes = ['/home', '/search', '/profile', '/cart', '/checkout', '/category', '/recommendations', '/product', '/payment', '/order-success', '/addresses', '/shop', '/orders', '/help'];

String homeFor(UserRole r) => switch (r) {
      UserRole.seller => '/seller',
      UserRole.admin => '/admin',
      UserRole.buyer => '/home',
    };

bool _isAdminPath(String p) => p == '/admin' || p.startsWith('/admin/');

/// Logika redirect murni (dapat diuji): peran dan status login menentukan rute yang boleh diakses.
String? computeRedirect(AppUser? user, String path) {
  if (user == null) return _publicPaths.contains(path) ? null : '/login';
  if (_guestOnly.contains(path)) {
    // Alur registrasi menyelesaikan dirinya sendiri lewat state login.
    return homeFor(user.role);
  }
  if (user.role == UserRole.admin) return _isAdminPath(path) || path == '/offline' ? null : '/admin';
  if (_isAdminPath(path)) return homeFor(user.role);
  if (user.role == UserRole.buyer && path.startsWith('/seller')) return '/home';
  if (user.role == UserRole.seller && _buyerPrefixes.any((p) => path == p || path.startsWith('$p/'))) return '/seller';
  return null;
}

class _AuthListenable extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable();
  ref.listen(authProvider, (_, _) => listenable.ping());
  ref.onDispose(listenable.dispose);
  final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: listenable,
    redirect: (context, state) => computeRedirect(ref.read(authProvider), state.uri.path),
    routes: [
      GoRoute(path: '/', builder: (_, _) => const StartupScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPhoneScreen(), routes: [
        GoRoute(path: 'otp', builder: (_, _) => const OtpScreen()),
        GoRoute(path: 'data', builder: (_, _) => const RegisterDataScreen()),
      ]),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/offline', builder: (_, _) => const OfflineScreen()),
      GoRoute(path: '/pick-kecamatan', builder: (_, _) => const PickKecamatanScreen()),
      GoRoute(path: '/admin', builder: (_, _) => const AdminHomeScreen()),

      // Pembeli: shell dengan bottom nav Beranda / Telusuri / Profil.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => _ShellScaffold(shell: shell, items: _buyerNav, badgeIndex: 2, badgeLabel: 'pesanan aktif'),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            GoRoute(path: '/recommendations', builder: (_, _) => const RecommendationsScreen()),
            GoRoute(path: '/category/:name', builder: (_, s) => CategoryScreen(category: s.pathParameters['name']!)),
                ]),
          StatefulShellBranch(routes: [GoRoute(path: '/search', builder: (_, _) => const SearchScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
                        GoRoute(path: '/help', builder: (_, _) => const HelpCenterScreen()),
          ]),
        ],
      ),
      GoRoute(path: '/product/:id', builder: (_, s) => ProductDetailScreen(productId: s.pathParameters['id']!)),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (_, _) => const CheckoutScreen()),
      GoRoute(path: '/payment/:id', builder: (_, s) => PaymentScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/order-success/:id', builder: (_, s) => OrderSuccessScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/orders', builder: (_, s) => BuyerOrdersScreen(initialTab: int.tryParse(s.uri.queryParameters['tab'] ?? '') ?? 0)),
      GoRoute(path: '/orders/:id', builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/orders/:id/rejected', builder: (_, s) => OrderRejectedScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/orders/:id/review', builder: (_, s) => ReviewScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/orders/:id/review/view', builder: (_, s) => ViewReviewScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/profile/data', builder: (_, _) => const ProfileDataScreen()),
      GoRoute(path: '/profile/password', builder: (_, _) => const ChangePasswordScreen()),
      GoRoute(path: '/profile/email', builder: (_, _) => const ChangeContactScreen(isEmail: true)),
      GoRoute(path: '/profile/phone', builder: (_, _) => const ChangeContactScreen(isEmail: false)),
      GoRoute(path: '/addresses', builder: (_, s) => AddressListScreen(pick: s.uri.queryParameters['pick'] == '1')),
      GoRoute(path: '/addresses/add', builder: (_, _) => const AddAddressScreen()),

      // Penjual: shell Beranda / Produk / Pengaturan.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => _ShellScaffold(shell: shell, items: _sellerNav),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/seller', builder: (_, _) => const SellerHomeScreen()),
                      ]),
          StatefulShellBranch(routes: [GoRoute(path: '/seller/products', builder: (_, _) => const SellerProductsScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/seller/settings', builder: (_, _) => const SellerSettingsScreen()),
            GoRoute(path: '/seller/help', builder: (_, _) => const HelpCenterScreen()),
          ]),
        ],
      ),
      GoRoute(path: '/seller/orders', builder: (_, s) => SellerOrdersScreen(initialTab: int.tryParse(s.uri.queryParameters['tab'] ?? '') ?? 0)),
      GoRoute(path: '/seller/orders/:id', builder: (_, s) => SellerOrderDetailScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/seller/orders/:id/ship', builder: (_, s) => ShipProofScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/seller/reviews', builder: (_, _) => const SellerReviewsScreen()),
      GoRoute(path: '/seller/products/new', builder: (_, _) => const ProductFormScreen()),
      GoRoute(path: '/seller/products/:id', builder: (_, s) => SellerProductDetailScreen(productId: s.pathParameters['id']!)),
      GoRoute(path: '/seller/products/:id/edit', builder: (_, s) => ProductFormScreen(productId: s.pathParameters['id'])),
      GoRoute(path: '/seller/products/:id/variants', builder: (_, s) => VariantsScreen(productId: s.pathParameters['id']!)),
      GoRoute(path: '/seller/categories/new', builder: (_, _) => const AddCategoryScreen()),
      GoRoute(path: '/seller/categories/:name/edit', builder: (_, s) => AddCategoryScreen(editing: s.pathParameters['name'])),
      GoRoute(path: '/pick-location', builder: (_, _) => const PickLocationScreen()),
      GoRoute(path: '/shop/:name', builder: (_, s) => ShopScreen(name: s.pathParameters['name']!)),
      GoRoute(path: '/seller/discount', builder: (_, _) => const DiscountScreen()),
      GoRoute(path: '/seller/ongkir', builder: (_, _) => const OngkirScreen()),
      GoRoute(path: '/seller/payment-methods', builder: (_, _) => const PaymentMethodsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

const _buyerNav = [BarItem(Icons.home_outlined, Icons.home, 'Beranda'), BarItem(Icons.search, Icons.search, 'Telusuri'), BarItem(Icons.account_circle_outlined, Icons.account_circle, 'Profil')];
const _sellerNav = [BarItem(Icons.home_outlined, Icons.home, 'Beranda'), BarItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Produk'), BarItem(Icons.settings_outlined, Icons.settings, 'Pengaturan')];

/// Shell dengan bottom bar putih (pil terpilih). Layar level-jelajah berada di dalam cabang shell sehingga bar selalu tampil.
class _ShellScaffold extends ConsumerWidget {
  const _ShellScaffold({required this.shell, required this.items, this.badgeIndex, this.badgeLabel});
  final int? badgeIndex;
  final String? badgeLabel;
  final StatefulNavigationShell shell;
  final List<BarItem> items;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Badge: jumlah pesanan aktif (menunggu, dikemas, dikirim) pada tab Profil, dari data yang sudah ada.
    final active = badgeIndex == null ? 0 : ref.watch(ordersProvider).where((o) => o.status == OrderStatus.menunggu || o.status == OrderStatus.dikemas || o.status == OrderStatus.dikirim).length;
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomBar(
        items: items,
        index: shell.currentIndex,
        badgeIndex: badgeIndex,
        badgeCount: active,
        badgeLabel: badgeLabel,
        onTap: (i) {
          if (i == shell.currentIndex) ref.read(tabReselectProvider.notifier).fire(i);
          shell.goBranch(i, initialLocation: i == shell.currentIndex);
        },
      ),
    );
  }
}
