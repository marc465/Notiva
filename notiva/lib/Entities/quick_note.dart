
class QuickNote {
  int id;
  String notesName;
  String transcript;
  DateTime timeOfCreation;
  DateTime timeOfLastChanges;
  String icon;
  bool isFavourite;

  QuickNote({
    required this.id,
    required this.notesName,
    required this.transcript,
    required this.timeOfCreation,
    required this.timeOfLastChanges,
    required this.icon,
    required this.isFavourite,
  });

  int get getId => id;
  String get getNotesName => notesName;
  String get getTranscript => transcript;
  DateTime get getTimeOfCreation => timeOfCreation;
  DateTime get getTimeOfLastChanges => timeOfLastChanges;
  String get getIcon => icon;
  bool get getIsFavourite => isFavourite;

  set setId(int id) => this.id = id;
  set setNotesName(String notesName) => this.notesName = notesName;
  set setTranscript(String transcript) => this.transcript = transcript;
  set setTimeOfCreation(DateTime timeOfCreation) => this.timeOfCreation = timeOfCreation;
  set setTimeOfLastChanges(DateTime timeOfLastChanges) => this.timeOfLastChanges = timeOfLastChanges;
  set setIcon(String icon) => this.icon = icon;
  set setIsFavourite(bool isFavourite) => this.isFavourite = isFavourite;

  factory QuickNote.fromJson(Map<String, dynamic> json) {
    return QuickNote(
      id: json['id'],
      notesName: json['notes_name'],
      transcript: json['transcript'],
      timeOfCreation: DateTime.parse(json['time_of_creation']),
      timeOfLastChanges: DateTime.parse(json['time_of_last_changes']),
      icon: json['icon'],
      isFavourite: json['is_favourite'],
    );
  }

  @override
  String toString() {
    return 'QuickNote{notesName: $notesName, transcript: $transcript, timeOfCreation: $timeOfCreation, timeOfLastChanges: $timeOfLastChanges, icon: $icon, isFavourite: $isFavourite}';
  }

    @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickNote &&
          runtimeType == other.runtimeType &&
          notesName == other.notesName &&
          transcript == other.transcript &&
          timeOfCreation == other.timeOfCreation &&
          timeOfLastChanges == other.timeOfLastChanges &&
          icon == other.icon &&
          isFavourite == other.isFavourite;

  @override
  int get hashCode =>
      notesName.hashCode ^
      transcript.hashCode ^
      timeOfCreation.hashCode ^
      timeOfLastChanges.hashCode ^
      icon.hashCode ^
      isFavourite.hashCode;

}
