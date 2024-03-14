import 'package:flutter/material.dart';

class MySearchDelegate extends SearchDelegate<String> {
  final List<dynamic> userdata;

  MySearchDelegate(this.userdata);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchResults = userdata
        .where((user) =>
            user['cid']
                .toString()
                .toLowerCase()
                .startsWith(query.toLowerCase()) ||
            user['cname']
                .toString()
                .toLowerCase()
                .startsWith(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text(searchResults[index]['cid'].toString()),
          title: Text(searchResults[index]['cname'].toString()),
          subtitle: Text(searchResults[index]['address1']),

          onTap: () {
            // Close the search delegate
            close(context, searchResults[index]['cid'].toString());
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  final List<dynamic> originalProducts;

  ProductSearchDelegate(this.originalProducts);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchResults = originalProducts
        .where((product) =>
            product['cid']
                .toString()
                .toLowerCase()
                .startsWith(query.toLowerCase()) ||
            product['cname']
                .toString()
                .toLowerCase()
                .startsWith(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text(searchResults[index]['cid'].toString()),
          title: Text(searchResults[index]['cname'].toString()),
          onTap: () {
            close(context, searchResults[index]['cid'].toString());
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
