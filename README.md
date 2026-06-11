# Adback Flutter SDK

Adback helps mobile apps attribute installs and subscription outcomes back to
paid campaigns.

This package is the Flutter wrapper for the Adback native mobile SDKs. In
`0.1.0`, iOS is backed by the Adback iOS binary SDK. Android builds include a
documented unsupported-platform stub until the native Adback Android SDK is
released.

## Requirements

- Flutter 3.19+
- Dart 3.3+
- iOS 15+
- Xcode 15+
- CocoaPods

## Installation

```yaml
dependencies:
  adback_flutter: ^0.1.0
```

Then run:

```sh
flutter pub get
cd ios && pod install
```

## Initialization

```dart
import 'package:adback_flutter/adback_flutter.dart';

await Adback.instance.configure('adbk_pk_live_...');
```

For development builds:

```dart
await Adback.instance.configure(
  'adbk_pk_test_...',
  options: const AdbackOptions(
    debug: true,
    environment: AdbackEnvironment.development,
    logLevel: AdbackLogLevel.debug,
  ),
);
```

To enable Apple Ads attribution on iOS 14.3+:

```dart
await Adback.instance.enableAppleAdsAttribution();
```

This does not request App Tracking Transparency permission.

## Events

```dart
await Adback.instance.track(AdbackStandardEvent.signUp);
await Adback.instance.track(
  AdbackStandardEvent.startTrial,
  properties: {'plan': 'annual'},
);
```

Use `flush` in debug flows or tests when you need to wait for pending delivery:

```dart
await Adback.instance.flush();
```

## Attribution Handoff

Use Adback attribution values with RevenueCat, Superwall, or your own paywall
targeting:

```dart
final attributes = await Adback.instance.getAttributionParams();
await Purchases.setAttributes(attributes);
await Superwall.shared.setUserAttributes(attributes);

final adbackId = await Adback.instance.getAdbackId();
```

`getAttributionParams()` waits for initial bootstrap if it is still running.
`getAdbackId()` returns `null` until install resolve has completed.

## Android Status

Android is intentionally a compile-time stub in `0.1.0`. Setup and event
methods throw `PlatformException(code: "adback_android_sdk_unavailable")`.
Safe getter methods return empty state:

- `isConfigured()` returns `false`
- `currentConfiguration()` returns `null`
- `getAdbackId()` returns `null`
- `getAttributionParams()` returns `{}`

The Android plugin shape is already present so Android support can land without
changing the Dart API once the native Adback Android SDK is available.

## Privacy

The SDK does not collect IDFA by default, precise location, contacts, photos,
clipboard contents, or installed-app lists. User match data is sent only when
your app passes it explicitly. Purchase and subscription revenue should come
from RevenueCat, Superwall, App Store Server Notifications, or your backend.

## Support

Dashboard: https://console.adback.app
