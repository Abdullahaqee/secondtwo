import 'package:http/http.dart' as http;

class ApiHandler {
  // static const loginUrl = 'http://192.168.18.9/ERP/login.php'; // Login URL
  static const baseUrl =
      "http://isofttouch.com/eorder/view_data.php"; // Base URL for other APIs
  // static const priceUrl = 'http://isofttouch.com/eorder/product.php';

  // static Future<Map<String, dynamic>> login(String userId, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(loginUrl),
  //       body: {
  //         'userid': userId,
  //         'password': password,
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return {'success': true, 'data': response.body};
  //     } else {
  //       return {'success': false, 'error': 'Failed to log in'};
  //     }
  //   } catch (e) {
  //     return {'success': false, 'error': 'Exception: $e'};
  //   }
  // }

  static Future<Map<String, dynamic>> fetchData(String apiPath) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$apiPath'));

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {'success': false, 'error': 'Failed to fetch data'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

// static Future<void> updateData() async {
//   try {
//     final response = await http.get(Uri.parse('$priceUrl/index.php'));
//
//     if (response.statusCode == 200) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString('apiData', response.body);
//     } else {
//       throw Exception('Failed to load Data');
//     }
//   } catch (e) {
//     print('Error updating data: $e');
//   }
// }
//
// static Future<String> getStoredData() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? apiData = prefs.getString('apiData');
//   return apiData ?? 'No Data';
// }
//
// static Future<List<Map<String, dynamic>>> fetchPrice() async {
//   try {
//     final response = await http.get(Uri.parse('$priceUrl/customer_endpoint'));
//
//     if (response.statusCode == 200) {
//       List<dynamic> customerData = jsonDecode(response.body);
//       List<Map<String, dynamic>> picture =
//           customerData.cast<Map<String, dynamic>>().toList();
//       return picture;
//     } else {
//       throw Exception('Failed to fetch customer data');
//     }
//   } catch (e) {
//     throw Exception('Exception: $e');
//   }
// }
//
// static Future<List<Map<String, dynamic>>> fetchcustomer() async {
//   try {
//     final response = await http.get(Uri.parse('$baseUrl/customer_endpoint'));
//
//     if (response.statusCode == 200) {
//       List<dynamic> customerData = jsonDecode(response.body);
//       List<Map<String, dynamic>> customers =
//           customerData.cast<Map<String, dynamic>>().toList();
//       return customers;
//     } else {
//       throw Exception('Failed to fetch customer data');
//     }
//   } catch (e) {
//     throw Exception('Exception: $e');
//   }
// }
}
