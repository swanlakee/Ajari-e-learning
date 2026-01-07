import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionService {
  final String baseUrl =
      'http://localhost:8000/api'; // Or http://10.0.2.2:8000/api for Android Emulator

  Future<Map<String, dynamic>> createInvoice(
    String token,
    double amount,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/topup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'amount': amount}),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> checkStatus(
    String token,
    String externalId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$externalId/check'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
