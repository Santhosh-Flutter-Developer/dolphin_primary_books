import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '/pdf/pdf.dart';

class PdfViewerPage extends StatefulWidget {
  final BookModel book;
  const PdfViewerPage({super.key, required this.book});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfViewerController _pdfViewerController;
  late PdfScrollDirection _scrollDirection;
  int _totalPages = 0;
  // ignore: unused_field
  int _currentPage = 0;
  final TextEditingController _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _scrollDirection = PdfScrollDirection.vertical;
  }

  void _goToPage(int page) {
    if (page > 0 && page <= _totalPages) {
      _pdfViewerController.jumpToPage(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: "Previous Page",
            onPressed: () {
              _pdfViewerController.previousPage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: "Next Page",
            onPressed: () {
              _pdfViewerController.nextPage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert),
            tooltip: "Toggle Scroll Direction",
            onPressed: () {
              setState(() {
                _scrollDirection =
                    _scrollDirection == PdfScrollDirection.vertical
                        ? PdfScrollDirection.horizontal
                        : PdfScrollDirection.vertical;
              });
            },
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Page",
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onSubmitted: (value) {
                final page = int.tryParse(value);
                if (page != null) _goToPage(page);
              },
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SfPdfViewer.network(
        "https://drive.google.com/uc?export=download&id=${widget.book.pdfId}",
        controller: _pdfViewerController,
        scrollDirection: _scrollDirection,
        pageLayoutMode: PdfPageLayoutMode.single,
        onDocumentLoaded: (details) {
          setState(() {
            _totalPages = details.document.pages.count;
          });
        },
        onPageChanged: (details) {
          setState(() {
            _currentPage = details.newPageNumber;
          });
        },
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        pageSpacing: 4,
        onDocumentLoadFailed: (details) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Failed to Load PDF"),
              content: Text(details.description),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
