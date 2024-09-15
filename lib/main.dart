import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'book.dart'; // O arquivo do modelo Book que já criamos

void main() {
  runApp(PesquisaLivroApp());
}

class PesquisaLivroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BookSearchScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class BookSearchScreen extends StatefulWidget {
  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  List<Book> _books = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();

  Future<void> _searchBooks() async {
    final query = _searchController.text;

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, digite o nome de um livro!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = 'https://www.googleapis.com/books/v1/volumes?q=$query';
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Book> books =
          (data['items'] as List).map((item) => Book.fromJson(item)).toList();

      setState(() {
        _books = books;
        _isLoading = false;
      });
    } else {
      throw Exception('Falha ao carregar livros');
    }
  }

  void _toggleReadStatus(Book book) {
    setState(() {
      book.isRead = !book.isRead;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Livros'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.lightBlueAccent,
              Colors.greenAccent,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Pesquisar por livros',
                  hintText: 'Digite o nome do livro',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _searchBooks,
                child: Text('Buscar'),
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          return ListTile(
                            title: Text(book.title),
                            subtitle: Text(
                                'Autor: ${book.author}\nAno: ${book.publishedDate}'),
                            trailing: Checkbox(
                              value: book.isRead,
                              onChanged: (value) {
                                _toggleReadStatus(book);
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
