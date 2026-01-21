class FeedbackResponse {
  final String id;
  final String attendeeId;
  final String attendeeName;
  final int rating;
  final String comments;
  final String submittedAt;

  FeedbackResponse({
    required this.id,
    required this.attendeeId,
    required this.attendeeName,
    required this.rating,
    required this.comments,
    required this.submittedAt,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      id: json['id'] as String,
      attendeeId: json['attendeeId'] as String,
      attendeeName: json['attendeeName'] as String,
      rating: json['rating'] as int,
      comments: json['comments'] as String,
      submittedAt: json['submittedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendeeId': attendeeId,
      'attendeeName': attendeeName,
      'rating': rating,
      'comments': comments,
      'submittedAt': submittedAt,
    };
  }
}
