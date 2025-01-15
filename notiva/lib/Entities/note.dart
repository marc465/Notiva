
class Note {
  int id;
  String notesName;
  String summary;
  String transcript;
  int userId;
  DateTime timeOfCreation;
  DateTime timeOfLastChanges;
  String icon;
  bool isFavourite;
  bool isEveryoneCanAccess;
  int fileSize;
  int bps;

  Note({
    required this.id,
    required this.notesName,
    required this.summary,
    required this.transcript,
    required this.userId,
    required this.timeOfCreation,
    required this.timeOfLastChanges,
    required this.icon,
    required this.isFavourite,
    required this.isEveryoneCanAccess,
    required this.fileSize,
    required this.bps,

  });

  int get getId => id;
  String get getNotesName => notesName;
  String get getSummary => summary;
  String get getTranscript => transcript;
  int get getUser => userId;
  DateTime get getTimeOfCreation => timeOfCreation;
  DateTime get getTimeOfLastChanges => timeOfLastChanges;
  String get getIcon => icon;
  bool get getIsFavourite => isFavourite;
  bool get getIsEveryoneCanAccess => isEveryoneCanAccess;
  int get getFileSize => fileSize;
  int get getbps => bps;


  set setId(int id) => this.id = id;
  set setNotesName(String notesName) => this.notesName = notesName;
  set setSummary(String summary) => this.summary = summary;
  set setTranscript(String transcript) => this.transcript = transcript;
  set setUser(int user) => this.userId = user;
  set setTimeOfCreation(DateTime timeOfCreation) => this.timeOfCreation = timeOfCreation;
  set setTimeOfLastChanges(DateTime timeOfLastChanges) => this.timeOfLastChanges = timeOfLastChanges;
  set setIcon(String icon) => this.icon = icon;
  set setIsFavourite(bool isFavourite) => this.isFavourite = isFavourite;
  set setIsEveryoneCanAccess(bool isEveryoneCanAccess) => this.isEveryoneCanAccess = isEveryoneCanAccess;
  set setFileSize(int fileSize) => this.fileSize = fileSize;
  set setbps(int bps) => this.bps = bps;

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      notesName: json['notes_name'],
      summary: json['summary'],
      transcript: json['transcript'],
      userId: json['userId'],
      timeOfCreation: DateTime.parse(json['time_of_creation']),
      timeOfLastChanges: DateTime.parse(json['time_of_last_changes']),
      icon: json['icon'],
      isFavourite: json['is_favourite'],
      isEveryoneCanAccess: json['is_everyone_can_access'],
      fileSize: json['audioFileSize'],
      bps: json['bps']
    );
  }

}
