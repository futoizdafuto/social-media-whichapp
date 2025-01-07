import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/services/FollowServices.dart';
import 'package:socially_app_flutter_ui/services/LoginServices.dart';  // Import LoginService
import 'config/colors.dart';
import 'config/myHttpOverrides.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/login/login_screen.dart';
import 'package:http/http.dart' as http;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

void main() {
  // Allow self-signed certificates (insecure for development)
  allowSelfSignedCertificate();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create a GlobalKey for the Navigator
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Fetch follow data when the app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchFollowData(context);  // Pass context to the method
    });

    return MaterialApp(
      title: 'Socially',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,  // Use GlobalKey for navigation
      theme: kAppThemeData,
      home: const LoginScreen(), // App starts at Login Screen if not logged in
    );
  }

  // Function to fetch follow data
  void fetchFollowData(BuildContext context) async {
    final followService = FollowService();

    // Fetch realUserName from secure storage
    final realUserName = await _getRealUserName();

    if (realUserName == null) {
      print("Error: User is not logged in.");
      // Redirect to login screen if the user is not logged in
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    print("RealUserName from storage: $realUserName"); // Debug print to check if realUserName is null

    // Call the getFollows method and pass the realUserName
    final followData = await followService.getFollows();
    if (followData['status'] == 'success') {
      // Kiểm tra và xử lý nếu dữ liệu trả về là một số hay danh sách
      var followingCountData = followData['following_list'];
      var followedCountData = followData['followed_list'];

      // Check and handle following count data
      if (followingCountData is List) {
        print('Following List: $followingCountData');
        print('Following Count: ${followingCountData.length}');
      } else if (followingCountData is int) {
        print('Following Count: $followingCountData'); // Handle if it's an int
      } else {
        print('Unexpected data type for followingCountData: $followingCountData');
      }

      // Check and handle followed count data
      if (followedCountData is List) {
        print('Followed List: $followedCountData');
        print('Followed Count: ${followedCountData.length}');
      } else if (followedCountData is int) {
        print('Followed Count: $followedCountData'); // Handle if it's an int
      } else {
        print('Unexpected data type for followedCountData: $followedCountData');
      }

      // Handle follower count as it might always be an int
      int followerCount = followData['follower_count'] ?? 0;
      print('Follower Count: $followerCount');
    } else {
      print('Error: ${followData['message']}');
    }
  }



  // Function to fetch the real username from secure storage
  Future<String?> _getRealUserName() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'realuserName');  // Assuming realUserName is saved under this key
  }
}

final ThemeData kAppThemeData = _buildAppTheme();

ThemeData _buildAppTheme() {
  final base = ThemeData.light();
  final baseTextTheme = GoogleFonts.poppinsTextTheme(base.textTheme);
  return base.copyWith(
    scaffoldBackgroundColor: kWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    ),
    textTheme: baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge!.copyWith(
        height: 58.5 / 39,
        fontWeight: FontWeight.w700,
        fontSize: 39.0,
        color: kBlack,
      ),
      displayMedium: baseTextTheme.displayMedium!.copyWith(
        height: 46.88 / 31.25,
        fontWeight: FontWeight.w700,
        fontSize: 31.25,
        color: kBlack,
      ),
      displaySmall: baseTextTheme.displaySmall!.copyWith(
        height: 37.5 / 25.0,
        fontWeight: FontWeight.w400,
        fontSize: 25.0,
        color: kBlack,
      ),
      headlineSmall: baseTextTheme.headlineSmall!.copyWith(
        height: 30.0 / 20.0,
        fontWeight: FontWeight.w400,
        fontSize: 20.0,
        color: kBlack,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: kBlack,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: baseTextTheme.bodySmall!.copyWith(
        height: 21.0 / 14.0,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: kBlack,
      ),
      labelSmall: baseTextTheme.labelSmall!.copyWith(
        height: 19.2 / 12.8,
        fontSize: 12.8,
        color: kCaption,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
