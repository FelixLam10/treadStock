import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dio/dio.dart';
import 'package:web/web.dart';

Future<Map<String, dynamic>?> fetchStockSearchData(
  Dio dio, {
  required String endpoint,
  required String keyword,
  required String token,
  required int count,
}) {
  final completer = Completer<Map<String, dynamic>?>();
  final callbackName =
      '_stockpilotSearch${DateTime.now().microsecondsSinceEpoch}';
  late final HTMLScriptElement script;
  Timer? timeout;

  void cleanup() {
    timeout?.cancel();
    script.remove();
    globalContext.setProperty(callbackName.toJS, null);
  }

  void completeWithError(Object error) {
    if (completer.isCompleted) return;
    cleanup();
    completer.completeError(error);
  }

  final callback = ((JSAny? value) {
    if (completer.isCompleted) return;
    final decoded = value?.dartify();
    cleanup();
    if (decoded is Map) {
      final normalized = jsonDecode(jsonEncode(decoded));
      completer.complete(normalized as Map<String, dynamic>);
    } else {
      completer.complete(null);
    }
  }).toJS;
  globalContext.setProperty(callbackName.toJS, callback);

  final uri = Uri.parse(endpoint).replace(
    queryParameters: {
      'input': keyword,
      'type': '14',
      'count': '$count',
      'token': token,
      'cb': callbackName,
    },
  );
  script = document.createElement('script') as HTMLScriptElement;
  script.src = uri.toString();
  script.setProperty(
    'onerror'.toJS,
    ((JSAny? _) => completeWithError(StateError('股票搜索请求失败'))).toJS,
  );
  document.head!.append(script);
  timeout = Timer(
    const Duration(seconds: 10),
    () => completeWithError(TimeoutException('股票搜索请求超时')),
  );

  return completer.future;
}
