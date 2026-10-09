import 'dart:convert';
import '/services/services.dart';
import 'package:http/http.dart' as http;

class DashboardService extends HttpConfig {
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

  Future getDashboard() async {
    String? schoolId = await LocalDBConfig().getUserId();

    try {
      var data = {
        "get_section_school_id": schoolId,
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
