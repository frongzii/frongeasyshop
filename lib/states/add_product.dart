import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/product_model.dart';
import 'package:frongeasyshop/models/stock_model.dart';
import 'package:frongeasyshop/utility/my_constant.dart';
import 'package:frongeasyshop/utility/my_dialog.dart';
import 'package:frongeasyshop/widgets/show_svg.dart';
import 'package:frongeasyshop/widgets/show_text.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  final StockModel stockModel;
  final String docStock;
  const AddProduct({Key? key, required this.stockModel, required this.docStock})
      : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  StockModel? stockModel;
  File? file;

  final formKey = GlobalKey<FormState>();
  TextEditingController nameProductColtroller = TextEditingController();
  TextEditingController amangProductColtroller = TextEditingController();
  TextEditingController priceProductColtroller = TextEditingController();
  String? docStock, uidUserlogin;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    stockModel = widget.stockModel;
    docStock = widget.docStock;
    findUidUser();
  }

  Future<void> findUidUser() async {
    await FirebaseAuth.instance.authStateChanges().listen((event) {
      uidUserlogin = event!.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyConstant.primart,
        title: Text('เพิ่มสินค้า ในกลุ่ม ${stockModel!.cat}'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(
          FocusScopeNode(),
        ),
        behavior: HitTestBehavior.opaque,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildImage(),
                buildName(),
                buildStock(),
                buildPrice(),
                buildSave(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildSave() {
    return Container(
      width: 250,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            if (file == null) {
              MyDialog().normalDialog(context, 'ยังไม่มีรูปภาพ',
                  'กรุณา ถ่ายภาพ หรือ เลือกรูปภาพจากคลัง');
            } else {
              processUploadAndInsertProduct();
            }
          }
        },
        child: const Text('Save'),
        style: MyConstant().myButtonStyle(),
      ),
    );
  }

  Container buildPrice() {
    return Container(
      width: 250,
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกราคาสินค้า';
          } else {
            return null;
          }
        },
        controller: priceProductColtroller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          label: ShowText(title: 'ราคาของสินค้า'),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Container buildName() {
    return Container(
      width: 250,
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกชื่อสินค้า';
          } else {
            return null;
          }
        },
        controller: nameProductColtroller,
        decoration: const InputDecoration(
          label: ShowText(title: 'ชื่อสินค้า'),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Container buildStock() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      width: 250,
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกจำนวนสินค้า';
          } else {
            return null;
          }
        },
        controller: amangProductColtroller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          label: ShowText(title: 'จำนวนสินค้า'),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> processTakePhoto(ImageSource source) async {
    try {
      var result = await ImagePicker()
          .pickImage(source: source, maxWidth: 800, maxHeight: 800);
      setState(() {
        file = File(result!.path);
      });
    } catch (e) {}
  }

  Row buildImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => processTakePhoto(ImageSource.camera),
          icon: const Icon(Icons.add_a_photo),
        ),
        Container(
          width: 150,
          height: 150,
          child: file == null ? const ShowImage() : Image.file(file!),
        ),
        IconButton(
          onPressed: () => processTakePhoto(ImageSource.gallery),
          icon: const Icon(Icons.add_photo_alternate),
        ),
      ],
    );
  }

  Future<void> processUploadAndInsertProduct() async {
    String nameFile = 'product${Random().nextInt(1000000)}.jpg';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child('Product/$nameFile');
    UploadTask task = reference.putFile(file!);
    await task.whenComplete(() async {
      await reference.getDownloadURL().then((value) async {
        var path = value.toString();
        print('path ==> $path');
        ProductModel model = ProductModel(
            nameProduct: nameProductColtroller.text,
            amountProduct: int.parse(amangProductColtroller.text),
            priceProduct: int.parse(priceProductColtroller.text),
            pathProduct: path);

        await FirebaseFirestore.instance
            .collection('user')
            .doc(uidUserlogin)
            .collection('stock')
            .doc(docStock)
            .collection('product')
            .doc()
            .set(model.toMap()).then((value) => Navigator.pop(context));
      });
    });
  }
}
