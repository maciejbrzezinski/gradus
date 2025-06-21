import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GradusTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  const GradusTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<GradusTextField> createState() => _GradusTextFieldState();
}

class _GradusTextFieldState extends State<GradusTextField> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(duration: AppTheme.animationDuration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(CurvedAnimation(parent: _animationController, curve: AppTheme.animationCurve));

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null) ...[
                AnimatedDefaultTextStyle(
                  duration: AppTheme.fastAnimation,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: _isFocused ? AppTheme.primaryColor : AppTheme.textSecondary,
                    fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(widget.label!),
                ),
                const SizedBox(height: AppTheme.spacing8),
              ],
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  enabled: widget.enabled,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  textInputAction: widget.textInputAction,
                  autofocus: widget.autofocus,
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  onSubmitted: widget.onSubmitted,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    errorText: widget.errorText,
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.suffixIcon,
                    filled: true,
                    fillColor: _isFocused ? AppTheme.surface.withValues(alpha: 0.8) : AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      borderSide: const BorderSide(color: AppTheme.error, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
