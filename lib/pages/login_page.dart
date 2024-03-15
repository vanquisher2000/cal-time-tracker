import 'package:cal_time_tracker/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cal_time_tracker/controller/userController.dart';
import 'package:iconly/iconly.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Center(
                    child:
                        //Text("loginPage"))
                        Image.asset('assets/time.png')),
              ),
              const Spacer(),
              Text(
                'upgrade your time management experience',
                style:
                    textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30, bottom: 30),
                child: Text(
                  "when you finish a task it will be registered automatically in your calendar.",
                  textAlign: TextAlign.center,
                ),
              ),
              /**/
              FilledButton.tonalIcon(
                onPressed: () async {
                  try {
                    final user = await UserController.loginWithGoogle();
                    if (user != null && mounted) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MyHomePage()));
                    }
                  } on FirebaseAuthException catch (error) {
                    print(error.message);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      error.message ?? "Something went wrong",
                    )));
                  } catch (error) {
                    print(error);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      error.toString(),
                    )));
                  }
                },
                icon: const Icon(IconlyLight.login),
                label: const Text("Continue with Google"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
