// ignore_for_file: unused_import

import 'package:amrita_ulabs/providers/availability_provider.dart';
import 'package:amrita_ulabs/screens/admin_screen/add_department_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/lab_staff_dashboard_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/add_lab_screen.dart';
import 'package:amrita_ulabs/screens/admin_screen/add_equipment_screen.dart';
import 'package:amrita_ulabs/providers/qr_provider.dart';
import 'package:amrita_ulabs/screens/admin_screen/qr_management_screen.dart';
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
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, prev) {
            prev?.updateAuthProvider(auth);
            return prev ??
                QrProvider(
                    authProvider:
                        Provider.of<AuthProvider>(context, listen: false));
          },
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildAppTheme(),
        initialRoute: '/login',
        routes: {
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
        },
      ),
    );
  }

  /// Build custom theme for AmritaULABS
  ThemeData _buildAppTheme() {
    return ThemeData(
      // Color scheme based on Amrita branding
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryMaroon,
        brightness: Brightness.light,
        primary: AppColors.primaryMaroon,
        secondary: AppColors.black90,
        surface: AppColors.background,
        background: AppColors.background,
        error: AppColors.error,
      ),

      // Typography using Google Fonts
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        displayLarge: GoogleFonts.roboto(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.roboto(
          fontSize: AppConstants.titleFontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.roboto(
          fontSize: AppConstants.headingFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: AppConstants.bodyFontSize,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: AppConstants.captionFontSize,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: AppConstants.smallFontSize,
          color: AppColors.textLight,
        ),
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: AppConstants.headingFontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          elevation: 2,
          textStyle: GoogleFonts.roboto(
            fontSize: AppConstants.bodyFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.defaultPadding,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: const BorderSide(
            color: AppColors.inputFocusBorder,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(
          fontSize: AppConstants.bodyFontSize,
          color: AppColors.textSecondary,
        ),
        hintStyle: GoogleFonts.roboto(
          fontSize: AppConstants.bodyFontSize,
          color: AppColors.textLight,
        ),
        errorStyle: GoogleFonts.roboto(
          fontSize: AppConstants.captionFontSize,
          color: AppColors.error,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 4,
        shadowColor: AppColors.primaryMaroon.withAlpha((255 * 0.1).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        ),
      ),

      // Scaffold background
      scaffoldBackgroundColor: AppColors.background,

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}