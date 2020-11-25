// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

class Post {
  Post({
    this.id,
    this.upvoteCount,
    this.downvoteCount,
    this.favouriteCount,
    this.file,
    this.owner,
    this.sharedAt,
    this.lastModified,
  });

  final String id;
  final int upvoteCount;
  final int downvoteCount;
  final int favouriteCount;
  final String file;
  final int owner;
  final DateTime sharedAt;
  final DateTime lastModified;

  factory Post.fromRawJson(String str) => Post.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json["id"],
    upvoteCount: json["upvote_count"],
    downvoteCount: json["downvote_count"],
    favouriteCount: json["favourite_count"],
    file: json["file"],
    owner: json["owner"],
    sharedAt: DateTime.parse(json["shared_at"]),
    lastModified: DateTime.parse(json["last_modified"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "upvote_count": upvoteCount,
    "downvote_count": downvoteCount,
    "favourite_count": favouriteCount,
    "file": file,
    "owner": owner,
    "shared_at": sharedAt.toIso8601String(),
    "last_modified": lastModified.toIso8601String(),
  };
}
