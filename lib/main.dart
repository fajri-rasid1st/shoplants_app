import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoplants/data/utils/cart_preferences.dart';
import 'package:shoplants/data/utils/const.dart';
import 'package:shoplants/data/utils/user_preferences.dart';
import 'package:shoplants/ui/screens/loading_screen.dart';
import 'package:shoplants/ui/screens/main_screen.dart';
import 'package:shoplants/ui/screens/welcome_screen.dart';
import 'package:shoplants/ui/styles/color_scheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // prevent landscape orientation
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // change status bar color
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: backGroundColor,
  ));

  // initialize user and cart preferences
  await UserPreferences.init();
  await CartPreferences.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shoplants',
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Poppins',
              displayColor: primaryTextColor,
              bodyColor: primaryTextColor,
            ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: tertiaryColor,
          background: backGroundColor,
          outline: secondaryTextColor,
          shadow: secondaryTextColor,
        ),
        scaffoldBackgroundColor: backGroundColor,
      ),
      home: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (UserPreferences.getUser(Const.userId) == null) {
                return const WelcomeScreen();
              }

              return MainScreen(user: UserPreferences.getUser(Const.userId)!);
            }
          }

          return const LoadingScreen();
        },
      ),
    );
  }
}
