import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(NewsClientApp());
}

class NewsClientApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewsListPage(),
    );
  }
}

class NewsListPage extends StatefulWidget {
  @override
  _NewsListPageState createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  List<dynamic> newsList = [];
  List<dynamic> offlineNews = [];
  bool isLoading = true;
  String selectedCategory = 'TechCrunch';
  final Map<String, String> categories = {
    'TechCrunch': 'https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=3357dd7923854713b0de942fb22211a1',
    'WSJ': 'https://newsapi.org/v2/everything?domains=wsj.com&apiKey=3357dd7923854713b0de942fb22211a1',
    'Business': 'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=3357dd7923854713b0de942fb22211a1',
    'Tesla': 'https://newsapi.org/v2/everything?q=tesla&from=2024-11-19&sortBy=publishedAt&apiKey=3357dd7923854713b0de942fb22211a1'
  };

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final url = categories[selectedCategory] ?? categories.values.first;
    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          newsList = data['articles'];
          offlineNews = newsList;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching news: $e');
    }
  }

  void sortNewsByDate() {
    setState(() {
      newsList.sort((a, b) => DateTime.parse(b['publishedAt']).compareTo(DateTime.parse(a['publishedAt'])));
    });
  }

  void filterNews(String query) {
    setState(() {
      newsList = offlineNews.where((article) => article['title'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Client'),
        actions: [
          DropdownButton<String>(
            value: selectedCategory,
            items: categories.keys
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCategory = value;
                });
                fetchNews();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: sortNewsByDate,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filterNews,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final article = newsList[index];
                      return ListTile(
                        title: Text(article['title'] ?? 'No Title'),
                        subtitle: Text(article['publishedAt'] ?? 'No Date'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailPage(article: article),
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

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  NewsDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title'] ?? 'News Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(article['publishedAt'] ?? 'No Date', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            Text(article['content'] ?? 'No Content'),
          ],
        ),
      ),
    );
  }
}
