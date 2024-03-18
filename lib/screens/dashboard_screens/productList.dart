import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DashboardScreen.dart';

class productList extends StatefulWidget {
  const productList({super.key});

  @override
  State<productList> createState() => _productListState();
}

class _productListState extends State<productList> {
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  List<dynamic> Products = [];
  List<dynamic> UserData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void filterData(String id) {
    setState(() {
      UserData = Products.where((user) =>
              user['cid'].toString().contains(id.toLowerCase()) ||
              user['cname'].toString().toLowerCase().contains(id.toLowerCase()))
          .toList();
    });
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('Products') ?? '[]';
    setState(() {
      Products = jsonDecode(jsonData);
      UserData = List.from(Products);
    });
  }

  // void updateNameFromIdController(String idKey) {
  //   var idValue = idController.text;
  //   // Check the entered ID
  //
  //   var product = Products.firstWhere(
  //         (user) => user[idKey].toString().trim() == idValue.trim(),
  //     orElse: () => {'cid': '', 'cname': ''},
  //   );
  //
  //   if (product != null) {
  //     nameController.text = product['cname'].toString();
  //   } else {
  //
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, right: 15, left: 15),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black12,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_outlined),
                    ),
                    onTap: () async {
                      SharedPreferences _preferences =
                          await SharedPreferences.getInstance();
                      String isaleman = _preferences.getString('jcname') ?? '';
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardScreen(
                                    cname: isaleman,
                                  )));
                    },
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black12,
                      ),
                      child: TextFormField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          hintText: ' Search Product',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     SizedBox(
              //       width: 80,
              //       child: TextField(
              //         controller: idController,
              //         keyboardType: TextInputType.number,
              //         decoration: InputDecoration(
              //           labelText: 'Enter ID',
              //         ),
              //         onEditingComplete: () {
              //           // Trigger the update when editing is complete
              //           updateNameFromIdController('cid');
              //         },
              //       ),
              //     ),
              //     const SizedBox(width: 5),
              //     Expanded(
              //       child: TextField(
              //         controller: nameController,
              //         readOnly: true,
              //         decoration: InputDecoration(
              //           labelText: 'Name',
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('code'),
              //     Text('products'),
              //     Text('cost price'),
              //   ],
              // ),
              Expanded(
                child: ListView.builder(
                  itemCount: UserData.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text(UserData[index]['cid'] ?? ''),
                      title: Text(UserData[index]['cname'] ?? ''),
                      trailing: Text(UserData[index]['cost_price'] ?? ''),
                      onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
