import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://gttp.efsouls.com/api',
    headers: {
      'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2d0dHAuZWZzb3Vscy5jb20vYXBpL2F1dGgvdmVyaWZ5LW90cCIsImlhdCI6MTc3NjQzMDg5MywiZXhwIjoxNzc2NDM0NDkzLCJuYmYiOjE3NzY0MzA4OTMsImp0aSI6IkZTODhZb1M5cWZiN2JEbEciLCJzdWIiOiIyIiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyJ9.s2Yzj_Pjnd_KxvjnyRivadld_2hAbFwuE9t2o638fOY',
    },
  ));

  final endpoints = [
    '/dashboard',
    '/certificates',
    '/schedules',
    '/subjects',
    '/syllabus',
    '/timetable',
    '/notices',
    '/schools',
    '/students',
    '/classes'
  ];

  Map<String, dynamic> schemas = {};

  for (var endpoint in endpoints) {
    debugPrint('Fetching \$endpoint...');
    try {
      final res = await dio.get(endpoint);
      schemas[endpoint] = res.data;
      debugPrint('Success!');
    } on DioException catch (e) {
      schemas[endpoint] = {'error': e.response?.data ?? e.message};
      debugPrint('Failed: \${e.message}');
    }
  }

  File('scratch/schema.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(schemas));
  debugPrint('Done!');
}
