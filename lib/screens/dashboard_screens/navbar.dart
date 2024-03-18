import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../LoginScreen.dart';
import 'about.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  List<dynamic> userdata = [];
  List<dynamic> filteredUserData = [];
  late SharedPreferences logindata;
  late String ready;
  List<dynamic> Products = [];
  List<dynamic> UserData = [];

  @override
  void initState() {
    super.initState();
    initial();
  }

  Future<void> getRecords() async {
    String uri = "http://isofttouch.com/eorder/product.php";
    try {
      var response = await http.get(Uri.parse(uri));
      setState(() {
        Products = jsonDecode(response.body);
        saveData(Products);
        UserData = List.from(Products);
        print('Products: $Products');
      });
    } catch (e) {}
  }

  Future<void> saveData(List<dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(data);
    await prefs.setString('Products', jsonData);
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('Products') ?? '[]';
    setState(() {
      Products = jsonDecode(jsonData);
      UserData = List.from(Products);
    });
  }

  Future<void> _getRecords() async {
    String uri = "http://isofttouch.com/eorder/view_data.php";
    try {
      var response = await http.get(Uri.parse(uri));
      setState(() {
        userdata = jsonDecode(response.body);
        isaveData(userdata);
        filteredUserData = List.from(userdata);
        print('userdata: $userdata');
      });
    } catch (e) {}
  }

  Future<void> isaveData(List<dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(data);
    await prefs.setString('userdata', jsonData);
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('userdata') ?? '[]';
    setState(() {
      userdata = jsonDecode(jsonData);
      filteredUserData = List.from(userdata);
    });
    isaveData(userdata);
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    String? data = logindata.getString('data');
    setState(() {
      ready = data ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blueGrey[50],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture:
                Image.asset('assets/images/softtouch_black.png'),
            currentAccountPictureSize: Size(150, 50),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
            accountName: Text('isofttouch.com'),
            accountEmail: Text('softtouchpk@gmail.com'),
          ),
          ListTile(
            leading: Icon(Icons.refresh_outlined),
            title: Text('Referesh Database'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Container(
                      child: AlertDialog(
                        title: Text('Referesh Database'),
                        content:
                            Text('Do you really want to Referesh Database'),
                        actions: [
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Show loading indicator
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    // prevents dismissing the dialog when tapped outside
                                    builder: (BuildContext context) {
                                      return WillPopScope(
                                        // This ensures that the dialog can't be closed by pressing the back button
                                        onWillPop: () async => false,
                                        child: AlertDialog(
                                          content:
                                              CircularProgressIndicator(), // Loading indicator
                                        ),
                                      );
                                    },
                                  );

                                  try {
                                    // Load data
                                    await _getRecords();
                                    await getRecords();
                                    await _loadData();
                                    await loadData();
                                  } catch (error) {
                                    // Handle error
                                  } finally {
                                    // Hide loading indicator
                                    Navigator.popUntil(
                                        context,
                                        (route) =>
                                            route.isFirst); // Close all dialogs
                                  }

                                  // Trigger data refresh for CustomerList screen
                                  // Refresh the saved data
                                },
                                child: Text('Confirm'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            },
          ),
          Divider(
            thickness: 2,
          ),
          ListTile(
            leading: Image.asset('assets/icons/about.png', scale: 8),
            title: Text(
              'About Us',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[700],
              ),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const About()));
            },
          ),
          Divider(
            thickness: 5,
          ),
          ListTile(
            leading: Icon(CupertinoIcons.power),
            title: Text('Logout'),
            onTap: () {
              // Set the isLoggedIn flag to false
              logindata.setBool('isLoggedIn', false);

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
