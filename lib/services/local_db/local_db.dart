import 'package:shared_preferences/shared_preferences.dart';

class LocalDBConfig {
  Future<SharedPreferences> connectLocalDb() async {
    return await SharedPreferences.getInstance();
  }

  Future<bool> checkLogin() async {
    var connection = await connectLocalDb();
    bool? result = connection.getBool('login');
    if (result == null) {
      return false;
    } else {
      return result;
    }
  }

  Future newUserLogin(
      {required String userId,
      required String userName,
      required String userLoginId,
      required String userType,
      required List<String> books}) async {
    var connection = await connectLocalDb();
    connection.setString('user_id', userId);
    connection.setString('user_name', userName);
    connection.setString('user_login_id', userLoginId);
    connection.setString('user_type', userType);
    connection.setStringList('books', books);
    connection.setBool('login', true);
    connection.setStringList('favorites', []);
  }

  Future<String?> getUserId() async {
    var connection = await connectLocalDb();
    return connection.getString('user_id');
  }

  Future<String?> getUsername() async {
    var connection = await connectLocalDb();
    return connection.getString('user_name');
  }

  Future<String?> getUserType() async {
    var connection = await connectLocalDb();
    return connection.getString('user_type');
  }

  Future setFavorite({required String videoDetails}) async {
    var connection = await connectLocalDb();
    List<String>? favorites = connection.getStringList('favorites') ?? [];
    favorites.add(videoDetails);
    return connection.setStringList('favorites', favorites);
  }

  Future<bool> checkFavorite(String videoDetails) async {
    var db = await LocalDBConfig().connectLocalDb();
    List<String>? favorites = db.getStringList('favorites') ?? [];
    return favorites.contains(videoDetails);
  }

  Future<bool> removeFavorite(String videoDetails) async {
    var db = await LocalDBConfig().connectLocalDb();
    List<String>? favorites = db.getStringList('favorites') ?? [];

    if (favorites.contains(videoDetails)) {
      favorites.remove(videoDetails);
      await db.setStringList('favorites', favorites);
      return true;
    }
    return false;
  }

  Future getFavorites() async {
    var connection = await connectLocalDb();
    return connection.getStringList('favorites');
  }

  Future<bool> logout() async {
    var connection = await connectLocalDb();
    return connection.clear();
  }
}
