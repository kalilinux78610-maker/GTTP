import 'package:share_plus/share_plus.dart';
void main() {
  Share.shareXFiles([XFile('foo.csv')], text: 'Export');
}
