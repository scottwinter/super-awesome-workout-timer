import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WheelSelector extends StatelessWidget {
  final String? label;
  final FixedExtentScrollController controller;
  final int maxValue;
  final ValueChanged<int> onSelectedItemChanged;
  final double height;
  final double width;
  final double itemExtent;
  final bool useMagnifier;
  final double magnification;
  final double diameterRatio;
  final double perspective;
  final double overAndUnderCenterOpacity;
  final TextStyle? textStyle;

  const WheelSelector({
    super.key,
    this.label,
    required this.controller,
    required this.maxValue,
    required this.onSelectedItemChanged,
    this.height = 150,
    this.width = 100,
    this.itemExtent = 50,
    this.useMagnifier = true,
    this.magnification = 1.3,
    this.diameterRatio = 1.3,
    this.perspective = 0.002,
    this.overAndUnderCenterOpacity = 0.5,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle =
        textStyle ?? Theme.of(context).textTheme.headlineMedium;

    return Column(
      children: [
        if (label != null)
          Text(label!, style: Theme.of(context).textTheme.titleLarge),
        if (label != null) const SizedBox(height: 10),
        SizedBox(
          height: height,
          width: width,
          child: ListWheelScrollView.useDelegate(
            useMagnifier: useMagnifier,
            magnification: magnification,
            diameterRatio: diameterRatio,
            perspective: perspective,
            overAndUnderCenterOpacity: overAndUnderCenterOpacity,
            controller: controller,
            itemExtent: itemExtent,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              HapticFeedback.selectionClick();
              onSelectedItemChanged(maxValue - index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) => Center(
                child: Text(
                  '${maxValue - index}',
                  style: effectiveTextStyle,
                ),
              ),
              childCount: maxValue,
            ),
          ),
        ),
      ],
    );
  }
}
