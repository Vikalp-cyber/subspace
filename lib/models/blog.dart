class Blog {
  final String id;

  final String imageUrl;

  final String title;

  bool isFavourite;

  Blog({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.isFavourite = false,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      title: json['title'] as String,
      isFavourite: json['isFavourite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'isFavourite': isFavourite,
    };
  }
}
