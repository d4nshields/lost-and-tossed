import 'package:json_annotation/json_annotation.dart';
import 'profile.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final String id;
  @JsonKey(name: 'item_id')
  final String itemId;
  @JsonKey(name: 'author_id')
  final String authorId;
  final String content;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Expanded fields (from joins)
  final Profile? author;

  const Comment({
    required this.id,
    required this.itemId,
    required this.authorId,
    required this.content,
    this.createdAt,
    this.updatedAt,
    this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  Comment copyWith({
    String? id,
    String? itemId,
    String? authorId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    Profile? author,
  }) {
    return Comment(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Comment(id: $id, authorId: $authorId, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';
  }
}

/// Data class for creating new comments
@JsonSerializable()
class CreateCommentRequest {
  @JsonKey(name: 'item_id')
  final String itemId;
  final String content;

  const CreateCommentRequest({
    required this.itemId,
    required this.content,
  });

  factory CreateCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCommentRequestToJson(this);
}
