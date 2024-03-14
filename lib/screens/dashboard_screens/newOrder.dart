import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:secondtwo/screens/DashboardScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Helper/Seachdelegate.dart';
import '../../Helper/database.dart';

class NewOrder extends StatefulWidget {
  final String Code;
  final String customerName;
  final List<Map<String, dynamic>> orderData;
  final int recordId;
  final bool isedit;
  const NewOrder({super.key, required this.customerName, required this.orderData, required this.recordId, required this.Code, required this.isedit,});

  @override
  State<NewOrder> createState() =>NewOrderState();
}

class NewOrderState extends State<NewOrder> {

  late TextEditingController editQuanitty;
  late TextEditingController quantityController;
  late FocusNode txtcodeFocusNode;
  List<Item> items = [];
  List<dynamic> userdata = [];
  List<dynamic> filteredUserData = [];
  List<dynamic> Products = [];
  String? selectedProduct;
  late FocusNode productSearchFocusNode;
  late FocusNode quantityFocusNode;
  int totalItemCount = 0;
  String? selectedCustomer;
  List<dynamic> originalProducts = [];
  late TextEditingController txtcode;
  late TextEditingController txtname;
  late TextEditingController txtnum;
  late TextEditingController txtpro;
  late TextEditingController txtcost;

  @override
  void initState() {
    super.initState();
    editQuanitty = TextEditingController();
    quantityController = TextEditingController();
    txtcode = TextEditingController(text: widget.Code);
    txtname = TextEditingController(text: widget.customerName);
    txtnum = TextEditingController();
    txtpro = TextEditingController();
    productSearchFocusNode = FocusNode();
    quantityFocusNode = FocusNode();
    txtcodeFocusNode = FocusNode();
    _loadData();
    loadData();
    initializeOrderItems(widget.recordId);
  }

  @override
  void dispose() {
    txtcode.dispose();
    txtname.dispose();
    txtnum.dispose();
    txtpro.dispose();
    txtcodeFocusNode.dispose();
    quantityController.dispose();
    productSearchFocusNode.dispose();
    editQuanitty.dispose();// Dispose of productSearchFocusNode
    super.dispose();
  }

  void filterData(String id) {
    setState(() {
      filteredUserData = userdata
          .where((user) =>
      user['cid'].toString().startsWith(id.toLowerCase()) ||
          user['cname']
              .toString()
              .toLowerCase()
              .startsWith(id.toLowerCase()))
          .toList();
    });
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('userdata') ?? '[]';
    setState(() {
      userdata = jsonDecode(jsonData);
      filteredUserData = List.from(userdata);
    });
  }

