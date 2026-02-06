/// App Spacing - Equivalent to: Tailwind/Material-UI spacing scale
/// 
/// MERN Comparison:
/// In React: const spacing = { xs: 4, sm: 8, md: 16, lg: 24, ... }
/// In Flutter: Static constants for consistent padding/margin throughout the app
/// 
/// This ensures consistency: all horizontal padding is one of these values,
/// creating a visual rhythm and making layouts predictable

abstract class AppSpacing {
  // ============= Minimal Spacing =============
  static const double xs = 4.0;    // For tight components
  static const double xsm = 6.0;   // Micro spacing

  // ============= Small Spacing =============
  static const double sm = 8.0;    // Padding within buttons, small gaps
  static const double smm = 10.0;  // Between small elements

  // ============= Medium Spacing =============
  static const double md = 12.0;   // Between rows
  static const double mdm = 14.0;  // Fine tuning

  // ============= Standard Spacing =============
  static const double lg = 16.0;   // Default padding for cards, containers
  static const double lgm = 18.0;  // Between sections

  // ============= Large Spacing =============
  static const double xl = 24.0;   // Between major sections
  static const double xlm = 28.0;  // Extra large spacing

  // ============= Extra Large Spacing =============
  static const double xxl = 32.0;  // Page-level spacing
  static const double xxxl = 40.0; // Between full-width sections
  static const double xxxlm = 48.0; // Maximum standard spacing

  // ============= Common Grouped Spacings =============
  /// Used for button heights, input field spacing
  static const double buttonHeight = 48.0;
  static const double buttonPadding = lg; // 16
  
  /// Used for card internal padding
  static const double cardPadding = lg; // 16
  static const double cardBorderRadius = 12.0;
  
  /// Used for screen/page edges
  static const double screenPadding = lg; // 16
  
  /// Used for small components (chips, badges)
  static const double smallComponentPadding = sm; // 8
}
