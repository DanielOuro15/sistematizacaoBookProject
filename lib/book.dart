class Book {
  final String title;
  final String author;
  final String publishedDate;
  bool isRead; // Indica se o livro foi lido ou não

  Book({
    required this.title,
    required this.author,
    required this.publishedDate,
    this.isRead = false, // Valor padrão é falso (não lido)
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];
    String date = volumeInfo['publishedDate'] ?? 'Data desconhecida';

    // Converte a data para o formato dd-mm-yyyy
    if (date.contains('-')) {
      List<String> dateParts = date.split('-');
      if (dateParts.length == 3) {
        date = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
      }
    }

    return Book(
      title: volumeInfo['title'] ?? 'Título desconhecido',
      author: (volumeInfo['authors'] != null && volumeInfo['authors'].isNotEmpty)
          ? volumeInfo['authors'][0]
          : 'Autor desconhecido',
      publishedDate: date,
    );
  }
}
