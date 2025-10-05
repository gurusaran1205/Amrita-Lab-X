import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// AmritaULABS app header with branding
class AppHeader extends StatelessWidget {
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double? height;
  final EdgeInsets? padding;

  const AppHeader({
    super.key,
    this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.largePadding,
      ),
      constraints: BoxConstraints(
        minHeight: screenHeight*0.12,
        maxHeight: screenHeight*0.20,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMaroon.withAlpha((255 * 0.1).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Back button and title row
            Row(
              children: [
                if (showBackButton)
                  IconButton(
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  )
                else
                  const SizedBox(width: 40), // Spacer for centering
                
                // App title
                Expanded(
                  child: _buildAppTitle(),
                ),
                
                const SizedBox(width: 40), // Right spacer for centering
              ],
            ),
            
            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build the AmritaULABS title with proper styling and alignment
  Widget _buildAppTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          // "Amrita" in black
          const TextSpan(
            text: 'Amrita',
            style: TextStyle(
              fontSize: AppConstants.titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.black90,
              letterSpacing: 0.5,
            ),
          ),
          // "ULABS" in white with maroon background - properly aligned
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryMaroon,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ULABS',
                style: TextStyle(
                  fontSize: AppConstants.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                  height: 1.0, // Ensures consistent line height
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple app title widget for use in other places
class AppTitle extends StatelessWidget {
  final double? fontSize;
  final MainAxisAlignment alignment;

  const AppTitle({
    super.key,
    this.fontSize,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Amrita',
          style: TextStyle(
            fontSize: fontSize ?? AppConstants.titleFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.black90,
            letterSpacing: 0.5,
            height: 1.0,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryMaroon,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'ULABS',
            style: TextStyle(
              fontSize: fontSize ?? AppConstants.titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              letterSpacing: 0.5,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

/// Welcome header with animation
class WelcomeHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget? icon;

  const WelcomeHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(height: 16),
                ],
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
