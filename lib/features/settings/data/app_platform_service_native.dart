class AppPlatformService {
  bool get supportsPwa => false;
  bool get isStandalone => false;
  bool get isIosSafari => false;
  Stream<void> get updates => const Stream.empty();

  void applyUpdate() {}
}
