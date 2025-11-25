import 'package:flutter/material.dart';
import 'package:flutter_application5/auth_service.dart';
import 'package:flutter_application5/home_page.dart';
import 'package:flutter_application5/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final  AuthService auth = AuthService();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                child:
                    loading ? const CircularProgressIndicator() : const Text('Login with Email'),
                onPressed: () async {
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) return;
                  setState(() {
                    loading = true;
                  });

                  final user = await auth.signInWithEmail(
                    emailController.text,
                    passwordController.text,
                  );
                  setState(() {
                    loading = false;
                  });
                  if (user != null) {
                    Navigator.pushReplacement(
                      context, MaterialPageRoute( builder: (_) => HomePage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login failed')),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  if (emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter your email to reset password')),
                    );
                    return;
                  }

                  final success = await auth.sendPasswordReset(emailController.text.trim());
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset email sent')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to send password reset email')),
                    );
                  }
                },
                child: const Text('Forgot password?'),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()),);
              }, child: Text( 'Don\'t have an account? Register') ),
            ],
          ),
        ),
      ),
    );
  }
}