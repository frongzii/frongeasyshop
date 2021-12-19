import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frongeasyshop/models/profile_shop_model.dart';
import 'package:frongeasyshop/widgets/show_process.dart';
import 'package:frongeasyshop/widgets/show_text.dart';

class ShowShopForBuyer extends StatefulWidget {
  const ShowShopForBuyer({Key? key}) : super(key: key);

  @override
  _ShowShopForBuyerState createState() => _ShowShopForBuyerState();
}

class _ShowShopForBuyerState extends State<ShowShopForBuyer> {
  var profileShopModels = <ProfileShopModel>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readShop();
  }

  Future<void> readShop() async {
    await FirebaseFirestore.instance
        .collection('user')
        .get()
        .then((value) async {
      for (var item in value.docs) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(item.id)
            .collection('profile')
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            // print('@@ ${value.docs}');
            for (var item in value.docs) {
              ProfileShopModel profileShopModel =
                  ProfileShopModel.fromMap(item.data());
              if (profileShopModel.product) {
                // print('@@ nameShop ==> ${profileShopModel.nameShop}');
                setState(() {
                  profileShopModels.add(profileShopModel);
                });
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: profileShopModels.isEmpty
          ? const ShowProcess()
          : ListView.builder(
              itemCount: profileShopModels.length,
              itemBuilder: (context, index) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(width: 150,height: 120,
                        child: Image.network(profileShopModels[index].pathImage),
                      ),
                      ShowText(title: profileShopModels[index].nameShop),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
