class ServerException implements Exception {
  final String message;
  ServerException([this.message = "Server Issues"]);

  @override
  String toString() => "ServerException: $message";
}