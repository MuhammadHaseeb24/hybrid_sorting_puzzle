
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/level_data.dart';
import '../utils/app_theme.dart';

class TubeWidget extends StatelessWidget {
  final Tube tube;
  final bool isSelected;
  final bool isHinted;
  final VoidCallback onTap;
  final double width;
  final double height;

  const TubeWidget({
    super.key,
    required this.tube,
    required this.isSelected,
    this.isHinted = false,
    required this.onTap,
    this.width = 56,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final safeCapacity = tube.capacity > 0 ? tube.capacity : 1;
    final tubeHeight = height > 16 ? height : 16.0;
    final tubeWidth = width > 16 ? width : 16.0;
    final segmentHeight = (tubeHeight - 8) / safeCapacity;

    final borderColor = isSelected
        ? AppTheme.accent
        : isHinted
        ? AppTheme.warning
        : Colors.white.withOpacity(0.15);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, isSelected ? -12.0 : 0.0),
        child: Container(
          width: tubeWidth,
          height: tubeHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tubeWidth / 2),
            border: Border.all(
              color: borderColor,
              width: isSelected || isHinted ? 3 : 2,
            ),
            // Keep the shadow stable between animation states.
            // This avoids invalid intermediate shadow values.
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppTheme.accent.withOpacity(0.4)
                    : Colors.black.withOpacity(0.3),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tubeWidth / 2 - 2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Glass tube background.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ],
                    ),
                  ),
                ),

                // Liquid slots: each segment stays within the tube.
                ...List.generate(safeCapacity, (index) {
                  final colorIndex = safeCapacity - 1 - index;
                  final hasColor = colorIndex < tube.colors.length;
                  final Color? color =
                  hasColor ? tube.colors[colorIndex] : null;

                  final isTopLiquidSegment =
                      hasColor && colorIndex == tube.colors.length - 1;
                  final isBottomSlot = colorIndex == 0;

                  return Positioned(
                    left: 4,
                    right: 4,
                    bottom: 4 + index * segmentHeight,
                    height: segmentHeight,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.vertical(
                          top: isTopLiquidSegment
                              ? const Radius.circular(4)
                              : Radius.zero,
                          bottom: isBottomSlot
                              ? Radius.circular(tubeWidth / 2 - 6)
                              : Radius.zero,
                        ),
                      ),
                      child: color == null
                          ? null
                          : DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.9),
                              color,
                              color.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Glass shine.
                Positioned(
                  left: 6,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Top rim.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .animate(target: isSelected ? 1 : 0)
          .scale(
        begin: const Offset(1, 1),
        end: const Offset(1.05, 1.05),
        duration: 200.ms,
      ),
    );
  }
}
