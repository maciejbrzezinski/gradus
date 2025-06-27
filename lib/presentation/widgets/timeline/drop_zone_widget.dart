import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/day.dart';
import '../../cubits/timeline/timeline_cubit.dart';

class DropZoneWidget extends StatefulWidget {
  final int targetIndex;
  final Day day;
  final bool isLastZone;

  const DropZoneWidget({
    super.key,
    required this.targetIndex,
    required this.day,
    this.isLastZone = false,
  });

  @override
  State<DropZoneWidget> createState() => _DropZoneWidgetState();
}

class _DropZoneWidgetState extends State<DropZoneWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragEnter() {
    _animationController.forward();
  }

  void _onDragLeave() {
    _animationController.reverse();
  }

  void _onDragAccept(Map<String, dynamic> data) {
    final itemId = data['itemId'] as String;
    final fromDay = data['fromDay'] as Day;

    context.read<TimelineCubit>().moveItemBetweenDays(
      itemId: itemId,
      fromDay: fromDay,
      toDay: widget.day,
      toIndex: widget.targetIndex,
    );

    _onDragLeave();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        final itemId = data['itemId'] as String?;
        final fromDay = data['fromDay'] as Day?;
        
        // Accept if we have valid data
        return itemId != null && fromDay != null;
      },
      onAcceptWithDetails: (details) => _onDragAccept(details.data),
      onMove: (_) => _onDragEnter(),
      onLeave: (_) => _onDragLeave(),
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: isActive ? 16 : 8,
          margin: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing24,
            vertical: isActive ? AppTheme.spacing4 : 0,
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(
                      alpha: _opacityAnimation.value * 0.4,
                    ),
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: _opacityAnimation.value > 0.5
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(
                                alpha: _opacityAnimation.value * 0.3,
                              ),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
