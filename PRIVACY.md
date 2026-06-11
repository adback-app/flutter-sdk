# Adback Flutter SDK Privacy Notes

This wrapper follows the native Adback mobile SDK privacy boundary.

- No IDFA collection by default.
- No precise location, contacts, photos, clipboard contents, or installed-app
  list collection.
- User match data is sent only when the app developer passes it explicitly.
- Apple AdServices tokens are sent only when Apple Ads attribution is enabled
  and only on the install resolve path.
- SDK purchase/subscription revenue, StoreKit capture, transactions, and
  `transaction_details` are out of MVP.

Android support is a compile-time unsupported-platform stub in `0.1.0`.
