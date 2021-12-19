import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/profile_shop_model.dart';
import 'package:frongeasyshop/utility/my_dialog.dart';
import 'package:frongeasyshop/widgets/show_form.dart';
import 'package:frongeasyshop/widgets/show_process.dart';
import 'package:frongeasyshop/widgets/show_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class InsertProfileShop extends StatefulWidget {
  const InsertProfileShop({Key? key}) : super(key: key);

  @override
  _InsertProfileShopState createState() => _InsertProfileShopState();
}

class _InsertProfileShopState extends State<InsertProfileShop> {
  final formKey = GlobalKey<FormState>();
  String? name, address, phone, docIdUser;
  double? lat, long;
  File? file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    findlatlng();
    findDocIdUser();
  }

  Future<void> findDocIdUser() async {
    await FirebaseAuth.instance.authStateChanges().listen((event) {
      docIdUser = event!.uid;
    });
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
            child: SingleChildScrollView(
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
                  showMap(),
                  showImage(),
                  buttonSave(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> choseSource(ImageSource imageSource) async {
    try {
      var result = await ImagePicker().pickImage(
        source: imageSource,
        maxHeight: 800,
        maxWidth: 800,
      );
      setState(() {
        file = File(result!.path);
      });
    } catch (e) {}
  }

  SizedBox showImage() {
    return SizedBox(
      width: 300,
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => choseSource(ImageSource.camera),
            icon: const Icon(Icons.add_a_photo),
          ),
          file == null
              ? const SizedBox(
                  height: 180,
                  width: 180,
                  child: ShowImage(),
                )
              : Container(
                  width: 180,
                  height: 180,
                  child: Image.file(file!),
                ),
          IconButton(
            onPressed: () => choseSource(ImageSource.gallery),
            icon: const Icon(Icons.add_photo_alternate),
          ),
        ],
      ),
    );
  }

  Set<Marker> myMarkkers() {
    return <Marker>[
      Marker(
        markerId: MarkerId('id'),
        position: LatLng(lat!, long!),
        infoWindow: InfoWindow(title: 'คุณอยู่ที่นี่', snippet: '[$lat,$long]'),
      ),
    ].toSet();
  }

  Container showMap() {
    return Container(
      margin: EdgeInsets.all(16),
      width: 300,
      height: 200,
      child: lat == null
          ? ShowProcess()
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat!, long!),
                zoom: 18,
              ),
              onMapCreated: (controller) {},
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
            if (file == null) {
              MyDialog().normalDialog(context, 'No Image', 'please take photo');
            } else {
              processUploadAndInsertProfile();
            }
          }
        },
        child: const Text('Save'),
      ),
    );
  }

  Future<void> processUploadAndInsertProfile() async {
    var nameFile = 'shop${Random().nextInt(1000000)}.jpg';
    print('@@ namefile == > $nameFile');
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    Reference reference = firebaseStorage.ref().child('shop/$nameFile');
    UploadTask uploadTask = reference.putFile(file!);
    await uploadTask.whenComplete(() async {
      await reference.getDownloadURL().then((value) async {
        var path = value.toString();
        print('@@ path ===> $path');

        ProfileShopModel model = ProfileShopModel(
            nameShop: name!,
            address: address!,
            phone: phone!,
            lat: lat!,
            long: long!,
            pathImage: path,
            product: false);

        await FirebaseFirestore.instance
            .collection('user')
            .doc(docIdUser)
            .collection('profile')
            .doc()
            .set(model.toMap())
            .then((value) => Navigator.pop(context),);
      });
    });
  }
}
