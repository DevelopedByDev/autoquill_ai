import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/design_tokens.dart';

/// A minimalist text input field that follows the design system guidelines
class MinimalistInput extends StatefulWidget {
  /// The controller for the text field
  final TextEditingController? controller;
  
  /// The label text for the input field
  final String? label;
  
  /// The placeholder text when the field is empty
  final String? placeholder;
  
  /// The helper text displayed below the input field
  final String? helperText;
  
  /// The error text displayed when there's an error
  final String? errorText;
  
  /// Whether the input field is disabled
  final bool isDisabled;
  
  /// Whether the input field is in a loading state
  final bool isLoading;
  
  /// Whether the input field is obscured (for passwords)
  final bool isObscured;
  
  /// Whether to show a toggle for obscured text
  final bool showObscureToggle;
  
  /// The prefix icon to display
  final IconData? prefixIcon;
  
  /// The suffix icon to display
  final IconData? suffixIcon;
  
  /// The callback when the suffix icon is pressed
  final VoidCallback? onSuffixIconPressed;
  
  /// The callback when the text changes
  final Function(String)? onChanged;
  
  /// The callback when the user submits the text
  final Function(String)? onSubmitted;
  
  /// The keyboard type for the input
  final TextInputType keyboardType;
  
  /// Input formatters for the text field
  final List<TextInputFormatter>? inputFormatters;
  
  /// The maximum number of lines for the input
  final int? maxLines;
  
  /// The minimum number of lines for the input
  final int? minLines;
  
  /// The maximum length of the input
  final int? maxLength;
  
  /// Whether to show the character counter
  final bool showCounter;
  
  /// Optional custom background color
  final Color? backgroundColor;
  
  /// Optional custom border color
  final Color? borderColor;
  
  /// Optional custom text color
  final Color? textColor;

  const MinimalistInput({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.isDisabled = false,
    this.isLoading = false,
    this.isObscured = false,
    this.showObscureToggle = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  State<MinimalistInput> createState() => _MinimalistInputState();
}

class _MinimalistInputState extends State<MinimalistInput> {
  bool _obscureText = true;
  
  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscured;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final defaultBgColor = isDarkMode 
        ? DesignTokens.darkSurface 
        : DesignTokens.lightSurface;
    
    final defaultTextColor = isDarkMode
        ? DesignTokens.trueWhite
        : DesignTokens.pureBlack;
    
    final defaultBorderColor = widget.errorText != null
        ? DesignTokens.vibrantCoral
        : Colors.transparent;
    
    // Apply disabled state
    Color bgColor = widget.backgroundColor ?? defaultBgColor;
    Color txtColor = widget.textColor ?? defaultTextColor;
    
    if (widget.isDisabled) {  
      bgColor = bgColor.withValues(alpha: DesignTokens.opacityDisabled);
      txtColor = txtColor.withValues(alpha: DesignTokens.opacityDisabled);
    }
    
    // Build suffix icon if needed
    Widget? suffixIconWidget;
    
    if (widget.isLoading) {
      suffixIconWidget = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDarkMode ? DesignTokens.trueWhite : DesignTokens.pureBlack,
          ),
        ),
      );
    } else if (widget.isObscured && widget.showObscureToggle) {
      suffixIconWidget = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: isDarkMode ? DesignTokens.trueWhite : DesignTokens.pureBlack,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffixIcon != null) {
      suffixIconWidget = IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: isDarkMode ? DesignTokens.trueWhite : DesignTokens.pureBlack,
          size: 20,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: DesignTokens.bodyMedium,
              fontWeight: DesignTokens.fontWeightMedium,
              color: txtColor,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXS),
        ],
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            border: Border.all(
              color: widget.borderColor ?? defaultBorderColor,
              width: widget.errorText != null ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isObscured && _obscureText,
            enabled: !widget.isDisabled,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            style: TextStyle(
              fontSize: DesignTokens.bodyMedium,
              color: txtColor,
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                color: txtColor.withValues(alpha: 0.5),
                fontSize: DesignTokens.bodyMedium,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: txtColor,
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIconWidget,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceSM,
                vertical: DesignTokens.spaceSM,
              ),
              counterText: widget.showCounter ? null : '',
            ),
          ),
        ),
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: DesignTokens.spaceXXS),
          Text(
            widget.errorText ?? widget.helperText ?? '',
            style: TextStyle(
              fontSize: DesignTokens.captionSize,
              color: widget.errorText != null
                  ? DesignTokens.vibrantCoral
                  : txtColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}
