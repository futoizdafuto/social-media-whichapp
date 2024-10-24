import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;

import '../../config/colors.dart';
import 'widgets/profile_background.dart';
import 'widgets/stat.dart';
import '../login/login_screen.dart'; 
import 'setting_profile/setting_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedTab = 'photos';

  _changeTab(String tab) {
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
 actions: [
  Padding(
    padding: const EdgeInsets.only(right: 16.0),
    child: IconButton(
      icon: SvgPicture.asset('assets/icons/menu.svg'),
      onPressed: () {
        // Show modal with half-screen content directly
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const SettingProfileScreen(),
        );
      },
    ),
  ),
],




        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: 140.0,
                      height: 140.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: kBlack),
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: ProfileImageClipper(),
                    child: Image.asset(
                      'assets/images/profile_image.jpg',
                      width: 180.0,
                      height: 180.0,
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              ),
              Text(
                'John Doe',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4.0),
              Text(
                '@johndoe',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 80.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stat(title: 'Posts', value: 35),
                    Stat(title: 'Followers', value: 1552),
                    Stat(title: 'Follows', value: 128),
                  ],
                ),
              ),
              const SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => _changeTab('photos'),
                    child: SvgPicture.asset(
                      'assets/icons/Button-photos.svg',
                      color: _selectedTab == 'photos' ? k2AccentStroke : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _changeTab('saved'),
                    child: SvgPicture.asset(
                      'assets/icons/Button-saved.svg',
                      color: _selectedTab == 'saved' ? k2AccentStroke : null,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14.0,
                  crossAxisSpacing: 14.0,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19.0),
                        child: Image.asset(
                          'assets/images/Rectangle-5.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19.0),
                        child: Image.asset(
                          'assets/images/Rectangle-7.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19.0),
                        child: Image.asset(
                          'assets/images/Rectangle-8.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19.0),
                        child: Image.asset(
                          'assets/images/Rectangle-1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileImageClipper extends CustomClipper<Path> {
  double radius = 35;

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(size.width / 2 - radius, radius)
      ..quadraticBezierTo(size.width / 2, 0, size.width / 2 + radius, radius)
      ..lineTo(size.width - radius, size.height / 2 - radius)
      ..quadraticBezierTo(size.width, size.height / 2, size.width - radius,
          size.height / 2 + radius)
      ..lineTo(size.width / 2 + radius, size.height - radius)
      ..quadraticBezierTo(size.width / 2, size.height, size.width / 2 - radius,
          size.height - radius)
      ..lineTo(radius, size.height / 2 + radius)
      ..quadraticBezierTo(0, size.height / 2, radius, size.height / 2 - radius)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
