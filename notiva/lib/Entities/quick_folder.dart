
class QuickFolder {
  int id;
  String folderName;
  String icon;

  QuickFolder({
    required this.id,
    required this.folderName,
    required this.icon
  });

  int get getId => id;
  String get getFolderName => folderName;
  String get getIcon => icon;

  set setId(int id) => this.id = id;
  set setFolderName(String folderName) => this.folderName = folderName;
  set setIcon(String icon) => this.icon = icon;

  factory QuickFolder.fromJson(Map<String, dynamic> json) {
    return QuickFolder(
      id: json['id'],
      folderName: json['folder_name'],
      icon: json['icon']
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
    return 'Folders{folderName: $folderName, icon: $icon}';
  }
}
