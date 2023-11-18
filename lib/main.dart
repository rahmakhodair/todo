import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/auth/login/login_screen.dart';
import 'package:todo/auth/register/register_screen.dart';
import 'package:todo/home/home_screen.dart';
import 'package:todo/home/task_list/edit_task.dart';
import 'package:todo/my_theme.dart';
import 'package:todo/providers/auth_provider.dart';
import 'package:todo/providers/list_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseFirestore.instance.settings =
  //     Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  // await FirebaseFirestore.instance.disableNetwork();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => ListProvider()),
    ChangeNotifierProvider(create: (context) => AuthProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RegisterScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        EditTask.routeName: (context) => EditTask(),
      },
      theme: MyTheme.lightTheme,
    );
  }
}
