import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frongeasyshop/widgets/show_form.dart';
import 'package:frongeasyshop/widgets/show_process.dart';
import 'package:geolocator/geolocator.dart';

class InsertProfileShop extends StatefulWidget {
  const InsertProfileShop({Key? key}) : super(key: key);

  @override
  _InsertProfileShopState createState() => _InsertProfileShopState();
}

class _InsertProfileShopState extends State<InsertProfileShop> {
  final formKey = GlobalKey<FormState>();
  String? name, address, phone;
  double? lat, long;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    findlatlng();
  }

  Future<void> findlatlng() async {
    LocationPermission locationPermission;
    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        exit(0);
      }
    }

    Position? position = await findPosition();
    if (position != null) {
      setState(() {
        lat = position.latitude;
        long = position.longitude;
        print('$lat,$long');
      });
    }
  }

  Future<Position?> findPosition() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มข้อมูลร้านค้า'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(
          FocusScopeNode(),
        ),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                ShowForm(
                  title: 'ชื่อร้านค้า : ',
                  myValidate: namevalidate,
                  mysave: nameSave,
                ),
                ShowForm(
                  title: 'ที่อยู่ : ',
                  mysave: addressSave,
                  myValidate: addressvalidate,
                ),
                ShowForm(
                  title: 'เบอร์โทรศัพท์ : ',
                  mysave: phomeSave,
                  myValidate: phonevalidate,
                ),
                Container(margin: EdgeInsets.all(16),
                  width: 300,
                  height: 200,
                  child: lat == null ? ShowProcess() : Text('$lat,$long'),
                ),
                buttonSave(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void nameSave(String? string) {
    name = string;
  }

  void addressSave(String? string) {
    address = string;
  }

  void phomeSave(String? string) {
    phone = string;
  }

  String? namevalidate(String? string) {
    if (string!.isEmpty) {
      return 'กรุณากรอกชื่อร้าน';
    } else {
      return null;
    }
  }

  String? addressvalidate(String? string) {
    if (string!.isEmpty) {
      return 'กรุณากรอกที่อยู่ร้าน';
    } else {
      return null;
    }
  }

  String? phonevalidate(String? string) {
    if (string!.isEmpty) {
      return 'กรุณากรอกเบอร์โทรศัพท์';
    } else {
      return null;
    }
  }

  Container buttonSave() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: 250,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState?.save();
            print('name =$name, address = $address, phone =$phone');
          }
        },
        child: const Text('Save'),
      ),
    );
  }
}
