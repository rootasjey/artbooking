class ProcessedBook {
  final String bookId;
  final bool success;

  ProcessedBook({
    this.bookId = '',
    this.success = false,
  });

  factory ProcessedBook.fromJSON(Map<String, dynamic> data) {
    return ProcessedBook(
      bookId: data['bookId'] ?? '',
      success: data['success'] ?? false,
    );
  }
}
