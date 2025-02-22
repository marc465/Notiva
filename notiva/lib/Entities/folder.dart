class Folder {
  int id;
  String folderName;
  String folderDescription;
  String icon;

  Folder({
    required this.id,
    required this.folderName,
    required this.folderDescription,
    required this.icon,
  });

  @override
  String toString() {
    return "Folder{id: $id, folderName: $folderName, folderDescription: $folderDescription, icon: $icon";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folderName': folderName,
      'folderDescription': folderDescription,
      'icon': icon,
    };
  }

    factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      folderName: json['folder_name'],
      folderDescription: json['description'],
      icon: json['icon']
    );
  }
}