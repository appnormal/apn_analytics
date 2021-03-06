library apn_analytics;

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

abstract class IAnalyticsService {
  void trackScreen(String screenName);

  void trackEvent(String category, String action, String label);

  void trackEventWithParams(String eventName, Map<String, dynamic> params);

  void trackButton(String? category, String label) => trackEvent(category ?? 'UI', 'Button', label);
}

class FirebaseAnalyticsService extends IAnalyticsService {
  final analytics = FirebaseAnalytics();

  @override
  void trackScreen(String screenName) {
    analytics.setCurrentScreen(screenName: screenName);
    print('[Analytics] Screen: $screenName');
  }

  @override
  void trackEvent(String category, String action, String label) {
    analytics.logEvent(
      name: category,
      parameters: <String, dynamic>{
        'action': action,
        'label': label,
      },
    );

    print('[Analytics] Event category: $category, action: $action, label: $label');
  }

  @override
  void trackEventWithParams(String eventName, Map<String, dynamic> params) {
    analytics.logEvent(name: eventName, parameters: params);
  }
}

class NoopAnalytics extends IAnalyticsService {
  @override
  void trackEvent(String category, String action, String label) {
    // No-op
  }

  @override
  void trackScreen(String screenName) {
    // No-op
  }

  @override
  void trackEventWithParams(String eventName, Map<String, dynamic> params) {
    // No-op
  }
}

class AnalyticsRouteObserver extends RouteObserver {
  final IAnalyticsService analytics;

  AnalyticsRouteObserver(this.analytics);
  @override
  void didPush(Route route, Route? previousRoute) {
    // Dialogs are also pushed, but have no name
    if (route.settings.name != null) {
      analytics.trackScreen(route.settings.name!);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // Dialogs are also popped, but have no name
    if (route.settings.name != null && previousRoute?.settings.name != null) {
      analytics.trackScreen(previousRoute!.settings.name!);
    }
    super.didPop(route, previousRoute);
  }
}
