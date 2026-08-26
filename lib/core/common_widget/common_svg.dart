import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonSvgWidget extends StatelessWidget {
  final String svgName;
  final double height;
  final double width;
  final Color? color;
  const CommonSvgWidget({
    super.key,
    required this.svgName,
    this.height = 16,
    this.width = 16,
    this.color,
  });

  bool get _isSvg => svgName.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      child: _isSvg
          ? SvgPicture.asset(
              svgName,
              height: height,
              width: width,
              colorFilter: color != null
                  ? ColorFilter.mode(color!, BlendMode.srcIn)
                  : null,
            )
          : Image.asset(
              svgName,
              height: height,
              width: width,
              color: color,
              fit: BoxFit.cover,
            ),
    );
  }
}
