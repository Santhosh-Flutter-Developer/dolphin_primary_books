class BookModel {
  String pdfId;
  String categoryName;
  String pdfName;
  BookModel({
    required this.pdfId,
    required this.categoryName,
    required this.pdfName,
  });

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      pdfId: map['pdf_id'] as String,
      categoryName: map['category_name'] as String,
      pdfName: map['pdf_name'] as String,
    );
  }
}
