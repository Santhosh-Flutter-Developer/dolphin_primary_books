import '/constants/constants.dart';

class HttpConfig {
  Future<String?> getdomain() async {
    String result = "$rootUrl/include/api/videotutorial_api.php";
    return result;
  }

  Future<Map<String, String>?> getHeaders() async {
    Map<String, String> result = {
      "Authorization":
          "Bearer giDTpOjvOZCV9YHTyypVBzGUXhcFZQTrBlADIoFkwVvTF8pedMH7Lb8B7MjcSMSF",
      "Api-Key":
          "mZOs7oTx8yaa3QuEBvVXotO1U6rp4gyWSvG2xLK9cfzwfZjOrDu0Hu3WttgMMGr6",
      "Auth-Token":
          "oA0YOI1yjZQaercg35uDom1KvTFWKRR6rKqhtIa5ajHImxs6q3wrmJFhVMZSRlMd"
    };
    return result;
  }
}
