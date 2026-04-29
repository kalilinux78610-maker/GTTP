import 'package:csv/csv.dart' as csv_pkg;

void main() {
  final input = [['name', 'age'], ['Alice', 30], ['Bob', 25]];
  final encoded = csv_pkg.csv.encode(input);
  print('Encoded: $encoded');
}
