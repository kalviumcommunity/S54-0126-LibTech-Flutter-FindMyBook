/// App Input Fields - Equivalent to: React form inputs + validation
/// 
/// MERN Comparison:
/// React: <input type="text" value={email} onChange={handleChange} />
/// Flutter: AppTextField(controller: emailCtrl, label: 'Email')
///
/// In MERN: Validation often happens in onChange handler + submit
/// In Flutter: Validation happens via validator callback + onChanged
///
/// This component handles:
/// - Real-time validation
/// - Error messages
/// - Focus states
/// - Keyboard types
/// - Password masking

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standard text input field with validation
/// 
/// Usage:
/// ```dart
/// AppTextField(
///   controller: titleController,
///   label: 'Book Title',
///   hint: 'Enter the title',
///   keyboardType: TextInputType.text,
///   validator: (value) {
///     if (value?.isEmpty ?? true) return 'Title is required';
///     return null;
///   },
/// )
/// ```
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? initialValue;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final int? maxLength;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool readOnly;
  final TextInputAction textInputAction;
  final String? counterText;
  final bool showCounter;
  final bool enabled;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final EdgeInsets contentPadding;

  const AppTextField({
    Key? key,
    this.controller,
    required this.label,
    this.hint,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.readOnly = false,
    this.textInputAction = TextInputAction.next,
    this.counterText,
    this.showCounter = false,
    this.enabled = true,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateField();
    }
  }

  void _validateField() {
    final value = widget.controller?.text ?? widget.initialValue ?? '';
    final error = widget.validator?.call(value);
    setState(() {
      _errorText = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              widget.label,
              style: AppTypography.labelLarge.copyWith(
                color: widget.enabled
                    ? AppColors.textPrimary
                    : AppColors.disabledText,
              ),
            ),
          ),

        // Text Field
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
            // Validate on change if there's an error
            if (_errorText != null) {
              _validateField();
            }
          },
          onTap: widget.onTap,
          validator: (value) {
            final error = widget.validator?.call(value);
            if (error != null) {
              _errorText = error;
            }
            return error;
          },
          style: AppTypography.bodyMedium.copyWith(
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.disabledText,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColor ?? AppColors.light,
            contentPadding: widget.contentPadding,
            hintText: widget.hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixTap,
                    child: Icon(
                      widget.suffixIcon,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            counterText: widget.showCounter ? widget.counterText : '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.borderColor ?? AppColors.border,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.borderColor ?? AppColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.focusedBorderColor ?? AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            errorStyle: AppTypography.labelSmall.copyWith(
              color: AppColors.error,
              height: 1.2,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

/// Password field with show/hide toggle
/// 
/// Usage:
/// ```dart
/// AppPasswordField(
///   controller: passwordCtrl,
///   label: 'Password',
///   validator: (value) {
///     if (value?.isEmpty ?? true) return 'Password required';
///     if (value!.length < 8) return 'Minimum 8 characters';
///     return null;
///   },
/// )
/// ```
class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppPasswordField({
    Key? key,
    this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint ?? 'Enter your password',
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      keyboardType: TextInputType.visiblePassword,
      suffixIcon: _obscureText ? Icons.visibility_off : Icons.visibility,
      onSuffixTap: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }
}

/// Search field with clear button
/// 
/// Usage:
/// ```dart
/// AppSearchField(
///   controller: searchCtrl,
///   onChanged: (query) => setState(() => _searchQuery = query),
///   onClear: () => searchCtrl.clear(),
/// )
/// ```
class AppSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;
  final void Function(String)? onSubmitted;

  const AppSearchField({
    Key? key,
    this.controller,
    this.hint = 'Search books...',
    this.onChanged,
    this.onClear,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _controller;
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateEmpty);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _updateEmpty() {
    setState(() {
      _isEmpty = _controller.text.isEmpty;
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    setState(() {
      _isEmpty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      label: '',
      hint: widget.hint,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: Icons.search,
      suffixIcon: _isEmpty ? null : Icons.clear,
      onSuffixTap: _clearSearch,
      onChanged: widget.onChanged,
      maxLines: 1,
    );
  }
}

/// Dropdown/Select field
/// 
/// Usage:
/// ```dart
/// AppDropdownField<String>(
///   label: 'Genre',
///   items: ['Fiction', 'Non-Fiction', 'Science'],
///   value: selectedGenre,
///   onChanged: (value) => setState(() => selectedGenre = value),
/// )
/// ```
class AppDropdownField<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String Function(T) itemLabel;
  final String? hint;

  const AppDropdownField({
    Key? key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    required this.itemLabel,
    this.hint,
  }) : super(key: key);

  @override
  State<AppDropdownField<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdownField<T>> {
  late T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              widget.label,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<T?>(
            value: _selectedValue,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            hint: Text(
              widget.hint ?? 'Select...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            items: widget.items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    widget.itemLabel(item),
                    style: AppTypography.bodyMedium,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              widget.onChanged?.call(value);
            },
          ),
        ),
      ],
    );
  }
}
