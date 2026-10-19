import 'package:dio/dio.dart';

Future<Map<String, dynamic>?> fetchStockSearchData(
  Dio dio, {
  required String endpoint,
  required String keyword,
  required String token,
  required int count,
}) async {
  final response = await dio.get(
    endpoint,
    queryParameters: {
      'input': keyword,
      'type': '14',
      'count': count,
      'token': token,
    },
  );
  final data = response.data;
  return data is Map<String, dynamic> ? data : null;
}
