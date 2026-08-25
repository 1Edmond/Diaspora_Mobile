import 'package:flutter/material.dart';

class Review {
  final String id;
  final String listingId;
  final String reviewerId;
  final String reviewerName;
  final int rating;
  final String comment;
  final bool isVerified;
  final DateTime createdAt;
  final String? providerReply;
  final DateTime? providerRepliedAt;

  const Review({
    required this.id,
    required this.listingId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.isVerified,
    required this.createdAt,
    this.providerReply,
    this.providerRepliedAt,
  });

  Review copyWith({
    String? id,
    String? listingId,
    String? reviewerId,
    String? reviewerName,
    int? rating,
    String? comment,
    bool? isVerified,
    DateTime? createdAt,
    String? providerReply,
    DateTime? providerRepliedAt,
  }) {
    return Review(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      providerReply: providerReply ?? this.providerReply,
      providerRepliedAt: providerRepliedAt ?? this.providerRepliedAt,
    );
  }

  String getFormattedDate(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    if (diff.inDays < 30) return 'Il y a ${(diff.inDays / 7).floor()} sem.';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String getReviewerDisplayName() {
    return reviewerName.trim().isNotEmpty ? reviewerName : 'Utilisateur';
  }

  List<Widget> getRatingStars(BuildContext context, {double size = 16}) {
    return List.generate(5, (index) {
      return Icon(
        index < rating ? Icons.star_rounded : Icons.star_border_rounded,
        color: Colors.amber,
        size: size,
      );
    });
  }

  bool get hasProviderReply => providerReply != null && providerReply!.isNotEmpty;

  String? getFormattedReplyDate(BuildContext context) {
    if (providerRepliedAt == null) return null;
    final diff = DateTime.now().difference(providerRepliedAt!);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Hier';
    return '${providerRepliedAt!.day}/${providerRepliedAt!.month}/${providerRepliedAt!.year}';
  }
}