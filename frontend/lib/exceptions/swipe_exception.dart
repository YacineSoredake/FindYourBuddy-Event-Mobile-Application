class SwipeException implements Exception {
  final String message;
  SwipeException([this.message = "Swipe error"]);

  @override
  String toString() => message;
}

class CantSwipeException extends SwipeException {
  CantSwipeException([super.message = "Couldn't swipe error"]);
}

class EventNotFoundInBuddy extends SwipeException {
  EventNotFoundInBuddy([super.message = "Error in event for target"]);
}
class TargetErrorException extends SwipeException {
  TargetErrorException([super.message = "Error in target"]);
}



