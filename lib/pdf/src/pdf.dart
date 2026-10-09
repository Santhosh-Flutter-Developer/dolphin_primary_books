// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/screens.dart';
import '/pdf/pdf.dart';

class Pdf extends StatefulWidget {
  const Pdf({super.key});

  @override
  State<Pdf> createState() => _PdfState();
}

class _PdfState extends State<Pdf> {
  late Future _future;
  List<BookModel> bookModelList = [];

  @override
  void initState() {
    _future = _init();
    super.initState();
  }

  Future<void> _init() async {
    try {
      bookModelList.clear();
      List<Map<String, dynamic>> booksList = [];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var book = prefs.getStringList('books');

            for (var i in (book ?? [])) {
        if (i is String && i != '[]') {
          booksList.add(json.decode(i) as Map<String, dynamic>);
        }
      }
      bookModelList = (booksList).map((e) => BookModel.fromMap(e)).toList();
      bookModelList.removeWhere(
        (element) =>
            !booksList.any((book) => element.pdfId.contains(book['pdf_id'])),
      );

      bookModelList.sort((a, b) => a.categoryName.compareTo(b.categoryName));
    } on SocketException catch (e) {
      debugPrint(e.toString());
      throw "No Network";
    } catch (e) {
      showSnackbar(context, content: e.toString(), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Books PDF"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const Offline(),
                ),
              );
            },
            tooltip: "Downloads",
            icon: const Icon(Icons.file_download_outlined),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.progressiveDots(
                  color: Theme.of(context).primaryColor, size: 40),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ResponsiveGridList(
                shrinkWrap: true,
                desiredItemWidth: 150,
                minSpacing: 10,
                children: List.generate(bookModelList.length, (index) {
                  var book = bookModelList[index];
                  return Tooltip(
                    message: book.categoryName,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => PdfViewerPage(book: book),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            width: 200,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: Image.asset(
                              "assets/images/book-thumnail.jpg",
                              gaplessPlayback: true,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.categoryName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // Text(
                                        //   "Pages : ${book.totalPages}",
                                        //   style: Theme.of(context)
                                        //       .textTheme
                                        //       .bodySmall!
                                        //       .copyWith(
                                        //         color: Colors.grey,
                                        //         fontWeight: FontWeight.bold,
                                        //       ),
                                        //   overflow: TextOverflow.ellipsis,
                                        // ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.file_download_outlined),
                                    tooltip: "Download",
                                    onPressed: () async {
                                      await Download.downloadFromUrl(
                                          context,
                                          "https://drive.google.com/uc?export=download&id=${book.pdfId}",
                                          "${book.categoryName}.pdf");
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }
        },
      ),
    );
  }
}
