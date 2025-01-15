
class QuickTag {
  int id;
  String tag;

  QuickTag({
    required this.id,
    required this.tag,
  });

  int get getId => id;
  String get getTag => tag;

  set setId(int id) => this.id = id;
  set setTag(String tag) => this.tag = tag;

  factory QuickTag.fromJson(Map<String, dynamic> json) {
    return QuickTag(
      id: json['id'],
      tag: json['tag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folder_name': tag,
    };
  }

}
