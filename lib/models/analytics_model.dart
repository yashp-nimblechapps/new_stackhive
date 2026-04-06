import 'package:stackhive/models/question_model.dart';
import 'package:stackhive/models/tag_model.dart';
import 'package:stackhive/models/user_model.dart';

class AnalyticsData {
  final TagModel? topTag;
  final QuestionModel? topQuestion;
  final AppUser? topContributor;

  final int totalVotes;
  final int totalQuestions;
  final int totalAnswers;

  /// NEW
  final List<TagModel> tagDistribution;
  final List<AppUser> topContributors;

  final List<int> questionsPerDay;
  final List<int> answersPerDay;

  AnalyticsData({
    this.topTag,
    this.topQuestion,
    this.topContributor,
    required this.totalVotes,
    required this.totalQuestions,
    required this.totalAnswers,

    required this.tagDistribution,
    required this.topContributors,

    this.questionsPerDay = const [],
    this.answersPerDay = const [],
  });
}