// ignore_for_file: public_member_api_docs, sort_constructors_first
class VideoModel {
  String title, videoUrl, thumbnailUrl, description, pageNo;
  VideoModel({
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    required this.pageNo,
  });

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["title"] = title;
    mapping["video_url"] = videoUrl;
    mapping["thumbnail_url"] = thumbnailUrl;
    mapping["description"] = description;
    mapping["page_no"] = pageNo;
    return mapping;
  }
}
