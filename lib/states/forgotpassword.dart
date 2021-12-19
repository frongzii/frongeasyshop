import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/utility/my_dialog.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyConstant.primart,
          title: const Text('ลืมรหัสผ่าน'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: ('Email ผู้ใช้งาน'),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (emailController.text.isEmpty) {
                    MyDialog()
                        .normalDialog(context, 'Empty', 'Plaese enter email');
                  } else {
                    processSentEmail();
                  }
                },
                child: Text('Reset Password'))
          ],
        ));
  }

  Future<void> processSentEmail() async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text)
        .then((value) {
      MyDialog().normalDialog(context, 'Success Sent Email',
          'กรุณาไปที่email เพื่อรีเซ็ตพาสเวิร์ด');
    }).catchError((value) {
      MyDialog().normalDialog(context, value.code, value.message);
    });
  }
}
