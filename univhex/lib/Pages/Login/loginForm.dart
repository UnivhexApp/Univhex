import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:univhex/Constants/AppColors.dart';
import 'package:univhex/Constants/current_user.dart';
import 'package:univhex/Firebase/firestore.dart';
import 'package:univhex/Firebase/user_auth.dart';
import 'package:univhex/Objects/app_user.dart';
import 'package:univhex/Objects/user_secure_storage.dart';

import 'package:univhex/Router/app_router.gr.dart';
import 'package:univhex/Widgets/appTextFields.dart';
import 'package:univhex/Widgets/univhex_progress_indicator.dart';

class AppLoginForm extends StatefulWidget {
  AppLoginForm({
    super.key,
  });
  String? _email;
  @override
  AppLoginFormState createState() {
    return AppLoginFormState();
  }
}

class AppLoginFormState extends State<AppLoginForm> {
  final _loginFormKey =
      GlobalKey<FormState>(); // To validate our data, we need to use a form.

  final _emailController = TextEditingController(); // Controller for email.
  final _passwordController =
      TextEditingController(); // Controller for Password.
  String? _email;
  String? _password = '';
  bool loggingIn = false;
  Future init() async {
    if (widget._email == null) {
      _email = await UserSecureStorage.getEmail() ?? '';
      // _password = await UserSecureStorage.getPassword() ?? '';
    }
    setState(() {
      _emailController.text = _email!;
      _passwordController.text = _password!;
    });
  }

  @override
  void initState() {
    // intialize variables.

    super.initState();
    _emailController.addListener(() {
      _email = _emailController.text;
    });
    _passwordController.addListener(() {
      _password = _passwordController.text;
    });
    init();
  }

  _submitLoginForm() async {
    _loginFormKey.currentState?.save();
    if (_loginFormKey.currentState != null &&
        _loginFormKey.currentState!.validate()) {
      setState(() {
        loggingIn = true;
      });
      if (await authUser(_email, _password!)) {
        AppUser? user = await readUserfromDB(CurrentUser.firebaseUser!.uid);
        if (user != null) {
          CurrentUser.user = user;

          context.router.push(const AppRoute());
        }
      }
    }
    setState(() {
      loggingIn = false;
    });
  }

  @override
  void dispose() {
    // Delete vars from Ram. Space allocation++.
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _loginFormKey,
      child: Column(
        children: <Widget>[
          // Add TextFormFields and ElevatedButton here.
          AppTextFormField(
            textHolder: "E-mail",
            obscure: false,
            borderRadius: 20,
            icon: const Icon(Icons.person),
            controller: _emailController,
          ),

          AppTextFormField(
            textHolder: "Password",
            obscure: true,
            borderRadius: 20,
            icon: const Icon(Icons.password),
            controller: _passwordController,
          ),
          CurrentUser.addVerticalSpace(2),

          !loggingIn
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(40),
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  onPressed: () {
                    _submitLoginForm();
                  },
                  child: const Text("Sign In"),
                )
              : const UnivhexProgressIndicator(
                  isHorizontal: true,
                ),
        ],
      ),
    );
  }
}
