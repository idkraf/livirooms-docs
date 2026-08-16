class Review {
  final int id;
  final int rating;
  final String? comment;
  final String? hostReply;
  final List<String> photos;
  final String userName;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    this.hostReply,
    this.photos = const [],
    required this.userName,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as int,
        rating: json['rating'] as int? ?? 0,
        comment: json['comment'] as String?,
        hostReply: json['host_reply'] as String?,
        photos: json['photos'] is List
            ? (json['photos'] as List).map((e) => '$e').toList()
            : const [],
        userName: (json['user'] is Map<String, dynamic>)
            ? (json['user']['name'] as String? ?? 'User')
            : 'User',
        createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
      );
}
