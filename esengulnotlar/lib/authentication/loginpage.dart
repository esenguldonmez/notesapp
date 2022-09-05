import 'package:esengulnotlar/authentication/registerpage.dart';
import 'package:esengulnotlar/inApp/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();

  final TextEditingController _mail = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Form(
        key: _loginFormKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Giriş Yap",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _mail,
                decoration: InputDecoration(
                  hintText: "Mail Adresi",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: const Icon(Icons.mail, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.75),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.75),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.25),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 0.75),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.25),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Şifre boş bırakılamaz" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _password,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  hintText: "Şifre",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: const Icon(Icons.key, color: Colors.black),
                  suffixIcon: GestureDetector(
                    child: Icon(Icons.remove_red_eye_outlined,
                        color: hidePassword ? Colors.grey : Colors.black),
                    onTap: () => setState(
                      () {
                        hidePassword = hidePassword ? false : true;
                      },
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.75),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.75),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.25),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 0.75),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.25),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Şifre boş bırakılamaz" : null,
              ),
              const SizedBox(height: 10),
              MaterialButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: const Text("Giriş Yap",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Colors.black,
                minWidth: MediaQuery.of(context).size.width,
                onPressed: () async {
                  if (_loginFormKey.currentState!.validate()) {
                    try {
                      FirebaseAuth.instance.authStateChanges().listen(
                        (User? user) {
                          if (user != null) {
                            final box = GetStorage();
                            box.write("mail", user.email);
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()),
                                (Route<dynamic> route) => false);
                          }
                        },
                      );
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _mail.text.trim(),
                        password: _password.text.trim(),
                      );
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message.toString())),
                      );
                    }
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    text: 'Hesabınuz yok mu? ',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Kayıt Ol',
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w500),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RegisterPage()),
                              ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    String check = FirebaseAuth.instance.currentUser?.email ?? "";
    print("check: $check");
    if (check != "") FirebaseAuth.instance.signOut();

    final box = GetStorage();
    _mail.text = box.read("mail") ?? "";
    super.initState();
  }
}
