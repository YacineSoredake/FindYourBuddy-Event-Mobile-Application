class EventException implements Exception {
  final String message;
  EventException([this.message = "Event error"]);

  @override
  String toString() => message;
}

class EventCreatingException extends EventException {
  EventCreatingException([super.message = "event creation failed"]);
}

class EventFetchException extends EventException {
  EventFetchException([super.message = "fetching event failed"]);
}

class MarkInterestException extends EventException {
  MarkInterestException([super.message = "marking interest failed"]);
}

class UnmarkInterestException extends EventException {
  UnmarkInterestException([super.message = "Unmarking interest failed"]);
}
