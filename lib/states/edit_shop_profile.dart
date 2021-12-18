import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/widgets/show_process.dart';
import 'package:frongeasyshop/widgets/show_text.dart';
//import 'package:frongeasyshop/widgets/show_signout.dart';

class EditShopProFile extends StatefulWidget {
  const EditShopProFile({Key? key}) : super(key: key);

  @override
  _EditShopProFileState createState() => _EditShopProFileState();
}

class _EditShopProFileState extends State<EditShopProFile> {
  var load = true;
  String? uidLogin;
  bool? haveProfile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readProfileshop();
  }

  Future<void> readProfileshop() async {
    await FirebaseAuth.instance.authStateChanges().listen((event) async {
      uidLogin = event!.uid;
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uidLogin)
          .collection('profile')
          .get()
          .then((value) {
        print('value ====>>>${value.docs}');
        if (value.docs.isEmpty) {
          setState(() {
            haveProfile = false;
            load = false;
          });
        } else {
          setState(() {
            haveProfile = true;
            load = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: haveProfile == null ? const SizedBox() :buttonInsertOrEdit(context),
      appBar: AppBar(
        backgroundColor: MyConstant.primart,
        title: const Text('แก้ไขข้อมูลร้านค้า'),
      ),
      body: load
          ? ShowProcess()
          : haveProfile!
              ? const Text('have Data')
              : Center(
                  child: ShowText(
                    title: 'No Profile',
                    textStyle: MyConstant().h2Style(),
                  ),
                ),
    );
  }

  ElevatedButton buttonInsertOrEdit(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (haveProfile!) {
          Navigator.pushNamed(context, MyConstant.routEditProfileshop);
        } else {
          Navigator.pushNamed(context, MyConstant.routInsertProfileShop);
        }
      },
      child: Text('InsertProFile'),
    );
  }
}
