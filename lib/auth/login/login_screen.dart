import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/auth/register/register_screen.dart';
import 'package:todo/components/custom_text_form_field.dart';
import 'package:todo/dialog_utils.dart';

import '../../firebase_utils.dart';
import '../../home/home_screen.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController(text: 'monia@gmail.com');

  var passwordController = TextEditingController(text: '1234567');

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/main_background.png",
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                    ),
                    CustomTextFormField(
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Please Enter Email';
                        }
                        bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(text);
                        if (!emailValid) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      label: 'Password',
                      keyboardType: TextInputType.number,
                      controller: passwordController,
                      obscureText: true,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Please Enter Password';
                        }
                        if (text.length < 6) {
                          return 'Password should have at least 6 chars.';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () {
                            register();
                          },
                          child: Text(
                            'Login',
                            style: Theme.of(context).textTheme.titleLarge,
                          )),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?",
                            style: Theme.of(context).textTheme.titleMedium),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(RegisterScreen.routeName);
                            },
                            child: Text(
                              'SignUp',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            )),
                      ],
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void register() async {
    if (formKey.currentState?.validate() == true) {
      DialogUtils.showMessage(context, 'Loading...');
      try {
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        var user = await FirebaseUtils.readUserFromFireStore(
            credential.user?.uid ?? '');
        if (user == null) {
          return;
        }
        var authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.updateUser(user);
        DialogUtils.hideLoading(context);
        DialogUtils.showMessage(context, 'Login Successfully',
            title: 'Success', posActionName: 'OK', posAction: () {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        });
        print(credential.user?.uid ?? '');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          DialogUtils.hideLoading(context);
          DialogUtils.showMessage(context, 'No user found for that email.',
              title: 'Error', posActionName: 'OK');
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          DialogUtils.hideLoading(context);
          DialogUtils.showMessage(
              context, 'Wrong password provided for that user.',
              title: 'Error', posActionName: 'OK');
          print('Wrong password provided for that user.');
        }
      } catch (e) {
        DialogUtils.hideLoading(context);
        DialogUtils.showMessage(context, '${e.toString()}',
            title: 'Error', posActionName: 'OK');
        print(e.toString());
      }
    }
  }
}
