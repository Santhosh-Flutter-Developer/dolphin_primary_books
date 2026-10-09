class DashboardModel {
  String? heading;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["heading"] = heading;
    return mapping;
  }
}
