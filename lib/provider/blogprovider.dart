import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subspace/models/blog.dart';

class BlogProvider with ChangeNotifier {
  final String adminSecret =
      '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';
  List<Blog> blogg = [];
  bool isLoading = false;
  bool hasError = false;
  String error = '';

  StreamController<List<Blog>> _blogStreamController =
      StreamController<List<Blog>>.broadcast();

  Stream<List<Blog>> get blogStream => _blogStreamController.stream;

  
  late SharedPreferences _prefs;
  bool _dataFetched = false; 

  BlogProvider() {
    _initSharedPreferences();
  }

  
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getBool('dataFetched') == true) {
      
      blogg = await getSavedBlogData();
      _blogStreamController.sink.add(blogg);
    }
  }

 
  bool get dataFetched => _dataFetched;

  
  void markDataFetched() {
    _dataFetched = true;
    _prefs.setBool('dataFetched', true);
  }

  Future<void> fetchData() async {
    isLoading = true;
    hasError = false;
    error = '';

    
    if (_dataFetched) {
      isLoading = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://intent-kit-16.hasura.app/api/rest/blogs'),
        headers: {'x-hasura-admin-secret': adminSecret},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final blogList = jsonData['blogs'] as List<dynamic>;

        blogg = blogList.map((blogData) => Blog.fromJson(blogData)).toList();
        _blogStreamController.sink.add(blogg);

       
        await saveBlogData(blogg);

        
        markDataFetched();
      } else {
        hasError = true;
        error = 'Failed to load data';
      }
    } catch (e) {
      hasError = true;
      error = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> saveBlogData(List<Blog> blogs) async {
    final blogListJson = blogs.map((blog) => blog.toJson()).toList();
    await _prefs.setString('blogData', json.encode(blogListJson));
  }

  
  Future<List<Blog>> getSavedBlogData() async {
    final blogDataJson = _prefs.getString('blogData');
    if (blogDataJson != null) {
      final List<dynamic> decodedJson = json.decode(blogDataJson);
      return decodedJson.map((json) => Blog.fromJson(json)).toList();
    }
    return [];
  }

  void dispose() {
    _blogStreamController.close();
  }
}
