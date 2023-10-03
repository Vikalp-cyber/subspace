import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subspace/blogdetail.dart';
import 'package:subspace/models/blog.dart';
import 'package:subspace/provider/blogprovider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showFavorites = false;

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    final blogProvider = Provider.of<BlogProvider>(context, listen: false);
    blogProvider.fetchData();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: SizedBox(
          width: 200,
          child: Image.asset(
            "assets/images/subspace.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          filterOptions(),
          Expanded(
            child: Consumer<BlogProvider>(
              builder: (context, blogProvider, child) {
                if (blogProvider.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.white,
                  ));
                } else if (blogProvider.hasError) {
                  return Center(child: Text('Error: ${blogProvider.error}'));
                } else if (blogProvider.blogg.isEmpty) {
                  return const Center(
                      child: Text(
                    'No data available.',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ));
                } else {
                  final filteredBlogs = showFavorites
                      ? blogProvider.blogg
                          .where((blog) => blog.isFavourite)
                          .toList()
                      : blogProvider.blogg;

                  return BlogList(filteredBlogs);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListView BlogList(List<Blog> filteredBlogs) {
    return ListView.builder(
      itemCount: filteredBlogs.length,
      itemBuilder: (context, index) {
        final blog = filteredBlogs[index];
        return GestureDetector(
          onTap: () async {
            final isFavorite = await _toggleFavoriteStatus(blog.id);
            setState(() {
              blog.isFavourite = isFavorite;
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 78, 78, 78),
            ),
            margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      blog.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: Text(
                          blog.title,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final isFavorite =
                              await _toggleFavoriteStatus(blog.id);
                          setState(() {
                            blog.isFavourite = isFavorite;
                          });
                        },
                        icon: Icon(
                          blog.isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Container filterOptions() {
    return Container(
      margin: const EdgeInsets.only(left: 20, bottom: 10),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                showFavorites = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: showFavorites
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text(
                "All Blogs",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                showFavorites = true;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: !showFavorites
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text(
                "Favorites",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _toggleFavoriteStatus(String blogId) async {
    _prefs ??= await SharedPreferences.getInstance();

    if (_prefs != null) {
      final favorites = _prefs!.getStringList('favorite_blogs') ?? [];
      if (favorites.contains(blogId)) {
        favorites.remove(blogId);
      } else {
        favorites.add(blogId);
      }
      await _prefs!.setStringList('favorite_blogs', favorites);
      return favorites.contains(blogId);
    }
    return false;
  }
}
