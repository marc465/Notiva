class Tag {
  String tag;

  Tag({
    required this.tag,
  });

  @override
  String toString() {
    return "Folder{folderName: $tag}";
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
    };
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tag: json['tag'],
    );
  }
}