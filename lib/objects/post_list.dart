// To parse this JSON data, do
//
//     final postList = postListFromJson(jsonString);

import 'dart:convert';

class PostList {
  PostList({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  final int count;
  final String next;
  final dynamic previous;
  final List<Result> results;

  factory PostList.fromRawJson(String str) => PostList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PostList.fromJson(Map<String, dynamic> json) => PostList(
    count: json["count"],
    next: json["next"],
    previous: json["previous"],
    results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "next": next,
    "previous": previous,
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
  };
}

class Result {
  Result({
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

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) => Result(
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
