import 'package:adback_flutter/adback_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app.adback.flutter/sdk');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);

      switch (call.method) {
        case 'isConfigured':
          return true;
        case 'getAdbackId':
          return 'adback_123';
        case 'getAttributionParams':
          return <String, String>{'adback_id': 'adback_123'};
        case 'currentConfiguration':
          return <String, Object?>{
            'apiKey': 'adbk_pk_live_test',
            'options': <String, Object?>{
              'environment': 'production',
            },
          };
      }

      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('configure sends wrapper metadata', () async {
    await Adback.instance.configure(
      'adbk_pk_test',
      options: const AdbackOptions(environment: AdbackEnvironment.development),
    );

    final arguments = calls.single.arguments as Map<dynamic, dynamic>;
    final options = arguments['options'] as Map<dynamic, dynamic>;

    expect(arguments['apiKey'], 'adbk_pk_test');
    expect(options['environment'], 'development');
    expect(options['wrapperName'], 'flutter');
    expect(options['wrapperVersion'], '0.1.0');
  });

  test('track rejects identity properties', () {
    expect(
      () => Adback.instance.track(
        AdbackStandardEvent.signUp,
        properties: <String, Object>{'email': 'user@example.com'},
      ),
      throwsArgumentError,
    );
  });

  test('track sends standard event properties', () async {
    await Adback.instance.track(
      AdbackStandardEvent.startTrial,
      properties: <String, Object>{'plan': 'annual'},
    );

    final arguments = calls.single.arguments as Map<dynamic, dynamic>;

    expect(arguments['eventName'], 'START_TRIAL');
    expect(arguments['properties'], <String, Object>{'plan': 'annual'});
  });

  test('getAttributionParams returns string map', () async {
    await expectLater(
      Adback.instance.getAttributionParams(),
      completion(<String, String>{'adback_id': 'adback_123'}),
    );
  });
}
