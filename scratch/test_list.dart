void main() {
  var s_id = '1';
  var s_name = 'Test';
  var theoryCompletion = 0;
  var practicalCompletion = 0;

  final List<dynamic> row = [s_id, s_name];
  print(row.runtimeType);

  try {
    row.addAll([theoryCompletion, practicalCompletion]);
    print(row);
  } catch (e, st) {
    print('Error 1: $e');
  }
}
