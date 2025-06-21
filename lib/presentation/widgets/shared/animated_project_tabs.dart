import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/project.dart';

class AnimatedProjectTabs extends StatelessWidget {
  final Project? selectedProject;
  final List<Project> availableProjects;
  final Function(String) onProjectChanged;

  const AnimatedProjectTabs({
    super.key,
    required this.selectedProject,
    required this.availableProjects,
    required this.onProjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (availableProjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: availableProjects.map((project) {
          final isSelected = selectedProject?.id == project.id;
          return Padding(
            padding: EdgeInsets.only(
              left: project == availableProjects.first ? 0 : AppTheme.spacing8,
            ),
            child: ProjectTab(
              project: project,
              isSelected: isSelected,
              onTap: () => onProjectChanged(project.id),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ProjectTab extends StatefulWidget {
  final Project project;
  final bool isSelected;
  final VoidCallback onTap;

  const ProjectTab({
    super.key,
    required this.project,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends State<ProjectTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppTheme.fastCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: AppTheme.animationDuration,
              curve: AppTheme.animationCurve,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
                vertical: AppTheme.spacing8,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : _isPressed
                        ? AppTheme.primaryColor.withValues(alpha: 0.05)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: widget.isSelected
                    ? Border.all(
                        color: AppTheme.primaryColor,
                        width: 1.5,
                      )
                    : null,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated color indicator
                  AnimatedContainer(
                    duration: AppTheme.fastAnimation,
                    curve: AppTheme.fastCurve,
                    width: AppTheme.spacing8,
                    height: AppTheme.spacing8,
                    decoration: BoxDecoration(
                      color: widget.isSelected 
                          ? AppTheme.primaryColor 
                          : AppTheme.textTertiary,
                      shape: BoxShape.circle,
                      boxShadow: widget.isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  // Animated text
                  AnimatedDefaultTextStyle(
                    duration: AppTheme.animationDuration,
                    curve: AppTheme.animationCurve,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: widget.isSelected
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    child: Text(widget.project.name),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
