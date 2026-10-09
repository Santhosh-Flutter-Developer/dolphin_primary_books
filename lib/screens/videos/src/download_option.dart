import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/utils.dart';
import '/model/model.dart';
import '/services/services.dart';

class DownloadOption extends StatefulWidget {
  final String heading;
  const DownloadOption({super.key, required this.heading});

  @override
  State<DownloadOption> createState() => _DownloadOptionState();
}

class _DownloadOptionState extends State<DownloadOption> {
  bool _selectAllSelected = false;

  final List<VideoModel> _selectedVideos = [];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Select the videos you want to download",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_selectedVideos.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context, _selectedVideos);
                      },
                      icon: Icon(
                        Iconsax.arrow_down,
                        color: redColor,
                        size: 20,
                      ),
                      label: Text(
                        "Download",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: redColor,
                        ),
                      ),
                    )
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Select all",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Checkbox(
                        value: _selectAllSelected,
                        onChanged: (value) {
                          setState(() {
                            _selectAllSelected = value!;
                            if (_selectAllSelected) {
                              _selectedVideos.clear();
                              _selectedVideos.addAll(videoList);
                            } else {
                              _selectedVideos.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: videoHandler,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return futureWaitingLoading();
                  } else if (snapshot.hasError) {
                    if (snapshot.error == 'No Network') {
                      return futureNetworkError();
                    } else {
                      return futureDisplayError(
                          content: snapshot.error.toString());
                    }
                  } else {
                    return ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: videoList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Image.network(
                            videoList[index].thumbnailUrl,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error);
                            },
                          ),
                          title: Text(videoList[index].title),
                          subtitle: Text(
                              "${videoList[index].description != 'NULL' ? videoList[index].description : ''} ${videoList[index].pageNo != 'NULL' ? videoList[index].pageNo : ''}"),
                          trailing: Checkbox(
                            value: _selectedVideos.contains(videoList[index]),
                            onChanged: (value) {
                              if (value == true) {
                                _selectedVideos.add(videoList[index]);
                              } else {
                                _selectedVideos.remove(videoList[index]);
                              }

                              if (_selectedVideos.length == videoList.length) {
                                _selectAllSelected = true;
                              } else {
                                _selectAllSelected = false;
                              }

                              setState(() {});
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    videoHandler = getVideos();
    super.initState();
  }

  Future? videoHandler;
  List<VideoModel> videoList = [];

  Future getVideos() async {
    setState(() {
      videoList.clear();
    });
    try {
      await DashboardService().getDashboard().then((value) {
        if (value != null && value.isNotEmpty) {
          var data = value["head"]["msg"];

          for (var item in data) {
            if (item["heading"] == widget.heading) {
              var videoListFromItem = item["video_list"] as List;

              setState(() {
                videoList.clear();
              });

              for (var videoItem in videoListFromItem) {
                VideoModel videoModel = VideoModel(
                  title: videoItem["title"].toString(),
                  videoUrl: videoItem["video_link"].toString(),
                  thumbnailUrl: videoItem["thumbnail"].toString(),
                  description: videoItem["description"].toString(),
                  pageNo: videoItem["page_no"].toString(),
                );
                setState(() {
                  videoList.add(videoModel);
                });
              }
              break;
            }
          }
        }
      });
    } catch (e) {
      showSnackbar(context, content: e.toString(), isSuccess: false);
    }
  }
}
