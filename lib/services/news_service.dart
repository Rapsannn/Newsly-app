import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  
  final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

  // Mengambil berita berdasarkan kategori

  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) async {
    final uri = Uri.https('newsapi.org', '/v2/top-headlines', {
      'country': 'us',
      'category': category,
      'pageSize': '20',
    });

    return _getArticles(uri);
  }

  // Mencari berita berdasarkan kata kunci
  Future<List<Article>> searchArticles({required String query}) async {
    final uri = Uri.https('newsapi.org', '/v2/everything', {
      'q': query,
      'pageSize': '20',
      'sortBy': 'publishedAt',
      'language': 'en',
    });

    return _getArticles(uri);
  }

  Future<List<Article>> _getArticles(Uri uri) async {
    if (_apiKey.isEmpty) {
      throw Exception('NEWS_API_KEY belum diatur. Periksa file .env.');
    }

    final response = await http.get(uri, headers: {'X-Api-Key': _apiKey});

    if (response.statusCode != 200) {
      throw Exception(
        'Permintaan berita gagal. Kode HTTP: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> jsonData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (jsonData['status'] != 'ok') {
      throw Exception(jsonData['message'] ?? 'NewsAPI mengalami kesalahan.');
    }

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil berita. HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] != 'ok') {
      throw Exception(data['message'] ?? 'Terjadi kesalahan pada API');
    }

    final List<dynamic> articlesJson = data['articles'];

    return articlesJson
        .map((json) => Article.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
