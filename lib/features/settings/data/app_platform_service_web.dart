import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

class AppPlatformService {
  final StreamController<void> _updates = StreamController<void>.broadcast();

  AppPlatformService() {
    web.window.addEventListener(
      'trendstock-update-ready',
      ((web.Event _) => _updates.add(null)).toJS,
    );
  }

  bool get supportsPwa => true;

  bool get isStandalone =>
      web.window.matchMedia('(display-mode: standalone)').matches;

  bool get isIosSafari {
    final userAgent = web.window.navigator.userAgent.toLowerCase();
    final isIos = RegExp(r'iphone|ipad|ipod').hasMatch(userAgent);
    final isWebKit = userAgent.contains('webkit');
    final isOtherIosBrowser = RegExp(r'crios|fxios|edgios').hasMatch(userAgent);
    return isIos && isWebKit && !isOtherIosBrowser;
  }

  Stream<void> get updates => _updates.stream;

  void applyUpdate() {
    web.window.dispatchEvent(web.Event('trendstock-apply-update'));
  }
}
