import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum GradusButtonType {
  primary,
  secondary,
  text,
  social,
}

class GradusButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final GradusButtonType type;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GradusButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = GradusButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.width,
    this.height,
  });

  const GradusButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.width,
    this.height,
  }) : type = GradusButtonType.primary;

  const GradusButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.width,
    this.height,
  }) : type = GradusButtonType.secondary;

  const GradusButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.width,
    this.height,
  }) : type = GradusButtonType.text;

  const GradusButton.social({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.width,
    this.height,
  }) : type = GradusButtonType.social;

  @override
  State<GradusButton> createState() => _GradusButtonState();
}

class _GradusButtonState extends State<GradusButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.99,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.fastCurve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.fastCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case GradusButtonType.primary:
        return AppTheme.primaryColor;
      case GradusButtonType.secondary:
        return Colors.transparent;
      case GradusButtonType.text:
        return Colors.transparent;
      case GradusButtonType.social:
        return Colors.white;
    }
  }

  Color _getForegroundColor() {
    switch (widget.type) {
      case GradusButtonType.primary:
        return AppTheme.textOnPrimary;
      case GradusButtonType.secondary:
        return AppTheme.primaryColor;
      case GradusButtonType.text:
        return AppTheme.primaryColor;
      case GradusButtonType.social:
        return AppTheme.textPrimary;
    }
  }

  BorderSide? _getBorderSide() {
    switch (widget.type) {
      case GradusButtonType.primary:
        return null;
      case GradusButtonType.secondary:
        return const BorderSide(color: AppTheme.primaryColor, width: 1.5);
      case GradusButtonType.text:
        return null;
      case GradusButtonType.social:
        return BorderSide(color: Colors.grey.shade300, width: 1);
    }
  }

  List<BoxShadow>? _getBoxShadow() {
    if (widget.type == GradusButtonType.primary && _isHovered) {
      return AppTheme.subtleShadow;
    }
    if (widget.type == GradusButtonType.social) {
      return AppTheme.subtleShadow;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: GestureDetector(
                onTapDown: isEnabled ? _onTapDown : null,
                onTapUp: isEnabled ? _onTapUp : null,
                onTapCancel: _onTapCancel,
                onTap: isEnabled ? widget.onPressed : null,
                child: AnimatedContainer(
                  duration: AppTheme.fastAnimation,
                  curve: AppTheme.fastCurve,
                  width: widget.isFullWidth ? double.infinity : widget.width,
                  height: widget.height ?? 56,
                  padding: widget.padding ??
                      const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing24,
                        vertical: AppTheme.spacing16,
                      ),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? (_isHovered && widget.type == GradusButtonType.primary
                            ? AppTheme.primaryDark
                            : _getBackgroundColor())
                        : Colors.grey.shade300,
                    border: _getBorderSide() != null
                        ? Border.fromBorderSide(_getBorderSide()!)
                        : null,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: _getBoxShadow(),
                  ),
                  child: Row(
                    mainAxisSize: widget.isFullWidth
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getForegroundColor().withValues(alpha: .4),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                      ] else if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: AppTheme.spacing12),
                      ],
                      Flexible(
                        child: Text(
                          widget.text,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: isEnabled
                                ? _getForegroundColor()
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
