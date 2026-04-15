import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/owner_provider.dart';
import 'providers/iot_provider.dart';
import 'services/connectivity_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/cart/presentation/screens/home_screen.dart';
import 'features/cart/presentation/screens/cart_screen.dart';
import 'features/qr_scanner/presentation/screens/qr_scanner_screen.dart';
import 'features/payment/presentation/screens/payment_screen.dart';
import 'features/orders/presentation/screens/orders_screen.dart';
import 'features/owner/presentation/screens/owner_dashboard_screen.dart';
import 'features/owner/presentation/screens/owner_add_product_screen.dart';
import 'features/owner/presentation/screens/owner_products_screen.dart';
import 'features/owner/presentation/screens/owner_customers_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/admin/presentation/screens/admin_add_product_screen.dart';
import 'features/admin/presentation/screens/admin_products_screen.dart';
// import 'features/admin/presentation/screens/admin_analytics_screen.dart';
// import 'features/admin/presentation/screens/admin_users_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firebase Analytics
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IotProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider2<IotProvider, AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, iot, auth, cart) {
            cart!.updateIotProvider(iot);
            if (auth.isAuthenticated && auth.currentUser != null) {
              cart.setUserId(auth.currentUser!.uid);
            } else {
              cart.clearAllData();
            }
            return cart;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(),
          update: (_, auth, product) {
            if (auth.isAuthenticated && (auth.isOwner || auth.isAdmin) && auth.currentUser != null) {
              product!.setOwnerId(auth.currentUser!.uid);
            } else {
              product!.clearAllData();
            }
            return product!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (_, auth, order) {
            if (auth.isAuthenticated && auth.currentUser != null) {
              order!.setUserId(auth.currentUser!.uid);
              if (auth.isOwner || auth.isAdmin) {
                order.setOwnerId(auth.currentUser!.uid);
              }
            } else {
              order!.clearAllData();
            }
            return order;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, OwnerProvider>(
          create: (_) => OwnerProvider(),
          update: (_, auth, owner) {
            if (auth.isAuthenticated && auth.isOwner && auth.currentUser != null) {
              owner!.setOwnerId(auth.currentUser!.uid);
            } else {
              owner!.clearAllData();
            }
            return owner!;
          },
        ),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: MaterialApp(
        title: 'Smart Trolley',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const HomeScreen(),
          '/cart': (_) => const CartScreen(),
          '/qr-scanner': (_) => const QRScannerScreen(),
          '/payment': (_) => const PaymentScreen(),
          '/orders': (_) => const OrdersScreen(),
          '/owner': (_) => const OwnerDashboardScreen(),
          '/owner-add-product': (_) => const OwnerAddProductScreen(),
          '/owner-products': (_) => const OwnerProductsScreen(),
          '/owner-customers': (_) => const OwnerCustomersScreen(),
          '/admin': (_) => const AdminDashboardScreen(),
          '/admin-products': (_) => const AdminProductsScreen(),
          '/admin-add-product': (_) => const AdminAddProductScreen(),
          // '/admin-analytics': (_) => const AdminAnalyticsScreen(),
          // '/admin-users': (_) => const AdminUsersScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated && authProvider.currentUser != null) {
          if (authProvider.isAdmin) {
            return const AdminDashboardScreen();
          }
          if (authProvider.isOwner) {
            return const OwnerDashboardScreen();
          }
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

