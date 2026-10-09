class DownloadsModel {
  final String path;
  final String pageNo; // Ensure this is an int
  final String title;

  DownloadsModel({
    required this.path,
    required this.pageNo,
    required this.title,
  });

  factory DownloadsModel.fromJson(Map<String, dynamic> json) {
    return DownloadsModel(
      path: json['path'].toString(),
      pageNo: json['page_no'].toString(), // Ensure it's a string for display
      title: json['title'].toString(),
    );
  }
}
