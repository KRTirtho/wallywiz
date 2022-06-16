import 'package:flutter/widgets.dart';
import 'package:marquee/marquee.dart';

class MarqueeText extends StatelessWidget {
  const MarqueeText(
      {Key? key, required this.text, this.style, this.staticLimit = 20})
      : super(key: key);
  final TextStyle? style;
  final String text;
  final int staticLimit;

  @override
  Widget build(BuildContext context) {
    return text.length > staticLimit
        ? Marquee(
            text: text,
            style: style,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 60.0,
            velocity: 30.0,
            startAfter: const Duration(seconds: 2),
            pauseAfterRound: const Duration(seconds: 2),
            accelerationDuration: const Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: const Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
            fadingEdgeStartFraction: 0.15,
            fadingEdgeEndFraction: 0.15,
          )
        : Text(text, style: style);
  }
}
