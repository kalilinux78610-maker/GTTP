void main() {
  int score = 1;
  int totalPoints = 1;
  int percentage = totalPoints > 0 ? ((score / totalPoints) * 100).round() : 0;
  bool passed = percentage >= 50;
  print("percentage: $percentage, passed: $passed");

  score = 1;
  totalPoints = 2;
  percentage = totalPoints > 0 ? ((score / totalPoints) * 100).round() : 0;
  passed = percentage >= 50;
  print("percentage: $percentage, passed: $passed");
}
