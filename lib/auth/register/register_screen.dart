import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/auth/login/login_screen.dart';
import 'package:todo/components/custom_text_form_field.dart';
import 'package:todo/dialog_utils.dart';
import 'package:todo/firebase_utils.dart';
import 'package:todo/home/home_screen.dart';
import 'package:todo/model/my_user.dart';

import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = 'register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var nameController = TextEditingController(text: "Monia");

  var emailController = TextEditingController(text: 'monia@gmail.com');

  var passwordController = TextEditingController(text: '1234567');

  var confirmPasswordController = TextEditingController(text: '1234567');

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
                      label: 'User Name',
                      controller: nameController,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Please Enter User Name';
                        }
                        return null;
                      },
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
                    CustomTextFormField(
                      label: 'Confirm Password',
                      keyboardType: TextInputType.number,
                      controller: confirmPasswordController,
                      obscureText: true,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Please Enter Confirm Password';
                        }
                        if (text != passwordController.text) {
                          return "Password doesn't match.";
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
                            'Register',
                            style: Theme.of(context).textTheme.titleLarge,
                          )),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(LoginScreen.routeName);
                        },
                        child: Text(
                          "Already have an account",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Theme.of(context).primaryColor),
                        ))
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void register() async {
    if (formKey.currentState?.validate() == true) {
      // DialogUtils.showLoading(context, 'Loading...');
      // await Future.delayed(Duration(seconds: 2));
      // DialogUtils.hideLoading(context);
      //todo : show loading
      DialogUtils.showLoading(context, 'Loading...');
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        MyUser myUser = MyUser(
            id: credential.user?.uid ?? '',
            name: nameController.text,
            email: emailController.text);
        await FirebaseUtils.addUserToFireStore(myUser);
        var authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.updateUser(myUser);
        //todo : hide loading
        DialogUtils.hideLoading(context);
        //todo : show message
        DialogUtils.showMessage(context, 'Register Successfully',
            title: 'Success', posActionName: 'OK', posAction: () {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        });
        print("Register Successfully");
        print(credential.user?.uid ?? '');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          DialogUtils.hideLoading(context);
          DialogUtils.showMessage(context, 'The password provided is too weak.',
              title: 'Error', posActionName: 'OK');
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          DialogUtils.hideLoading(context);
          DialogUtils.showMessage(
              context, 'The account already exists for that email.',
              title: 'Error', posActionName: 'OK');
          print('The account already exists for that email.');
        }
      } catch (e) {
        DialogUtils.hideLoading(context);
        DialogUtils.showMessage(context, '${e.toString()}',
            title: 'Error', posActionName: 'OK');
        print(e);
      }
    }
  }
}
