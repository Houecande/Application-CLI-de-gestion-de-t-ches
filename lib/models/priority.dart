import '../exceptions/custom_exceptions.dart';
enum Priority {
  low,
  medium,
  high;

  static Priority fromString(String str) {
    switch (str.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        throw InvalidInputException('Propriété invalide: $str');
    }
  }

  int get value {
    switch (this) {
      case Priority.low:
        return 1;
      case Priority.medium:
        return 2;
      case Priority.high:
        return 3;
    }
  }
}