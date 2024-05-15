import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:nuke_my_inbox/app_state.dart';

// import 'app_state.dart';

class LoginScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const LoginScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in to Nuke My Inbox'),
      ),
      body: Center(
        child: SignInButtonBuilder(
          text: 'Sign in with Google',
          icon: Icons.login,
          onPressed: () {
            Provider.of<ApplicationState>(context, listen: false).signInWithGoogle(context);
          },
          backgroundColor: ThemeData.dark(useMaterial3: true).scaffoldBackgroundColor,
        )
      ),
    );
  }
}