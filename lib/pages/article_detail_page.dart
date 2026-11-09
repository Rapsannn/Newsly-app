import 'package:flutter/material.dart'; 
import '../models/article.dart'; 
class ArticleDetailPage extends StatelessWidget { 
final Article article; 
  const ArticleDetailPage({ 
    super.key, 
    required this.article, 
  }); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Detail Berita'), 
      ), 
      body: SingleChildScrollView( 
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [ 
            if (article.imageUrl.isNotEmpty) 
              Image.network( 
                article.imageUrl, 
                width: double.infinity, 
                height: 240, 
                fit: BoxFit.cover, 
                errorBuilder: (context, error, stackTrace) { 
                  return const SizedBox( 
                    height: 200, 
                    child: Center( 
                      child: Icon( 
                        Icons.broken_image, 
                        size: 60, 
                      ), 
                    ), 
                  ); 
                }, 
              ), 
            Padding( 
              padding: const EdgeInsets.all(16), 
              child: Column( 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [ 
                  Text( 
                    article.sourceName, 
                    style: const TextStyle( 
                      color: Colors.blue, 
                      fontWeight: FontWeight.bold, 
                    ), 
                  ), 
                  const SizedBox(height: 8), 
                  Text( 
                    article.title, 
                    style: const TextStyle( 
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                    ), 
                  ), 
                  const SizedBox(height: 12), 
                  Text( 
                    'Tanggal publikasi: ${article.publishedAt}', 
                    style: const TextStyle( 
                      color: Colors.grey, 
                      fontSize: 12, 
                    ), 
                  ), 
                  const SizedBox(height: 16), 
                  Text( 
                    article.description.isEmpty 
                        ? 'Deskripsi berita tidak tersedia.' 
                        : article.description, 
                    style: const TextStyle( 
                      fontSize: 16, 
                      height: 1.5, 
                    ), 
                  ), 
                ], 
              ), 
            ),
          ], 
        ), 
      ),
    ); 
  } 
}