class InstallService {
  static bool get isStandalone => false;
  static bool get canPrompt => false;
  static bool get shouldShow => false;
  static String get instructions => 'Use your browser menu to add CampusTrust to your home screen.';
  static Future<bool> prompt() async => false;
  static void dismiss() {}
}
