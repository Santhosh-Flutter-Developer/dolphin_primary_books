import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '/services/services.dart';
import '/screens/screens.dart';
import '/utils/utils.dart';

class FavoriteList extends StatefulWidget {
  final String heading;
  final List<Map<String, String>> items;
  const FavoriteList({super.key, required this.items, required this.heading});

  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  bool isTv = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    isTv = await isAndroidTV();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: !isTv
          ? ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlay(
                              url: widget.items[index]["video_url"]!,
                              heading: widget.items[index]["title"]!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Expanded(flex: 1, child: Icon(Iconsax.video)),
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.items[index]["title"]!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: blueDarkColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    "Page No. ${widget.items[index]["page_no"]}",
                                    style: TextStyle(
                                        color: blueDarkColor, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: FutureBuilder<bool>(
                                future: LocalDBConfig().checkFavorite(
                                    "${widget.heading},${widget.items[index]["title"]},${widget.items[index]["page_no"]},${widget.items[index]["video_url"]}"),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Icon(Icons.error);
                                  } else {
                                    bool isFavorite = snapshot.data ?? false;
                                    return IconButton(
                                      onPressed: () async {
                                        if (isFavorite) {
                                          await LocalDBConfig().removeFavorite(
                                              "${widget.heading},${widget.items[index]["title"]},${widget.items[index]["page_no"]},${widget.items[index]["video_url"]}");
                                          showSnackbar(context,
                                              content:
                                                  "Video removed from favorites",
                                              isSuccess: true);
                                        } else {
                                          await LocalDBConfig().setFavorite(
                                              videoDetails:
                                                  "${widget.heading},${widget.items[index]["title"]},${widget.items[index]["page_no"]},${widget.items[index]["video_url"]}");
                                          showSnackbar(context,
                                              content:
                                                  "Video added to favorites",
                                              isSuccess: true);
                                        }
                                        setState(() {});
                                      },
                                      icon: isFavorite
                                          ? Icon(
                                              Icons.favorite,
                                              color: redColor,
                                            )
                                          : const Icon(
                                              Icons.favorite_border,
                                            ),
                                    );
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                );
              },
            )
          : Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ResponsiveGridList(
                shrinkWrap: true,
                desiredItemWidth: isTab(context) ? 200 : 150,
                minSpacing: 10,
                children: widget.items
                    .map(
                      (video) => VideosCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TvVideoPlay(
                                  videoUrl: video["video_url"] ?? '',
                                  fav:
                                      "${widget.heading},${video["title"]},${video["page_no"]},${video["video_url"]}"),
                            ),
                          );
                        },
                        title: video["title"] ?? '',
                        subtitle: video["page_no"] ?? '',
                        favorite: Expanded(
                          flex: 1,
                          child: FutureBuilder<bool>(
                            future: LocalDBConfig().checkFavorite(
                                "${widget.heading},${video["title"]},${video["page_no"]},${video["video_url"]}"),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return const Icon(Icons.error);
                              } else {
                                bool isFavorite = snapshot.data ?? false;
                                return IconButton(
                                  onPressed: () async {
                                    if (isFavorite) {
                                      await LocalDBConfig().removeFavorite(
                                          "${widget.heading},${video["title"]},${video["page_no"]},${video["video_url"]}");
                                      showSnackbar(context,
                                          content:
                                              "Video removed from favorites",
                                          isSuccess: true);
                                    } else {
                                      await LocalDBConfig().setFavorite(
                                          videoDetails:
                                              "${widget.heading},${video["title"]},${video["page_no"]},${video["video_url"]}");
                                      showSnackbar(context,
                                          content: "Video added to favorites",
                                          isSuccess: true);
                                    }
                                    setState(() {});
                                  },
                                  icon: isFavorite
                                      ? Icon(
                                          Icons.favorite,
                                          color: redColor,
                                        )
                                      : const Icon(
                                          Icons.favorite_border,
                                        ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }

  AppBar appbar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: whiteColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: whiteColor),
      backgroundColor: redColor,
      title: Text(
        widget.heading,
        style: TextStyle(color: whiteColor),
      ),
    );
  }
}
