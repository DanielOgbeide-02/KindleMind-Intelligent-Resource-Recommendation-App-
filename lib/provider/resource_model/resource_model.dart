class ResourceModel {
  final String quote;
  final String author;
  final String articleType;
  final bool isLiked;
  final bool isDisliked;
  final bool isShared;
  final bool isSaved;

  ResourceModel({
    required this.quote,
    required this.author,
    required this.articleType,
    this.isLiked = false,
    this.isDisliked = false,
    this.isShared = false,
    this.isSaved = false,
  });

  factory ResourceModel.fromMap(Map<String, dynamic> data) {
    return ResourceModel(
      quote: data['quote'] ?? data['content'] ?? data['title'] ?? '', // Fallback to content or title
      author: data['author'] ?? '',
      articleType: data['articleType'] ?? '', // Set based on collection or add logic
      isLiked: data['isLiked'] ?? false,
      isDisliked: data['isDisliked'] ?? false,
      isShared: data['isShared'] ?? false,
      isSaved: data['isSaved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quote': quote,
      'author': author,
      'articleType': articleType,
      'isLiked': isLiked,
      'isDisliked': isDisliked,
      'isShared': isShared,
      'isSaved': isSaved,
    };
  }

  // ✅ Add copyWith
  ResourceModel copyWith({
    bool? isLiked,
    bool? isDisliked,
    bool? isShared,
    bool? isSaved,
  }) {
    return ResourceModel(
      quote: quote,
      author: author,
      articleType: articleType,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
      isShared: isShared ?? this.isShared,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
