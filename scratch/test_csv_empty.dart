import 'package:csv/csv.dart';

void main() {
  final converter = ListToCsvConverter();
  try {
    print(converter.convert([]));
  } catch(e) {
    print('Empty list: $e');
  }

  try {
    print(converter.convert([['a', 'b']]));
  } catch(e) {
    print('Headers only: $e');
  }
}
