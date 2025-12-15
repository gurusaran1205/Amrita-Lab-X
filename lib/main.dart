import 'package:amrita_ulabs/providers/availability_provider.dart';
import 'package:amrita_ulabs/providers/booking_provider.dart';
import 'package:amrita_ulabs/providers/user_provider.dart';
import 'package:amrita_ulabs/providers/session_provider.dart'; // Added import
import 'package:amrita_ulabs/screens/admin_screen/add_department_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/approve_requests_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/approve_logout_screen.dart'; // Added import
import 'package:amrita_ulabs/screens/admin_screen/block_users_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/lab_staff_dashboard_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/add_lab_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/add_equipment_screen.dart';
import 'package:amrita_ulabs/providers/qr_provider.dart';
import 'package:amrita_ulabs/screens/admin_screen/qr_management_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/reports_screen.dart'; // Added Import
import 'package:amrita_ulabs/screens/admin_screen/edit_department_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/delete_department_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/manage_departments_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/edit_lab_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/manage_labs_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/delete_lab_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/edit_equipment_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/manage_equipments_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/delete_equipment_screen.dart';
import 'package:amrita_ulabs/screens/login_screen.dart';
import 'package:amrita_ulabs/screens/main_navigation.dart';
import 'package:amrita_ulabs/screens/my_bookings_screen.dart';
import 'package:amrita_ulabs/screens/qr_scanner_screen.dart';
import 'package:amrita_ulabs/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/colors.dart';
import 'utils/constants.dart';
import 'providers/auth_provider.dart';
import 'screens/signup_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/success_screen.dart';
import 'providers/equipment_provider.dart';
import 'screens/equipment_selection.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AmritaULabsApp());
}

class AmritaULabsApp extends StatelessWidget {
  const AmritaULabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, EquipmentProvider>(
          create: (context) => EquipmentProvider(
              authProvider: Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, prev) =>
              EquipmentProvider(authProvider: auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AvailabilityProvider>(
          create: (context) => AvailabilityProvider(
              authProvider: Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, prev) =>
              AvailabilityProvider(authProvider: auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, QrProvider>(
          create: (context) => QrProvider(
              authProvider: Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, prev) {
            prev?.updateAuthProvider(auth);
            return prev ?? QrProvider(authProvider: auth);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, BookingProvider>(
          create: (context) => BookingProvider(
              authProvider: Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, _) => BookingProvider(authProvider: auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(
              authProvider: Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, _) => UserProvider(authProvider: auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SessionProvider>(
          create: (context) => SessionProvider(
              authProvider: Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, _) => SessionProvider(authProvider: auth),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildAppTheme(),
        initialRoute: '/splash',

        // NO DUPLICATES OF edit/delete HERE
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/otp': (context) => const OtpVerificationScreen(),
          '/success': (context) => const SuccessScreen(),
          '/equipment': (context) => const EquipmentSelectionPage(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/reset-password': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final email = (args is String) ? args : "";
            return ResetPasswordScreen(email: email);
          },
          '/main_navigation': (context) => const MainNavigation(),
          '/my_bookings': (context) => const MyBookingsScreen(),
          '/qr_scanner': (context) => const QRScannerScreen(),
          '/lab_staff_dashboard': (context) => const LabStaffDashboardScreen(),
          '/add_department': (context) => const AddDepartmentScreen(),
          '/add_lab': (context) => const AddLabScreen(),
          '/add_equipment': (context) => const AddEquipmentScreen(),
          '/qr_management': (context) => const QrManagementScreen(),
          '/approve_requests': (context) => const ApproveRequestsScreen(),
          '/approve_logout': (context) => const ApproveLogoutScreen(), // Added route
          '/block_users': (context) => const BlockUsersScreen(),
          '/manage_departments': (context) => const ManageDepartmentsScreen(),
          '/delete_department': (context) => const DeleteDepartmentScreen(),
          '/manage_labs': (context) => const ManageLabsScreen(),
          '/delete_lab': (context) => const DeleteLabScreen(),
          '/edit_lab': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;

            if (args == null ||
                args['id'] == null ||
                args['name'] == null ||
                args['location'] == null ||
                args['departmentId'] == null) {
              return const ErrorScreen();
            }

            return EditLabScreen(
              labId: args['id'],
              initialName: args['name'],
              initialLocation: args['location'],
              departmentId: args['departmentId'],
            );
          },
          '/manage_equipments': (context) => const ManageEquipmentsScreen(),
          '/delete_equipment': (context) => const DeleteEquipmentScreen(),
          '/reports': (context) => const ReportsScreen(showAppBar: true), // Added Route
          '/edit_equipment': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;

            if (args == null ||
                args['id'] == null ||
                args['name'] == null ||
                args['type'] == null ||
                args['modelNumber'] == null ||
                args['description'] == null ||
                args['status'] == null ||
                args['labId'] == null) {
              return const ErrorScreen();
            }

            return EditEquipmentScreen(
              equipmentId: args['id'],
              initialName: args['name'],
              initialType: args['type'],
              initialModel: args['modelNumber'],
              initialDescription: args['description'],
              initialStatus: args['status'],
              labId: args['labId'],
            );
          },
          '/edit_department': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;

            if (args == null ||
                args['id'] == null ||
                args['name'] == null ||
                args['description'] == null) {
              return const ErrorScreen();
            }

            return EditDepartmentScreen(
              departmentId: args['id'],
              initialName: args['name'],
              initialDescription: args['description'],
            );
          },
        },
      ),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryMaroon,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
      scaffoldBackgroundColor: AppColors.background,
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Error: Missing arguments")),
    );
  }
}
