import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';

class StoryWidget extends StatefulWidget {
  const StoryWidget({super.key});

  @override
  State<StoryWidget> createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            height: 56.0,
            width: 56.0,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 24.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: k3GradientAccent,
              boxShadow: [
                BoxShadow(
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                  color: k3Pink.withOpacity(0.52),
                ),
              ],
            ),
            child: SvgPicture.asset('assets/icons/only_plus.svg'),
          ),
          ...List.generate(
            5,
            (index) => Container(
              height: 56.0,
              width: 56.0,
              margin: EdgeInsets.only(
                left: 30.0,
                right: index == 4 ? 30.0 : 0.0,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2.0, color: k2AccentStroke),
                image: const DecorationImage(
                  image: AssetImage('assets/images/profile_image.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
