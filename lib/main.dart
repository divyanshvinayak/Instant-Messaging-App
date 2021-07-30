import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:express/providers/app.dart';
import 'package:express/screens/splash_screen.dart';
import 'package:express/models/user.dart';
import 'package:express/models/message.dart';
import 'package:express/models/preferences.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(PreferencesAdapter());
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(Express());
}

class Express extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<App>(
      create: (context) => App(),
      child: MaterialApp(
        title: 'Express',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
