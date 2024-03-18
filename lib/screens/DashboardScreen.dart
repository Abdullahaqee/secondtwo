import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../customerList.dart';
import 'dashboard_screens/about.dart';
import 'dashboard_screens/navbar.dart';
import 'dashboard_screens/newOrder.dart';
import 'dashboard_screens/orderList.dart';
import 'dashboard_screens/productList.dart';
import 'dashboard_screens/todaySale.dart';

class DashboardScreen extends StatefulWidget {
  final String cname;

  const DashboardScreen({required this.cname});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  // void loadData() async {
  //   logindata = await SharedPreferences.getInstance();
  //    var savedCName = logindata.getString('cname') ?? '';
  //   if (savedCName.isEmpty) {
  //     savedCName = widget.cname;
  //     logindata.setString('cname', savedCName);
  //   }
  // }
  void loadData() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    String iName = _preferences.getString('jcname') ?? '';
    if (iName.isEmpty) {
      iName = widget.cname;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('DASHBOARD', style: TextStyle(color: Colors.blueGrey[700])),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Icon(CupertinoIcons.person, color: Colors.blueGrey[700]),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 2, left: 10, right: 10),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blueGrey[50],
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.white,
                        spreadRadius: 1,
                        offset: Offset(4, 4),
                      ),
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.blueGrey.shade100,
                        spreadRadius: 1,
                        offset: Offset(-4, -4),
                      ),
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cname,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.blueGrey[700]),
                    ),
                    // Text(
                    //   'Distribution Full Address',
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.w300,
                    //       fontSize: 14,
                    //       color: Colors.blueGrey[700]),
                    // ),
                  ],
                ),
              ),
              // Grid View Containers
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.90,
                    children: [
                      // New Order Widget

                      CategoryCard(
                          title: "New Order",
                          pngSrc: 'assets/neworder.png',
                          press: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NewOrder(
                                          customerName: '',
                                          orderData: [],
                                          recordId: 0,
                                          Code: '',
                                          isedit: false,
                                        )));
                          }),

                      CategoryCard(
                        title: "Order List",
                        pngSrc: 'assets/orderlist.png',
                        press: () async {
                          // Assuming you have a SaleData instance named 'saleData' to pass
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SaveData(),
                            ),
                          );
                        },
                      ),

                      CategoryCard(
                          title: "Customers List",
                          pngSrc: 'assets/customerlist.png',
                          press: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CustomerList()));
                          }),
                      CategoryCard(
                          title: "Products List",
                          pngSrc: 'assets/productlist.png',
                          press: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const productList()));
                          }),

                      CategoryCard(
                          title: "Today Sale",
                          pngSrc: 'assets/todaysale.png',
                          press: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TodaySale()));
                          }),

                      CategoryCard(
                          title: "About Us",
                          pngSrc: 'assets/about.png',
                          press: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => About()));
                          }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String pngSrc;
  final String title;
  final VoidCallback press;

  const CategoryCard({
    super.key,
    required this.pngSrc,
    required this.title,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.blueGrey[50],
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: Colors.white,
              spreadRadius: 1,
              offset: Offset(4, 4),
            ),
            BoxShadow(
              blurRadius: 3,
              color: Colors.blueGrey.shade100,
              spreadRadius: 1,
              offset: Offset(-4, -4),
            ),
          ]),
      child: InkWell(
        onTap: press,
        child: Column(children: [
          const Spacer(),
          Image.asset(
            pngSrc,
            scale: 4.5,
          ),
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.blueGrey[700],
            ),
          ),
          const Spacer(),
        ]),
      ),
    );
  }
}
