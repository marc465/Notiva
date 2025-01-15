class Tag {
  String tag;
  List<int> idOfNotesInTag;

  Tag({
    required this.tag,
    required this.idOfNotesInTag
  });

  @override
  String toString() {
    return "Folder{folderName: $tag, idOfNotesInTag: $idOfNotesInTag}";
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'idOfNotesInTag': idOfNotesInTag,
    };
  }
}