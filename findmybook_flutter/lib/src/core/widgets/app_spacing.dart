/// App Spacing Helpers - Equivalent to: Tailwind margin/padding utilities
/// 
/// MERN Comparison:
/// Tailwind CSS: <div className="p-4 mb-6">...</div>
/// Flutter: AppPadding(padding: 16, child: AppGap(gap: 24, child: ...))
///
/// These components provide consistent spacing throughout the app
/// and reduce repetitive SizedBox usage

import 'package:flutter/material.dart';

/// AppPadding - Wraps widget with consistent padding
/// 
/// Usage:
/// ```dart
/// AppPadding(
///   padding: 16,
///   child: Text('Content'),
/// )
/// ```
class AppPadding extends StatelessWidget {
  final double? all;
  final double? horizontal;
  final double? vertical;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final Widget child;

  const AppPadding({
    Key? key,
    this.all,
    this.horizontal,
    this.vertical,
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.child,
  })  : assert(
          all == null ||
              (horizontal == null &&
                  vertical == null &&
                  top == null &&
                  right == null &&
                  bottom == null &&
                  left == null),
          'Cannot specify both all and individual padding values',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (all != null) {
      return Padding(
        padding: EdgeInsets.all(all!),
        child: child,
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: top ?? vertical ?? 0,
        right: right ?? horizontal ?? 0,
        bottom: bottom ?? vertical ?? 0,
        left: left ?? horizontal ?? 0,
      ),
      child: child,
    );
  }
}

/// AppGap - Vertical spacing between widgets in Column
/// Equivalent to CSS gap property in flexbox
/// 
/// Usage:
/// ```dart
/// AppGap(
///   gap: 16,
///   children: [
///     Text('Title'),
///     Text('Subtitle'),
///   ],
/// )
/// ```
class AppGap extends StatelessWidget {
  final double gap;
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const AppGap({
    Key? key,
    required this.gap,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(height: gap),
        ]
      ],
    );
  }
}

/// AppHorizontalGap - Horizontal spacing between widgets in Row
/// 
/// Usage:
/// ```dart
/// AppHorizontalGap(
///   gap: 12,
///   children: [
///     Icon(Icons.star),
///     Text('Rating'),
///   ],
/// )
/// ```
class AppHorizontalGap extends StatelessWidget {
  final double gap;
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const AppHorizontalGap({
    Key? key,
    required this.gap,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Flexible(child: children[i]),
          if (i < children.length - 1) SizedBox(width: gap),
        ]
      ],
    );
  }
}

/// AppSpacer - Empty space with flexible sizing
/// Equivalent to Spacer() in Flutter
/// 
/// Usage:
/// ```dart
/// Row(
///   children: [
///     Text('Left'),
///     AppSpacer(),
///     Text('Right'),
///   ],
/// )
/// ```
class AppSpacer extends StatelessWidget {
  final double flex;

  const AppSpacer({
    Key? key,
    this.flex = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex.toInt(),
      child: const SizedBox.expand(),
    );
  }
}

/// AppVerticalDivider - Vertical spacing with optional divider line
/// 
/// Usage:
/// ```dart
/// AppVerticalDivider(height: 24)
/// ```
class AppVerticalDivider extends StatelessWidget {
  final double height;
  final bool showDivider;
  final Color? dividerColor;
  final double dividerThickness;

  const AppVerticalDivider({
    Key? key,
    this.height = 16,
    this.showDivider = false,
    this.dividerColor,
    this.dividerThickness = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showDivider) {
      return SizedBox(height: height);
    }

    return Divider(
      height: height,
      color: dividerColor ?? Theme.of(context).dividerColor,
      thickness: dividerThickness,
    );
  }
}

/// AppBox - Creates a box with optional border and shadow
/// Shortcut for Container with common styling
/// 
/// Usage:
/// ```dart
/// AppBox(
///   padding: 16,
///   backgroundColor: Colors.blue,
///   borderRadius: 8,
///   child: Text('Content'),
/// )
/// ```
class AppBox extends StatelessWidget {
  final Widget child;
  final double? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final BoxShape shape;

  const AppBox({
    Key? key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.shape = BoxShape.rectangle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding != null ? EdgeInsets.all(padding!) : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius ?? 0)
            : null,
        border: border,
        boxShadow: boxShadow,
        shape: shape,
      ),
      child: child,
    );
  }
}
