import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:express/providers/app.dart';
import 'package:express/screens/home_screen.dart';
import 'package:express/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await Provider.of<App>(context, listen: false).initDirs();
    await Provider.of<App>(context, listen: false).openBoxes();
    setState(() {
      if (Provider.of<App>(context, listen: false).preferencesBox.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (builder) => LoginScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (builder) => HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(),
      ),
    );
  }
}
