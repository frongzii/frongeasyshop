import 'package:flutter/material.dart';
class EditProfileShop extends StatefulWidget {
  const EditProfileShop({ Key? key }) : super(key: key);

  @override
  _EditProfileShopState createState() => _EditProfileShopState();
}

class _EditProfileShopState extends State<EditProfileShop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('แก้ไขข้อมูลร้านค้า'),),
    body: Text('Edit Profile'),
      
    );
  }
}