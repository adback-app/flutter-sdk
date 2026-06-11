import AdbackSDK
import Flutter
import UIKit

public class AdbackFlutterPlugin: NSObject, FlutterPlugin {
  private let wrapperName = "flutter"
  private let wrapperVersion = "0.1.0"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "app.adback.flutter/sdk",
      binaryMessenger: registrar.messenger()
    )
    let instance = AdbackFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "configure":
      configure(call, result: result)
    case "enableAppleAdsAttribution":
      Adback.enableAppleAdsAttribution()
      result(nil)
    case "isConfigured":
      result(Adback.isConfigured())
    case "currentConfiguration":
      result(currentConfiguration())
    case "getAdbackId":
      result(Adback.getAdbackId())
    case "getAttributionParams":
      Task {
        result(await Adback.getAttributionParams() ?? [:])
      }
    case "track":
      track(call, result: result)
    case "flush":
      Task {
        await Adback.flush()
        result(nil)
      }
    case "reset":
      Adback.reset()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func configure(_ call: FlutterMethodCall, result: FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
      let apiKey = arguments["apiKey"] as? String
    else {
      result(
        FlutterError(
          code: "adback_invalid_arguments",
          message: "configure requires apiKey.",
          details: nil
        )
      )
      return
    }

    let options = arguments["options"] as? [String: Any] ?? [:]
    Adback.configure(apiKey: apiKey, options: adbackOptions(from: options))
    result(nil)
  }

  private func track(_ call: FlutterMethodCall, result: FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
      let eventName = arguments["eventName"] as? String,
      let standardEvent = AdbackStandardEvent(rawValue: eventName)
    else {
      result(
        FlutterError(
          code: "adback_invalid_event",
          message: "track requires a supported Adback standard event.",
          details: nil
        )
      )
      return
    }

    do {
      Adback.track(
        standardEvent,
        properties: try propertyValues(from: arguments["properties"] as? [String: Any] ?? [:]),
        user: adbackUser(from: arguments["user"] as? [String: Any] ?? [:])
      )
      result(nil)
    } catch {
      result(
        FlutterError(
          code: "adback_invalid_properties",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }

  private func currentConfiguration() -> [String: Any?]? {
    guard let configuration = Adback.currentConfiguration() else {
      return nil
    }

    return [
      "apiKey": configuration.apiKey,
      "options": optionsDictionary(configuration.options),
    ]
  }

  private func adbackOptions(from dictionary: [String: Any]) -> AdbackOptions {
    AdbackOptions(
      environment: environment(from: dictionary["environment"] as? String),
      apiBaseURL: URL(string: dictionary["apiBaseURL"] as? String ?? "https://api.adback.app")
        ?? URL(string: "https://api.adback.app")!,
      debug: boolValue(dictionary["debug"]) ?? false,
      logLevel: logLevel(from: dictionary["logLevel"] as? String),
      networkEnabled: boolValue(dictionary["networkEnabled"]) ?? true,
      wrapperName: stringValue(dictionary["wrapperName"]) ?? wrapperName,
      wrapperVersion: stringValue(dictionary["wrapperVersion"]) ?? wrapperVersion
    )
  }

  private func optionsDictionary(_ options: AdbackOptions) -> [String: Any?] {
    [
      "apiBaseURL": options.apiBaseURL.absoluteString,
      "debug": options.debug,
      "environment": options.environment.rawValue,
      "logLevel": options.logLevel.rawValue,
      "networkEnabled": options.networkEnabled,
      "wrapperName": options.wrapperName,
      "wrapperVersion": options.wrapperVersion,
    ]
  }

  private func environment(from value: String?) -> AdbackEnvironment {
    value == AdbackEnvironment.development.rawValue ? .development : .production
  }

  private func logLevel(from value: String?) -> AdbackLogLevel {
    switch value {
    case AdbackLogLevel.off.rawValue:
      return .off
    case AdbackLogLevel.warn.rawValue:
      return .warn
    case AdbackLogLevel.info.rawValue:
      return .info
    case AdbackLogLevel.debug.rawValue:
      return .debug
    default:
      return .error
    }
  }

  private func adbackUser(from dictionary: [String: Any]) -> AdbackUser {
    let matchData = dictionary["matchData"] as? [String: Any] ?? [:]

    return AdbackUser(
      customerUserID: stringValue(dictionary["customerUserId"]),
      matchData: AdbackUserMatchData(
        email: stringValue(matchData["email"]),
        phone: stringValue(matchData["phone"]),
        firstName: stringValue(matchData["firstName"]),
        lastName: stringValue(matchData["lastName"]),
        dateOfBirth: stringValue(matchData["dateOfBirth"]),
        externalID: stringValue(matchData["externalId"])
      )
    )
  }

  private func propertyValues(
    from dictionary: [String: Any]
  ) throws -> [String: AdbackPropertyValue] {
    var properties: [String: AdbackPropertyValue] = [:]

    for (key, rawValue) in dictionary {
      if rawValue is NSNull {
        continue
      }

      if let value = rawValue as? String {
        properties[key] = .string(value)
        continue
      }

      if let number = rawValue as? NSNumber {
        if CFGetTypeID(number) == CFBooleanGetTypeID() {
          properties[key] = .bool(number.boolValue)
        } else if number.doubleValue.rounded() == number.doubleValue {
          properties[key] = .int(number.intValue)
        } else {
          properties[key] = .double(number.doubleValue)
        }
        continue
      }

      throw NSError(
        domain: "app.adback.flutter",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unsupported Adback property value for \(key)."]
      )
    }

    return properties
  }

  private func stringValue(_ value: Any?) -> String? {
    guard let value = value as? String else {
      return nil
    }

    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  private func boolValue(_ value: Any?) -> Bool? {
    if let value = value as? Bool {
      return value
    }

    return (value as? NSNumber)?.boolValue
  }
}
