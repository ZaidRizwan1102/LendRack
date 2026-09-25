import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet/utils/responsive.dart';

class CustomInputField extends StatefulWidget {
  final String? svgPath;
  final double? customHeight;
  final double? customWidth;
  final double? svgSize;
  final double? svgPadding;
  final EdgeInsetsGeometry? margin;
  final String hintText;
  final int maxLines;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.hintText,
    this.svgPath,
    this.customHeight,
    this.customWidth,
    this.svgSize,
    this.svgPadding,
    this.margin,
    this.maxLines = 1,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword && widget.maxLines == 1;
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    final double? computedHeight =
        widget.customHeight ?? (widget.maxLines > 1 ? null : size.heightPerc(5.8));

    return Container(
      margin:
          widget.margin ??
          EdgeInsets.only(
            top: size.heightPerc(1.5),
          ),
      width: widget.customWidth ?? size.widthPerc(71),
      height: computedHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(size.widthPerc(4)),
        border: Border.all(color: Theme.of(context).shadowColor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.widthPerc(2)),
        child: TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          maxLines: widget.maxLines,
          style: const TextStyle(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: widget.svgPath != null
                ? Padding(
                    padding: EdgeInsets.all(widget.svgPadding ?? size.widthPerc(3.8)),
                    child: SvgPicture.asset(
                      widget.svgPath!,
                      width: widget.svgSize ?? size.widthPerc(5),
                      height: widget.svgSize ?? size.widthPerc(5),
                      fit: BoxFit.contain,
                    ),
                  )
                : null,
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.widthPerc(3),
                      ),
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black, // Hardcoded black, un-overridable
                        size: size.widthPerc(5),
                      ),
                    ),
                  )
                : null,
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: const TextStyle(fontSize: 16, color: Colors.black),
            contentPadding: EdgeInsets.symmetric(
              vertical: widget.maxLines > 1
                  ? size.heightPerc(1.5)
                  : size.heightPerc(1.2),
              horizontal: widget.svgPath == null ? size.widthPerc(2) : 0,
            ),
          ),
        ),
      ),
    );
  }
}