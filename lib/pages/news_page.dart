import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import 'article_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService _newsService = NewsService();

  late Future<List<Article>> _newsFuture;

  final TextEditingController _searchController =
      TextEditingController();

  final TextEditingController _localFilterController =
      TextEditingController();

  String _selectedCategory = 'general';
  String _localKeyword = '';

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);

  final List<Map<String, String>> _categories = [
    {'name': 'Umum', 'value': 'general'},
    {'name': 'Bisnis', 'value': 'business'},
    {'name': 'Hiburan', 'value': 'entertainment'},
    {'name': 'Kesehatan', 'value': 'health'},
    {'name': 'Sains', 'value': 'science'},
    {'name': 'Olahraga', 'value': 'sports'},
    {'name': 'Teknologi', 'value': 'technology'},
  ];

  @override
  void initState() {
    super.initState();

    _newsFuture = _newsService.fetchTopHeadlines();
  }

  // Memilih kategori berita
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();

      _newsFuture = _newsService.fetchTopHeadlines(
        category: category,
      );
    });
  }

  // Mencari berita dari API
  void _searchNews() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _selectCategory(_selectedCategory);
      return;
    }

    setState(() {
      _newsFuture = _newsService.searchArticles(
        query: query,
      );
    });
  }

  // Mengulang request berita jika terjadi error
  void _retryFetch() {
    setState(() {
      final query = _searchController.text.trim();

      if (query.isNotEmpty) {
        _newsFuture = _newsService.searchArticles(
          query: query,
        );
      } else {
        _newsFuture = _newsService.fetchTopHeadlines(
          category: _selectedCategory,
        );
      }
    });
  }

  // Filter berita berdasarkan judul
  List<Article> filterByTitle(
    List<Article> articles,
    String keyword,
  ) {
    if (keyword.isEmpty) {
      return articles;
    }

    return articles.where((article) {
      return article.title
          .toLowerCase()
          .contains(keyword.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _localFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Newsly',
          style: TextStyle(
            color: primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER DAN SEARCH BAR
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover the World',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Temukan berita terbaru hari ini.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 18),

                // SEARCH BERITA API
                TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _searchNews(),
                  decoration: InputDecoration(
                    hintText: 'Cari berita...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: primaryColor,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _searchNews,
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: primaryColor,
                      ),
                    ),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // KATEGORI BERITA
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: const Text(
              'Kategori',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];

                final isSelected =
                    _selectedCategory == category['value'];

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category['name']!),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      _selectCategory(category['value']!);
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // FILTER JUDUL BERITA
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TextField(
              controller: _localFilterController,
              onChanged: (value) {
                setState(() {
                  _localKeyword = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Filter judul berita...',
                prefixIcon: const Icon(Icons.filter_list),
                suffixIcon: IconButton(
                  onPressed: () {
                    _localFilterController.clear();

                    setState(() {
                      _localKeyword = '';
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // DAFTAR BERITA
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _newsFuture,
              builder: (context, snapshot) {

                // LOADING
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }

                // ERROR
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 55,
                            color: Colors.grey,
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Oops! Berita gagal dimuat.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Periksa koneksi internet kamu, lalu coba lagi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 18),

                          ElevatedButton.icon(
                            onPressed: _retryFetch,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // MENGAMBIL DATA
                final articles = snapshot.data ?? [];

                // DATA KOSONG
                if (articles.isEmpty) {
                  return const Center(
                    child: Text(
                      'Berita tidak ditemukan.',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                      ),
                    ),
                  );
                }

                // FILTER JUDUL
                final filteredArticles = filterByTitle(
                  articles,
                  _localKeyword,
                );

                if (filteredArticles.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada berita yang cocok.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                // LIST BERITA
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),

                      // NAVIGASI KE DETAIL BERITA
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ArticleDetailPage(
                                article: article,
                              );
                            },
                          ),
                        );
                      },

                      child: Card(
                        margin: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // GAMBAR BERITA
                            if (article.imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  article.imageUrl,
                                  width: double.infinity,
                                  height: 190,
                                  fit: BoxFit.cover,
                                  errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return Container(
                                      width: double.infinity,
                                      height: 190,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 45,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),

                            // INFORMASI BERITA
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // SUMBER BERITA
                                  Text(
                                    article.sourceName,
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // JUDUL BERITA
                                  Text(
                                    article.title,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // DESKRIPSI
                                  Text(
                                    article.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // FOOTER KARTU
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Latest update',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 13,
                                        color: primaryColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}