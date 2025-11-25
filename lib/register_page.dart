import 'package:flutter/material.dart';
import 'package:flutter_application5/auth_service.dart';
import 'package:flutter_application5/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body:Center(
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
                 child: loading ? const CircularProgressIndicator() : const Text('Register'),
                  onPressed: () async {
                    if(emailController.text.isEmpty || passwordController.text.isEmpty)return;
                    setState(() {
                      loading = true;
                    });

                    final user = await auth.registerWithEmail(
                      emailController.text,
                      passwordController.text,
                    );
                    setState(() {
                      loading = false;
                    });
                    if (user != null) {
                      if(user.emailVerified == false){
                        await user.sendEmailVerification();
                         ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verification email sent')),
                       );
                      }
                      Navigator.pushReplacement(
                        context, MaterialPageRoute( builder: (_) => LoginPage()),
                      );
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration failed')),
                      );
                    }
                  },
                ),
                SizedBox(height: 12),
                TextButton(
                  child: const Text('Already have an account? Login'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context, MaterialPageRoute( builder: (_) => LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}
