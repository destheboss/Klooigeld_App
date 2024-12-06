import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Color? backgroundColor;
  final Color? shadowColor;
  final VoidCallback? onTap;
  final Widget? child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  const CustomCard({
    Key? key,
    this.backgroundColor,
    this.shadowColor,
    this.onTap,
    this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? Colors.black26,
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(0),
            child: child,
          ),
        ),
      ),
    );
  }
}
