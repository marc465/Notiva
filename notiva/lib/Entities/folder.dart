class Folder {
  String folderName;
  String icon;
  List<int> idOfNotesInFolder;

  Folder({
    required this.folderName,
    required this.icon,
    required this.idOfNotesInFolder
  });

  @override
  String toString() {
    return "Folder{folderName: $folderName, icon: $icon, idOfNotesInFolder: $idOfNotesInFolder}";
  }

  Map<String, dynamic> toJson() {
    return {
      'folderName': folderName,
      'icon': icon,
      'idOfNotesInFolder': idOfNotesInFolder,
    };
  }
}