import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

class InstallService {
  static bool get isStandalone =>
      html.window.matchMedia('(display-mode: standalone)').matches ||
      (html.window.navigator as dynamic).standalone == true;

  static bool get canPrompt => js_util.callMethod<bool>(
        js_util.globalThis,
        'campusTrustCanInstall',
        const [],
      ) ?? false;

  static bool get shouldShow =>
      !isStandalone && html.window.localStorage['campustrust-install-dismissed'] != 'true';

  static String get instructions {
    final ua = html.window.navigator.userAgent.toLowerCase();
    if (ua.contains('iphone') || ua.contains('ipad')) {
      return 'Tap Share in Safari, then choose Add to Home Screen.';
    }
    return 'Open your browser menu and choose Install app or Add to Home screen.';
  }

  static Future<bool> prompt() async {
    if (!canPrompt) return false;
    final promise = js_util.callMethod<Object?>(
      js_util.globalThis,
      'campusTrustInstall',
      const [],
    );
    final result = await js_util.promiseToFuture<bool>(promise!);
    if (result) dismiss();
    return result;
  }

  static void dismiss() {
    html.window.localStorage['campustrust-install-dismissed'] = 'true';
  }
}
