import 'package:stackhive/features/question/data/question_sort.dart';

class PaginationParams {
  final String? tag;
  final QuestionSort sort;

  PaginationParams({
    required this.tag, 
    required this.sort
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationParams && 
          runtimeType == other.runtimeType &&
          tag == other.tag &&
          sort == other.sort;

  @override
  int get hashCode => tag.hashCode ^ sort.hashCode;        
}