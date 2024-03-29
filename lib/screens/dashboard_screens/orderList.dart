import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as location_package;
import 'package:location/location.dart';
import '../../Helper/database.dart';
import 'newOrder.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class SaveData extends StatefulWidget {
  const SaveData({super.key});

  @override
  State<SaveData> createState() => _SaveDataState();
}

class _SaveDataState extends State<SaveData> {
  List<Map<String, dynamic>> savedData = [];
  List<Map<String, dynamic>> filteredData = [];
  TextEditingController idController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool isPostDataCalled = false;
  location_package.Location location = location_package.Location();
  bool isUploadConfirmed = false;
  double perc = 0;

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
    _getCurrentAddress();
  }

  Future<String> _getCurrentAddress() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Check if location service is enabled, if not, request it.
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Handle if the user refuses to enable location service.
        throw 'Location service is disabled.';
      }
    }

    // Check if permission is granted, if not, request it.
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // Handle if the user refuses to grant location permission.
        throw 'Location permission is denied.';
      }
    }

    // Get the current location.
    locationData = await location.getLocation();
    double latitude = locationData.latitude!;
    double longitude = locationData.longitude!;

// Use geocoding to convert coordinates to address.
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    // Extract the address from the placemark.
    Placemark placemark = placemarks[0];
    String address =
        "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";

    // Return the address.
    return address;
  }

  Future<void> fetchDataFromDatabase() async {
    try {
      // Initialize the LocalDatabase
      LocalDatabase localDatabase = LocalDatabase();

      // Initialize the local database if not already initialized
      await localDatabase.initDatabase();

      // Retrieve the saved data from the local database
      var data = await localDatabase.readalldata();

      // Ensure data is not null
      savedData = data;
      filteredData =
          List.from(savedData); // Initialize filteredData with all data

      setState(() {});
    } catch (e) {
      // Handle the error or notify the user accordingly.
    }
  }

  void filterData() {
    String idQuery = idController.text.toLowerCase();
    String dateQuery = dateController.text.toLowerCase();
    String nameQuery = nameController.text.toLowerCase();

    filteredData = savedData.where((data) {
      int orderId = savedData.indexOf(data) + 1; // Auto-incremented ID
      String date =
          formattedDate(data['date_time']); // Extract date without time

      return orderId.toString().startsWith(idQuery) &&
          date.toLowerCase().contains(dateQuery) &&
          data['customerName']!.toString().toLowerCase().startsWith(nameQuery);
    }).toList();

    setState(() {});
  }

  void _showUploadOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitCircle(color: Colors.deepPurple),
                // Or any other loading indicator
                SizedBox(height: 20),
                Text('Uploading Data...'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideUploadOverlay() {
    Navigator.of(context).pop();
  }

  void postData() async {
    setState(() {
      isUploadConfirmed = true;
    });
    if (isPostDataCalled) {
      return; // If already uploading, do nothing
    }
    try {
      _showUploadOverlay();
      String url = 'http://isofttouch.com/eorder/insert1.php';

      String currentAddress = await _getCurrentAddress();
      // int uploadedItems = 0;
      //
      // // Calculate the total number of items for percentage calculation
      // int totalNumberOfItems = 0;
      // for (var data in filteredData) {
      //   totalNumberOfItems += (jsonDecode(data['order_data']) as List).length;
      // }

      // Construct the data to send to the API
      for (var data in filteredData) {
        try {
          String orderno = data['autonumber']?.toString() ?? '';
          String uploadStatus = data['upload']?.toString() ?? 'No';

          // Check if the item has already been uploaded
          if (uploadStatus == 'Yes') {
            continue;
          }

          String customerCode = data['customerCode']?.toString() ?? '';
          String customerName = data['customerName']?.toString() ?? '';
          String OrderdataString = data['order_data']?.toString() ?? '';
          String isaleman = data['isaleman']?.toString() ?? '';
          String idate = data['date_time']?.toString() ?? '';
          String currentDate = DateFormat('y/M/d').format(DateTime.now());

          List<Map<String, dynamic>> orderData =
              (jsonDecode(OrderdataString) as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .toList();

          for (var order in orderData) {
            String itemCode = order['itemCode']?.toString() ?? 'N/A';
            String itemName = order['item']?.toString() ?? 'N/A';
            String quantity = order['quantity']?.toString() ?? 'N/A';

            var post = await http.post(Uri.parse(url), body: {
              'orderno': orderno,
              'icucode': customerCode,
              'icuname': customerName,
              'itemcode': itemCode,
              'itemname': itemName,
              'quantity': quantity,
              'salesman': isaleman,
              'cdate': currentDate,
              'cdatetime': idate,
              'clocation': currentAddress
            });


            // uploadedItems++;
            // // Calculate percentage and update the state
            // double progress = uploadedItems / totalNumberOfItems;
            // setState(() {
            //   perc = progress.clamp(
            //       0.0, 1.0); // Clamp perc value to range [0.0, 1.0]
            // });
            //
            // print('Updating perc variable...');
            // print('Current value of perc: $perc');
            // Update the upload status to 'Yes' after successful API response
            if (post.statusCode == 200) {
              LocalDatabase localDatabase = LocalDatabase();
              await localDatabase.updateUploadStatus(orderno);
              // Update filteredData immediately after successful upload
            }
          }
        } catch (e) {
        }
      }
      setState(() {
        isUploadConfirmed = false;
      });
      _hideUploadOverlay();
      // After the upload process is complete, dismiss the dialog
      // Navigator.pop(context); // Close the dialog

    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Save Data',
          // style: GoogleFonts.dancingScript(
          //   fontSize: 25,
          //   fontWeight: FontWeight.bold,
          //  )
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),

            // Date Search Bar
            child: SizedBox(
              width: 120,
              child: CupertinoTextField(
                controller: dateController,
                padding: const EdgeInsets.all(10),
                placeholder: 'Search Date',
                placeholderStyle: const TextStyle(color: Colors.black45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: CupertinoColors.placeholderText,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                onChanged: (value) {
                  filterData();
                },
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: CupertinoTextField(
                    controller: idController,
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.all(10),
                    placeholder: 'Auto No',
                    placeholderStyle: const TextStyle(color: Colors.black45),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: CupertinoColors.placeholderText,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onChanged: (value) {
                      filterData();
                    },
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: CupertinoTextField(
                    controller: nameController,
                    padding: const EdgeInsets.all(10),
                    placeholder: 'Search Name',
                    placeholderStyle: const TextStyle(color: Colors.black45),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(
                        Iconsax.search_normal_1,
                        color: Colors.grey,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: CupertinoColors.placeholderText,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onChanged: (value) {
                      filterData();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Your main content
          RefreshIndicator(
            onRefresh: () async {
              await fetchDataFromDatabase();
            },
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      int reversedIndex = filteredData.length - 1 - index;

                      int orderId = reversedIndex + 1;
                      String Code = filteredData[reversedIndex]['customerCode']
                              ?.toString() ??
                          'N/A';
                      String customerName = filteredData[reversedIndex]
                                  ['customerName']
                              ?.toString() ??
                          'N/A';
                      String orderDataString = filteredData[reversedIndex]
                                  ['order_data']
                              ?.toString() ??
                          '';

                      List<Map<String, dynamic>> orderData =
                          (jsonDecode(orderDataString) as List<dynamic>)
                              .cast<Map<String, dynamic>>()
                              .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        // Ensures children widgets expand horizontally
                        children: [
                          if (reversedIndex == filteredData.length - 1 ||
                              !isSameDay(
                                  filteredData[reversedIndex + 1]['date_time'],
                                  filteredData[reversedIndex]['date_time']))
                            // Date Field Container
                            Container(
                              // Wrap the Row inside a Container to ensure it expands horizontally
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    formattedDate(filteredData[reversedIndex]
                                        ['date_time']),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      Get.defaultDialog(
                                        title: 'Confirmation',
                                        content: Row(
                                          children: [
                                            CupertinoButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                // Close the dialog and return false
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                            ),
                                            CupertinoButton(
                                              child: const Text('Confirm'),
                                              onPressed: () async {
                                                if (!isPostDataCalled) {
                                                  postData();
                                                  isPostDataCalled = true;
                                                }
                                                Navigator.of(context).pop(true);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                  // (!isUploadConfirmed)
                                  //     ? Container()
                                  //     : CircularPercentIndicator(
                                  //         radius: 30,
                                  //         animation: true,
                                  //         lineWidth: 10,
                                  //         percent: perc.clamp(0.0, 1.0),
                                  //         // Clamp perc value to range [0.0, 1.0]
                                  //         // Ensure that perc reaches 100% before stopping animation
                                  //         onAnimationEnd: () {
                                  //           setState(() {
                                  //             perc =
                                  //                 1.0; // Set perc to 100% when animation completes
                                  //           });
                                  //         },
                                  //         // Convert perc to percentage for display (1 to 100)
                                  //         center: Text(
                                  //           '${(perc * 100).toInt()}%',
                                  //           // Display percentage from 1 to 100
                                  //           style: TextStyle(
                                  //             fontSize: 12,
                                  //             color: Colors.deepPurple,
                                  //           ),
                                  //         ),
                                  //         progressColor: Colors.deepPurple,
                                  //         backgroundColor:
                                  //             Colors.deepPurple.shade100,
                                  //         circularStrokeCap:
                                  //             CircularStrokeCap.round,
                                  //       ),
                                ],
                              ),
                            ),

                          // Order Invoice Card Widget
                          Card(
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Theme(
                              data: Theme.of(context)
                                  .copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: Text(
                                  '$orderId',
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.red),
                                ),
                                title: Text(
                                  customerName,
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: Text(
                                  filteredData[reversedIndex]['upload'] == 'Yes'
                                      ? 'Uploaded'
                                      : '',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                children: [
                                  ...orderData.map((order) {
                                    String itemName =
                                        order['item']?.toString() ?? 'N/A';
                                    String quantity =
                                        order['quantity']?.toString() ?? 'N/A';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              itemName,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                          SizedBox(
                                            child: Text(
                                              quantity,
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          height: 23,
                                          child: CupertinoButton(
                                            color: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: const Text(
                                              'Edit Order',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            onPressed: () {
                                              if (filteredData[reversedIndex]
                                                      ['upload'] !=
                                                  'Yes') {
                                                Get.defaultDialog(
                                                  title: 'Confirmation',
                                                  content: Row(
                                                    children: [
                                                      CupertinoButton(
                                                        child: const Text(
                                                            'Cancel'),
                                                        onPressed: () {
                                                          // Close the dialog and return false
                                                          Navigator.of(context)
                                                              .pop(false);
                                                        },
                                                      ),
                                                      CupertinoButton(
                                                        child: const Text(
                                                            'Confirm'),
                                                        onPressed: () async {
                                                          if (orderData
                                                                  .isNotEmpty &&
                                                              customerName
                                                                  .isNotEmpty) {
                                                            int recordId =
                                                                orderId;

                                                            bool result =
                                                                await Navigator
                                                                    .push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        NewOrder(
                                                                  Code: Code,
                                                                  customerName:
                                                                      customerName,
                                                                  orderData:
                                                                      orderData,
                                                                  recordId:
                                                                      recordId,
                                                                  isedit: true,
                                                                ),
                                                              ),
                                                            );

                                                            if (result) {
                                                              await fetchDataFromDatabase();
                                                              setState(() {});
                                                            }
                                                          }
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: 23,
                                          child: CupertinoButton(
                                            color: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: const Text(
                                              'Delete Order',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            onPressed: () async {
                                              if (filteredData[reversedIndex]
                                                      ['upload'] !=
                                                  'Yes') {
                                                Get.defaultDialog(
                                                  title: 'Confirmation',
                                                  content: Row(
                                                    children: [
                                                      CupertinoButton(
                                                        child: const Text(
                                                            'Cancel'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(false);
                                                        },
                                                      ),
                                                      CupertinoButton(
                                                        child: const Text(
                                                            'Confirm'),
                                                        onPressed: () async {
                                                          int orderIdToDelete =
                                                              filteredData[
                                                                      reversedIndex]
                                                                  [
                                                                  'autonumber'];
                                                          LocalDatabase
                                                              localDatabase =
                                                              LocalDatabase();
                                                          await localDatabase
                                                              .Deletedb(
                                                                  orderIdToDelete);
                                                          setState(() {
                                                            // Remove the deleted order from filteredData
                                                            filteredData.removeAt(
                                                                reversedIndex);
                                                          });
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            formattedTime(
                                                filteredData[reversedIndex]
                                                    ['date_time']),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isUploadConfirmed)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(), // or any other widget
              ),
            ),
        ],
      ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     postData(Selecteddate);
      //   },
      //   elevation: 10,
      //   backgroundColor: Color(0xff4a5759),
      //   label: Text(
      //     'Upload Data',
      //     style: TextStyle(color: Colors.white, fontSize: 16),
      //   ),
      // ),
    );
  }

  bool isSameDay(String dateTime1, String dateTime2) {
    DateTime date1 = DateTime.parse(dateTime1);
    DateTime date2 = DateTime.parse(dateTime2);

    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String formattedTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('hh:mm a')
        .format(dateTime); // Use 'hh:mm a' format for hours, minutes, and AM/PM
  }

  // Helper function to format date
  String formattedDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('MMMM d, y').format(dateTime);
  }
}
