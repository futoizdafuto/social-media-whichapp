import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/home/widgets/background.dart';
import '../settings_modal/setting_item.dart';
import '../post_screen/post_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // firstly, we need to create a backround
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Socially',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                onPressed: () {},
                icon: SvgPicture.asset('assets/icons/notif.svg'),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Feed',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              // const SizedBox(height: 30.0),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       Container(
              //         height: 56.0,
              //         width: 56.0,
              //         alignment: Alignment.center,
              //         margin: const EdgeInsets.only(left: 24.0),
              //         decoration: BoxDecoration(
              //           shape: BoxShape.circle,
              //           gradient: k3GradientAccent,
              //           boxShadow: [
              //             BoxShadow(
              //               blurRadius: 12.0,
              //               offset: const Offset(0, 4),
              //               color: k3Pink.withOpacity(0.52),
              //             ),
              //           ],
              //         ),
              //         child: SvgPicture.asset('assets/icons/only_plus.svg'),
              //       ),
              //       ...List.generate(
              //         5,
              //         (index) => Container(
              //           height: 56.0,
              //           width: 56.0,
              //           margin: EdgeInsets.only(
              //             left: 30.0,
              //             right: index == 4 ? 30.0 : 0.0,
              //           ),
              //           alignment: Alignment.center,
              //           decoration: BoxDecoration(
              //             shape: BoxShape.circle,
              //             border: Border.all(width: 2.0, color: k2AccentStroke),
              //             image: const DecorationImage(
              //               image:
              //                   AssetImage('assets/images/profile_image.jpg'),
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const PostElement(),
            ],
          ),
        ),
      ),
    );
  }
}
