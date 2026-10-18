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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, isSelected ? -12.0 : 0.0),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width / 2),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accent
                  : isHinted
                      ? AppTheme.warning
                      : Colors.white.withOpacity(0.15),
              width: isSelected || isHinted ? 3 : 2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(width / 2 - 2),
            child: Stack(
              children: [
                // Glass tube background
                Container(
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
                // Liquid segments
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(tube.capacity, (index) {
                      final colorIndex = index;
                      final hasColor = colorIndex < tube.colors.length;
                      final color = hasColor ? tube.colors[colorIndex] : null;
                      final segmentHeight = (height - 8) / tube.capacity;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        width: width - 8,
                        height: segmentHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.vertical(
                            top: colorIndex == tube.colors.length - 1 && hasColor
                                ? const Radius.circular(4)
                                : Radius.zero,
                            bottom: colorIndex == 0
                                ? Radius.circular(width / 2 - 6)
                                : Radius.zero,
                          ),
                          boxShadow: color != null
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 6,
                                    offset: const Offset(0, -2),
                                  ),
                                ]
                              : null,
                        ),
                        child: color != null
                            ? Container(
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
                              )
                            : null,
                      );
                    }),
                  ),
                ),
                // Shine effect
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
                // Top rim
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
