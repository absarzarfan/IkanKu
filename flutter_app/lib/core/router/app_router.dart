import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikanku/core/theme/app_theme.dart';
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

const _publicPaths = {'/', '/login', '/register', '/register/otp', '/register/data', '/forgot', '/offline', '/pick-kecamatan'};
const _guestOnly = {'/', '/login', '/register', '/register/otp', '/register/data', '/forgot'};
const _buyerPrefixes = ['/home', '/search', '/profile', '/cart', '/checkout', '/category', '/recommendations', '/product', '/payment', '/order-success', '/addresses'];

String homeFor(UserRole r) => r == UserRole.seller ? '/seller' : '/home';

/// Logika redirect murni (dapat diuji): peran dan status login menentukan rute yang boleh diakses.
String? computeRedirect(AppUser? user, String path) {
  if (user == null) return _publicPaths.contains(path) ? null : '/login';
  if (_guestOnly.contains(path)) {
    // Alur registrasi menyelesaikan dirinya sendiri lewat state login.
    return homeFor(user.role);
  }
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
    initialLocation: '/',
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
      GoRoute(path: '/help', builder: (_, _) => const HelpCenterScreen()),

      // Pembeli: shell dengan bottom nav Beranda / Telusuri / Profil.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => _ShellScaffold(shell: shell, items: _buyerNav),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/search', builder: (_, _) => const SearchScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())]),
        ],
      ),
      GoRoute(path: '/category/:name', builder: (_, s) => CategoryScreen(category: s.pathParameters['name']!)),
      GoRoute(path: '/recommendations', builder: (_, _) => const RecommendationsScreen()),
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
          StatefulShellBranch(routes: [GoRoute(path: '/seller', builder: (_, _) => const SellerHomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/seller/products', builder: (_, _) => const SellerProductsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/seller/settings', builder: (_, _) => const SellerSettingsScreen())]),
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
      GoRoute(path: '/seller/discount', builder: (_, _) => const DiscountScreen()),
      GoRoute(path: '/seller/ongkir', builder: (_, _) => const OngkirScreen()),
      GoRoute(path: '/seller/payment-methods', builder: (_, _) => const PaymentMethodsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

const _buyerNav = [(Icons.home_outlined, 'Beranda'), (Icons.search, 'Telusuri'), (Icons.account_circle_outlined, 'Profil')];
const _sellerNav = [(Icons.home_outlined, 'Beranda'), (Icons.inventory_2_outlined, 'Produk'), (Icons.settings_outlined, 'Pengaturan')];

/// Bottom nav biru melengkung (Figma "Tab Bar pembeli" 6443:15697).
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.shell, required this.items});
  final StatefulNavigationShell shell;
  final List<(IconData, String)> items;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(children: [
              for (final (i, it) in items.indexed)
                Expanded(
                  child: InkWell(
                    onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(it.$1, color: Colors.white.withValues(alpha: i == shell.currentIndex ? 1 : 0.7)),
                      Text(it.$2, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white, fontWeight: i == shell.currentIndex ? FontWeight.w600 : FontWeight.w400)),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
