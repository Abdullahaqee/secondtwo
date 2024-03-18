import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerList extends StatefulWidget {
  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  List<dynamic> secondScreenData = [];
  List<dynamic> filteredUserData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDataForSecondScreen();
  }

  Future<void> _loadDataForSecondScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('userdata') ?? '[]';
    setState(() {
      secondScreenData = jsonDecode(jsonData);
      filteredUserData = List.from(secondScreenData);
    });
  }

  void filterData(String id) {
    setState(() {
      filteredUserData = secondScreenData
          .where((user) =>
              user['cid'].toString().startsWith(id.toLowerCase()) ||
              user['cname']
                  .toString()
                  .toLowerCase()
                  .startsWith(id.toLowerCase()))
          .toList(); // Convert the set to a list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAFAFF),
      appBar: AppBar(
        title: Text("Customer List"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterData(value);
              },
              decoration: InputDecoration(
                labelText: 'Search by ID',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUserData.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 40,
                  height: 60,
                  child: ListTile(
                    leading: Text(filteredUserData[index]['cid']),
                    title: Text(filteredUserData[index]['cname']),
                    subtitle: Text(filteredUserData[index]['address1']),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
