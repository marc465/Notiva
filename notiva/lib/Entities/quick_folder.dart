
class QuickFolder {
  int id;
  String folderName;
  String icon;
  int count_notes;

  QuickFolder({
    required this.id,
    required this.folderName,
    required this.icon,
    required this.count_notes
  });

  int get getId => id;
  String get getFolderName => folderName;
  String get getIcon => icon;

  set setId(int id) => this.id = id;
  set setFolderName(String folderName) => this.folderName = folderName;
  set setIcon(String icon) => this.icon = icon;
  set setCountNotes(int countNotes) => count_notes = count_notes;

  factory QuickFolder.fromJson(Map<String, dynamic> json) {
    return QuickFolder(
      id: json['id'],
      folderName: json['folder_name'],
      icon: json['icon'],
      count_notes: int.parse(json['count_notes'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folder_name': folderName,
      'icon': icon,
    };
  }

  @override
  String toString() {
    return 'Folders{id: $id, folderName: $folderName, icon: $icon, count_notes: $count_notes}';
  }
}
