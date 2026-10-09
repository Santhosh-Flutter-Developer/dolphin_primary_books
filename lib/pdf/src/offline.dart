import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:responsive_grid/responsive_grid.dart';

import '/pdf/pdf.dart';

class Offline extends StatefulWidget {
  const Offline({super.key});

  @override
  State<Offline> createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  late Future _future;
  List<String> bookList = [];

  @override
  void initState() {
    _future = _init();
    super.initState();
  }

  Future<void> _init() async {
    var temp = await getTemporaryDirectory();
    var directory = Directory("${temp.path}/dolphin/");
    for (var i in directory.listSync()) {
      bookList.add(i.path);
    }

    Set<String> pdfBaseNames = bookList
        .where((e) => e.endsWith('.pdf'))
        .map((e) => e.replaceAll('.pdf', ''))
        .toSet();

    Set<String> jpgBaseNames = bookList
        .where((e) => e.endsWith('.jpg'))
        .map((e) => e.replaceAll('.jpg', ''))
        .toSet();

    Set<String> commonBaseNames = pdfBaseNames.intersection(jpgBaseNames);

    List<String> filteredList = bookList.where((file) {
      final base = file.replaceAll('.pdf', '').replaceAll('.jpg', '');
      return commonBaseNames.contains(base);
    }).toList();

    bookList.clear();
    bookList.addAll(filteredList);

    bookList.removeWhere((element) => element.contains("pdf"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Downloaded Books PDF"), actions: const []),
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
                children: List.generate(bookList.length, (index) {
                  var book = bookList[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PdfViewerPageOffline(
                            path: book.replaceAll('jpg', 'pdf')),
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
                          child: Image.file(
                            File(book),
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
                                  child: Text(
                                    path.basenameWithoutExtension(book),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_rounded),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Delete Book"),
                                          content: const Text(
                                              "Are you sure you want to delete this book?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                File(book).delete();
                                                setState(() {
                                                  bookList.remove(book);
                                                });
                                                if (File(
                                                        "${path.basenameWithoutExtension(book)}.pdf")
                                                    .existsSync()) {
                                                  File("${path.basenameWithoutExtension(book)}.pdf")
                                                      .deleteSync();
                                                }
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        );
                                      },
                                      barrierDismissible: false,
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
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
