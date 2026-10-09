import 'dart:convert';
import 'package:http/http.dart' as http;
import '/services/services.dart';

class AuthService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data");
    return url;
  }

  getHeader() async {
    var data = await super.getHeaders();
    var url = data;
    return url;
  }

  Future checkLogin(
      {required String username, required String password}) async {
    try {
      var data = {
        "username": username,
        "password": password,
      };
      var url = await getDomain();
      var headers = await getHeader();
      var message =
          await http.post(url, headers: headers, body: json.encode(data));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
