import 'dart:async';

import 'package:flutter/services.dart';

const String adbackFlutterVersion = '0.1.0';

enum AdbackEnvironment {
  development,
  production;

  String get wireName => name;
}

enum AdbackLogLevel {
  off,
  error,
  warn,
  info,
  debug;

  String get wireName => name;
}

enum AdbackStandardEvent {
  addToCart('ADD_TO_CART'),
  addToWishlist('ADD_TO_WISHLIST'),
  install('INSTALL'),
  initiateCheckout('INITIATE_CHECKOUT'),
  levelComplete('LEVEL_COMPLETE'),
  levelStart('LEVEL_START'),
  login('LOGIN'),
  register('SIGN_UP'),
  search('SEARCH'),
  share('SHARE'),
  signUp('SIGN_UP'),
  startTrial('START_TRIAL'),
  tutorialComplete('TUTORIAL_COMPLETE'),
  viewContent('VIEW_CONTENT'),
  viewItem('VIEW_ITEM');

  const AdbackStandardEvent(this.wireName);

  final String wireName;
}

class AdbackOptions {
  const AdbackOptions({
    this.apiBaseURL = 'https://api.adback.app',
    this.debug = false,
    this.environment = AdbackEnvironment.production,
    this.logLevel = AdbackLogLevel.error,
    this.networkEnabled = true,
    this.wrapperName,
    this.wrapperVersion,
  });

  final String apiBaseURL;
  final bool debug;
  final AdbackEnvironment environment;
  final AdbackLogLevel logLevel;
  final bool networkEnabled;
  final String? wrapperName;
  final String? wrapperVersion;

  Map<String, Object?> toMap() => <String, Object?>{
        'apiBaseURL': apiBaseURL,
        'debug': debug,
        'environment': environment.wireName,
        'logLevel': logLevel.wireName,
        'networkEnabled': networkEnabled,
        'wrapperName': wrapperName ?? 'flutter',
        'wrapperVersion': wrapperVersion ?? adbackFlutterVersion,
      };
}

class AdbackConfiguration {
  const AdbackConfiguration({
    required this.apiKey,
    required this.options,
  });

  final String apiKey;
  final Map<String, Object?> options;

  static AdbackConfiguration? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return null;
    }

    final options = map['options'];

    return AdbackConfiguration(
      apiKey: map['apiKey'] as String,
      options: Map<String, Object?>.from(options as Map<dynamic, dynamic>),
    );
  }
}

class AdbackUserMatchData {
  const AdbackUserMatchData({
    this.dateOfBirth,
    this.email,
    this.externalId,
    this.firstName,
    this.lastName,
    this.phone,
  });

  final String? dateOfBirth;
  final String? email;
  final String? externalId;
  final String? firstName;
  final String? lastName;
  final String? phone;

  Map<String, Object?> toMap() => <String, Object?>{
        'dateOfBirth': dateOfBirth,
        'email': email,
        'externalId': externalId,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      }..removeWhere((_, value) => value == null);
}

class AdbackUser {
  const AdbackUser({
    this.customerUserId,
    this.matchData = const AdbackUserMatchData(),
  });

  final String? customerUserId;
  final AdbackUserMatchData matchData;

  Map<String, Object?> toMap() => <String, Object?>{
        'customerUserId': customerUserId,
        'matchData': matchData.toMap(),
      }..removeWhere((_, value) => value == null);
}

class Adback {
  Adback._();

  static final Adback instance = Adback._();
  static const MethodChannel _channel = MethodChannel('app.adback.flutter/sdk');

  Future<void> configure(
    String apiKey, {
    AdbackOptions options = const AdbackOptions(),
  }) {
    return _channel.invokeMethod<void>('configure', <String, Object?>{
      'apiKey': apiKey,
      'options': options.toMap(),
    });
  }

  Future<void> enableAppleAdsAttribution() {
    return _channel.invokeMethod<void>('enableAppleAdsAttribution');
  }

  Future<bool> isConfigured() async {
    return await _channel.invokeMethod<bool>('isConfigured') ?? false;
  }

  Future<AdbackConfiguration?> currentConfiguration() async {
    final result = await _channel.invokeMapMethod<dynamic, dynamic>(
      'currentConfiguration',
    );

    return AdbackConfiguration.fromMap(result);
  }

  Future<String?> getAdbackId() {
    return _channel.invokeMethod<String>('getAdbackId');
  }

  Future<Map<String, String>> getAttributionParams() async {
    final result = await _channel.invokeMapMethod<dynamic, dynamic>(
      'getAttributionParams',
    );

    return result == null
        ? <String, String>{}
        : Map<String, String>.from(result);
  }

  Future<void> track(
    AdbackStandardEvent event, {
    Map<String, Object> properties = const <String, Object>{},
    AdbackUser user = const AdbackUser(),
  }) {
    _validateProperties(properties);

    return _channel.invokeMethod<void>('track', <String, Object?>{
      'eventName': event.wireName,
      'properties': properties,
      'user': user.toMap(),
    });
  }

  Future<void> flush() {
    return _channel.invokeMethod<void>('flush');
  }

  Future<void> reset() {
    return _channel.invokeMethod<void>('reset');
  }

  void _validateProperties(Map<String, Object> properties) {
    for (final entry in properties.entries) {
      if (_identityPropertyKeys.contains(entry.key.toLowerCase())) {
        throw ArgumentError(
          '${entry.key} must be sent through dedicated identity fields, not properties.',
        );
      }

      final value = entry.value;
      if (value is! bool && value is! num && value is! String) {
        throw ArgumentError('Unsupported Adback property value for ${entry.key}.');
      }
    }
  }
}

const Set<String> _identityPropertyKeys = <String>{
  'ad_services_token',
  'ad_services_token_present',
  'adback_id',
  'appstack_id',
  'asa_token',
  'customer_user_id',
  'date_of_birth',
  'dob',
  'email',
  'external_id',
  'first_name',
  'idfa',
  'idfv',
  'install_id',
  'last_name',
  'phone',
  'phone_number',
  'transaction',
  'transaction_details',
  'user_id',
};
