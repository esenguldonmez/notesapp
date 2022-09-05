import 'package:esengulnotlar/authentication/loginpage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final TextEditingController _mail = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Form(
        key: _registerFormKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Kayıt Ol",
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
                    value!.isEmpty ? "Şifre boş bırakılamaz!" : null,
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
                child: const Text("Kayıt Ol",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Colors.black,
                minWidth: MediaQuery.of(context).size.width,
                onPressed: () async {
                  if (_registerFormKey.currentState!.validate()) {
                    try {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: _mail.text.trim(),
                        password: _password.text.trim(),
                      );
                      Navigator.pop(context);
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
                    text: 'Hesabın var mı? ',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Giriş Yap',
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w500),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pop(context),
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
}
