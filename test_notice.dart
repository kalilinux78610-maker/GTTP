import 'dart:io';
import 'dart:convert';
void main() async {
  var req = await HttpClient().postUrl(Uri.parse('https://gttp.efsouls.com/api/auth/login'));
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode({'email':'shreyanshvasava@efsouls.com', 'password':'password'}));
  var res = await req.close();
  var body = await res.transform(utf8.decoder).join();
  var token = jsonDecode(body)['access_token'];
  print('Token: $token');
  
  var req2 = await HttpClient().getUrl(Uri.parse('https://gttp.efsouls.com/api/notices'));
  req2.headers.set('Authorization', 'Bearer $token');
  req2.headers.set('Accept', 'application/json');
  var res2 = await req2.close();
  var body2 = await res2.transform(utf8.decoder).join();
  print('Notices: $body2');
}