  void filterdata (String id) {
    setState(() {
      Products = originalProducts
          .where((user) =>
      user['cid'].toString().startsWith(id.toLowerCase()) ||
          user['cname'].toString().toLowerCase().startsWith(id.toLowerCase()))
          .toList();
    });
  }


  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('Products') ?? '[]';
    setState(() {
      originalProducts = jsonDecode(jsonData);
      Products = List.from(originalProducts);
    });
  }

  void updateNameFromIdController(String idKey) {
    var idValue = txtnum.text; // Check the entered ID

    var product = originalProducts.firstWhere(
          (user) => user[idKey].toString().trim() == idValue.trim(),
      orElse: () => {'cid': '', 'cname': ''},
    ); // Check the found product

    if (product != null) {
      txtpro.text = product['cname'].toString();
    }
  }

  void forCustomer (String idKey) {
    var idValue = txtcode.text;

    var custom = userdata.firstWhere((user) =>
    user[idKey].toString().trim() == idValue.trim(),
      orElse: () => {'cid': '','cname': ''},
    );
    if (custom != null){
      txtname.text = custom['cname'].toString();
    }
  }

  void updateTotalItemCount() {
    setState(() {
      totalItemCount = items.length;
    });
  }

  void initializeOrderItems(int recordId) {
    // Initialize the items list with the transferred order data
    widget.orderData.forEach((order) {
      String itemName = order['item']?.toString() ?? 'N/A';
      String quantity = order['quantity']?.toString() ?? 'N/A';
      items.add(Item(item: itemName, quantity: quantity, itemCode: '',));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                // Customer Search Icon
                SizedBox(
                  height: 40,
                  width: 40,
                  child: CupertinoButton(
                    color: Color(0xff4a5759),
                    padding: EdgeInsets.zero,
                    child: Icon(Iconsax.search_status_1),
                    onPressed: () async {
                      String? selected = await showSearch<String>(
                        context: context,
                        delegate: MySearchDelegate(userdata),
                      );
                      if (selected != null) {
                        setState(() {
                          // Find the selected customer in the filteredUserData
                          var selectedCustomer = filteredUserData.firstWhere(
                                (user) =>
                            user['cid'].toString().trim() ==
                                selected.trim(),
                            orElse: () => {'cname: cname'},
                          );

                          // Update the text fields with cid and cname values
                          if (selectedCustomer.isNotEmpty) {
                            txtcode.text =
                                selectedCustomer['cid'].toString().trim();
                            txtname.text =
                                selectedCustomer['cname'].toString().trim();
                          }
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 3),

                SizedBox(
                  height: 40,
                  width: 72,
                  child: CupertinoTextField(
                    focusNode: txtcodeFocusNode,
                    keyboardType: TextInputType.number,
                    placeholder: 'Code',
                    placeholderStyle: TextStyle(color: Colors.black45),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: CupertinoColors.placeholderText,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    controller: txtcode,
                    onEditingComplete: () {
                      // Trigger the update when editing is complete
                      forCustomer('cid');
                      FocusScope.of(context)
                          .requestFocus(productSearchFocusNode);
                    },
                  ),
                ),
                const SizedBox(width: 3),

                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: CupertinoTextField(
                      readOnly: true,
                      controller: txtname,
                      textInputAction: TextInputAction.next,
                      placeholder: 'Customer Name',
                      placeholderStyle: TextStyle(color: Colors.black45),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: CupertinoColors.placeholderText,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),

            Row(
              children: [
                // Product Search Icon
                SizedBox(
                  height: 40,
                  width: 40,
                  child: CupertinoButton(
                    color: Color(0xff4a5759),
                    padding: EdgeInsets.zero,
                    child: Icon(Iconsax.search_status_1),
                    onPressed: () async {
                      String? selected = await showSearch<String>(
                        context: context,
                        delegate: ProductSearchDelegate(originalProducts),
                      );
                      if (selected != null) {
                        setState(() {
                          // Find the selected product in the originalProducts list
                          var selectedProductData =
                          originalProducts.firstWhere(
                                (product) =>
                            product['cid'].toString().trim() ==
                                selected.trim(),
                            orElse: () => {},
                          );

                          // Update the text fields with cid and cname values
                          if (selectedProductData.isNotEmpty) {
                            txtnum.text =
                                selectedProductData['cid'].toString().trim();
                            txtpro.text = selectedProductData['cname']
                                .toString()
                                .trim();
                          }
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 3),

                SizedBox(
                  height: 40,
                  width: 72,
                  child: CupertinoTextField(
                    focusNode: productSearchFocusNode,
                    keyboardType: TextInputType.number,
                    placeholder: 'Code',
                    placeholderStyle: TextStyle(color: Colors.black45),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: CupertinoColors.placeholderText,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    controller: txtnum,
                    onEditingComplete: () {
                      // Trigger the update when editing is complete
                      updateNameFromIdController('cid');
                      FocusScope.of(context).requestFocus(quantityFocusNode);
                    },
                  ),
                ),
                const SizedBox(width: 3),

                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: CupertinoTextField(
                      readOnly: true,
                      controller: txtpro,
                      textInputAction: TextInputAction.next,
                      placeholder: 'Product Name',
                      placeholderStyle: TextStyle(color: Colors.black45),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: CupertinoColors.placeholderText,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: 150,
              child: CupertinoTextField(
                focusNode: quantityFocusNode,
                controller: quantityController,
                keyboardType: TextInputType.number,
                placeholder: 'Quantity',
                placeholderStyle: TextStyle(color: Colors.black45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: CupertinoColors.placeholderText,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                onEditingComplete: () {
                  if (txtcode.text.isNotEmpty &&
                      txtname.text.isNotEmpty &&
                      txtnum.text.isNotEmpty &&
                      txtpro.text.isNotEmpty &&
                      quantityController.text.isNotEmpty) {
                    // Validate that the quantity is greater than 0 and remove leading zeros
                    int? quantity = int.tryParse(quantityController.text);
                    if (quantity != null && quantity > 0) {
                      // Create a formatted string to represent the item
                      // String itemDescription = '$txtnum.text - $txtpro.text';

                      setState(() {
                        // Add the formatted item description to the items list
                        items.add(Item(
                          item: txtpro.text,
                          quantity: quantity.toString(),
                          itemCode: txtnum.text,
                        ));

                        updateTotalItemCount();

                        // Clear text fields and selections after adding an item
                        quantityController.text = '';
                        txtnum.text = '';
                        txtpro.text = '';
                        selectedCustomer = null;
                        selectedProduct = null;
                      });
                      productSearchFocusNode.requestFocus();
                    } else {
                      // Show an error or handle the case where the quantity is not valid
                      print('Invalid quantity. Please enter a valid quantity greater than 0.');
                    }
                  }
                },

                // Add Item Icon Button
                suffix: CupertinoButton(
                  onPressed: () {
                    // Check if all required fields are filled
                    if (txtcode.text.isNotEmpty &&
                        txtname.text.isNotEmpty &&
                        txtnum.text.isNotEmpty &&
                        txtpro.text.isNotEmpty &&
                        quantityController.text.isNotEmpty) {
                      // Validate that the quantity is greater than 0 and remove leading zeros
                      int? quantity = int.tryParse(quantityController.text);
                      if (quantity != null && quantity > 0) {
                        // Create a formatted string to represent the item
                        // String itemDescription = '$txtnum.text - $txtpro.text';

                        setState(() {
                          // Add the formatted item description to the items list
                          items.add(Item(
                            item: txtpro.text,
                            quantity: quantity.toString(),
                            itemCode: txtnum.text,
                          ));

                          updateTotalItemCount();

                          // Clear text fields and selections after adding an item
                          quantityController.text = '';
                          txtnum.text = '';
                          txtpro.text = '';
                          selectedCustomer = null;
                          selectedProduct = null;
                        });
                        productSearchFocusNode.requestFocus();
                      } else {
                        // Show an error or handle the case where the quantity is not valid
                        print('Invalid quantity. Please enter a valid quantity greater than 0.');
                      }
                    }
                  },
                  color: Color(0xff4a5759),
                  padding: EdgeInsets.zero,
                  child: const Icon(Iconsax.direct_right),
                ),
                // Add Item Button close coding
              ),
            ),
            const SizedBox(height: 10),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Product Name',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                Text('Quantity',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ],
            ),

            // List View Widget
            Expanded(
              child: SlidableAutoCloseBehavior(
                closeWhenOpened: true,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) => Slidable(
                    endActionPane:
                    ActionPane(motion: const StretchMotion(), children: [
                      // edit and delete buttons

                      SlidableAction(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.green,
                        label: 'Edit',
                        onPressed: (context) {
                          editQuanitty.text = '';
                          showDialog(context: context, builder: (context){
                            return AlertDialog(
                              title: const Text('Edit Quantity'),
                              actions: [
                                TextFormField(
                                  controller: editQuanitty,
                                  keyboardType: TextInputType.number,
                                  onEditingComplete: (){
                                    String newQuantity = editQuanitty.text.trim();
                                    if (newQuantity.isNotEmpty) {
                                      setState(() {
                                        items[index].quantity = newQuantity;
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter new quantity',
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    String newQuantity = editQuanitty.text.trim();
                                    if (newQuantity.isNotEmpty) {
                                      setState(() {
                                        items[index].quantity = newQuantity;
                                      });
                                    }
                                    Navigator.pop(context); // Close the bottom sheet
                                  },
                                  child: Text('Save'),
                                ),
                              ],
                            );
                          });
                        },
                      ),
                      SlidableAction(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.red,
                        label: 'Delete',
                        onPressed: (context) {
                          setState(() {
                            items.removeAt(index);
                            updateTotalItemCount();
                          });
                        },
                      ),
                    ]),
                    child: getRow(index),
                  ),
                ),
              ),
            ),

            // Bottom Buttons Row Widget
            Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 35,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Total Items',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                            text: totalItemCount.toString()),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // order save button
                    SizedBox(
                      height: 35,
                      child: CupertinoButton(
                        onPressed: widget.isedit? null: () async {
                          // Check if all required fields are filled
                          if (txtcode.text.isNotEmpty && txtname.text.isNotEmpty && items.isNotEmpty) {
                            try {
                              // Show a confirmation dialog
                              bool confirm = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Save Data'),
                                    content: Text('Are you sure to save the data?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          // Close the dialog and return false
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Close the dialog and return true
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              // If the user confirms, proceed with saving the data
                              if (confirm == true) {
                                // Initialize the LocalDatabase
                                LocalDatabase localDatabase = LocalDatabase();
                                // Initialize the local database if not already initialized
                                await localDatabase.initDatabase();
                                // Convert the items to a list of Map<String, dynamic>
                                List<Map<String, dynamic>> itemsAsMaps = items.map((item) {
                                  return {
                                    'Code': txtcode.text ?? '',
                                    'Name': txtname.text ?? '',
                                    'itemCode': item.itemCode ?? '',
                                    'item': item.item ?? '',  // Use item.item directly from the specific item
                                    'quantity': item.quantity ?? '',  // Use item.quantity directly from the specific item
                                  };
                                }).toList();


                                SharedPreferences _preferences = await SharedPreferences.getInstance();
                                String isaleman = _preferences.getString('jcid') ?? '';
                                String iName =  _preferences.getString('jcname') ?? '';



                                await localDatabase.addApiDataLocally(
                                    txtcode.text,
                                    txtname.text,
                                    itemsAsMaps,
                                    isaleman// Use item.quantity directly from the specific item
                                  );
                                print(isaleman);


                                // for (var item in items) {
                                //   await localDatabase.addDataLocally(
                                //     txtcode.text,
                                //     txtname.text,
                                //     item.itemCode,
                                //     item.item,  // Use item.item directly from the specific item
                                //     item.quantity,
                                //   );
                                // }

                                await localDatabase.readalldata();
                                quantityController.text = '';
                                txtname.text = '';
                                txtcode.text = '';
                                txtnum.text = '';
                                txtpro.text = '';
                                selectedCustomer = null;
                                selectedProduct = null;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => DashboardScreen(cname: iName,)),
                                );

                                // print('Sale data saved to the database successfully');
                                // print('Name: ${txtname.text}');
                                // itemsAsMaps.forEach((item) {
                                //   print('  Item: ${item['item']}, Quantity: ${item['quantity']}');
                                // });
                              }
                            } catch (e) {
                              print('Error saving sale data to the database: $e');
                              // Handle the error or notify the user accordingly.
                            }
                            txtcodeFocusNode.requestFocus();
                          }
                        },
                        color: Color(0xff4a5759),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        borderRadius: BorderRadius.circular(5),
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),

                    // Order Update Button
                    CupertinoButton(
                      color: Color(0xffe8e8e4),
                      padding: EdgeInsets.all(5),
                      borderRadius: BorderRadius.circular(10),
                      onPressed: widget.isedit
                          ? () async {
                        bool confirm = await Get.defaultDialog(
                          title: 'Confirmation',
                          content: Row(
                            children: [
                              CupertinoButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  // Close the dialog and return false
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              CupertinoButton(
                                child: const Text('Confirm'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          Navigator.pop(context, true);

                          // Use the existing instance of LocalDatabase
                          LocalDatabase local = LocalDatabase();

                          List<Map<String, dynamic>> itemsAsMaps =
                          items.map((item) {
                            return {
                              'item': item.item ?? '',
                              'quantity': item.quantity ?? '',
                            };
                          }).toList();

                          // Use the recordId received from the previous screen
                          await local.Updatedata(
                              txtcode.text, txtname.text, itemsAsMaps, widget.recordId);
                        }
                      }
                          : null, // Set onPressed to null when widget.isedit is false
                      child: Row(
                        children: [
                          Image.asset('assets/icons/update.png', scale: 15),
                          Text(
                            'Update',
                            style: TextStyle(fontSize: 15, color: Colors.teal.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget getRow(int index) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 50,child: Text(items[index].itemCode),),
          Expanded(
            child: Text(
              items[index].item,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(
            child: Text(
              items[index].quantity,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class Item {
  String itemCode;
  String item;
  String quantity;

  Item({required this.item,required this.itemCode ,required this.quantity});
}