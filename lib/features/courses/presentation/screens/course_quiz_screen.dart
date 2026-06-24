import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/courses/presentation/providers/course_module_provider.dart';
import '../../data/repositories/courses_repository_impl.dart';


class CourseQuizScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String moduleId;
  final String? submoduleId;

  const CourseQuizScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    this.submoduleId,
  });

  @override
  ConsumerState<CourseQuizScreen> createState() => _CourseQuizScreenState();
}

class _CourseQuizScreenState extends ConsumerState<CourseQuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, String> _selectedAnswers = {}; // questionId -> optionId
  bool _isSubmitted = false;
  int _score = 0;

  bool _isSubmitting = false;

  void _submitQuiz(List<dynamic> questions) async {
    int score = 0;
    try {
      for (final question in questions) {
        final selectedOptionId = _selectedAnswers[question.id];
        if (selectedOptionId != null) {
          dynamic selectedOption;
          for (final o in question.options) {
            if (o.id == selectedOptionId) {
              selectedOption = o;
              break;
            }
          }
          selectedOption ??= question.options[0]; // fallback
          
          debugPrint('Question ID: ${question.id}');
          debugPrint('Selected Option ID: ${selectedOption.id}');
          debugPrint('Is Correct: ${selectedOption.isCorrect}');
          debugPrint('Question Points: ${question.points}');

          if (selectedOption.isCorrect == true || 
              selectedOption.isCorrect == 1 || 
              selectedOption.isCorrect?.toString() == '1' || 
              selectedOption.isCorrect?.toString().toLowerCase() == 'true') {
            score += (question.points as int);
          }
        }
      }
      debugPrint('Calculated Score: $score');

      int totalPoints = questions.fold(0, (sum, q) => sum + (q.points as int));
      int percentage = totalPoints > 0 ? ((score / totalPoints) * 100).round() : 0;
      bool passed = percentage >= 50;

      setState(() {
        _isSubmitting = true;
      });

      await ref.read(coursesRepositoryProvider).submitQuiz(
            widget.courseId,
            widget.moduleId,
            percentage,
            passed,
            widget.submoduleId,
          );
      
      if (mounted) {
        setState(() {
          _score = score;
          _isSubmitted = true;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final moduleAsync = ref.watch(courseModuleProvider((
      courseId: widget.courseId,
      moduleId: widget.moduleId,
    )));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MCQ Quiz'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1C1E),
      ),
      body: SafeArea(
        child: moduleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading quiz: $err')),
          data: (module) {
            if (module == null) {
              return const Center(child: Text('Module not found.'));
            }
            
            List<dynamic> questions = [];
            if (widget.submoduleId != null) {
              final session = module.sessions.firstWhere(
                (s) => s.id == widget.submoduleId,
                orElse: () => module.sessions.first,
              );
              questions = session.mcqQuestions;
            } else {
              questions = module.mcqQuestions;
            }
            
            if (questions.isEmpty) {
              return const Center(child: Text('No quiz questions available.'));
            }

            if (_isSubmitted) {
              return _buildResultView(questions);
            }

            return _buildQuizView(questions);
          },
        ),
      ),
    );
  }

  Widget _buildQuizView(List<dynamic> questions) {
    final question = questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == questions.length - 1;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress
          Text(
            'Question ${_currentQuestionIndex + 1} of ${questions.length}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / questions.length,
            backgroundColor: const Color(0xFFE8ECF0),
            color: const Color(0xFF7C3AED),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 32),

          // Question Text
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 24),

          // Options
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isSelected = _selectedAnswers[question.id] == option.id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAnswers[question.id] = option.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF3E8FF) : Colors.white,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE5E7EB),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF9CA3AF),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Center(
                                  child: CircleAvatar(
                                    radius: 6,
                                    backgroundColor: Color(0xFF7C3AED),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option.optionText,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? const Color(0xFF4C1D95) : const Color(0xFF374151),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation Buttons
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Previous'),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : () {
                    if (_selectedAnswers[question.id] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select an answer')),
                      );
                      return;
                    }

                    if (isLastQuestion) {
                      _submitQuiz(questions);
                    } else {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting && isLastQuestion 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : Text(isLastQuestion ? 'Submit Quiz' : 'Next Question'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(List<dynamic> questions) {
    int totalPoints = questions.fold(0, (sum, q) => sum + (q.points as int));
    double percentage = totalPoints > 0 ? (_score / totalPoints) * 100 : 0;
    bool passed = percentage >= 50;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: passed ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                passed ? Icons.emoji_events : Icons.cancel_outlined,
                size: 40,
                color: passed ? const Color(0xFF059669) : const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              passed ? 'Quiz Completed!' : 'Quiz Failed',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You scored $_score out of $totalPoints points',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.pop(true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Return to Module'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
