package app.adback.flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AdbackFlutterPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "app.adback.flutter/sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "isConfigured" -> result.success(false)
      "currentConfiguration" -> result.success(null)
      "getAdbackId" -> result.success(null)
      "getAttributionParams" -> result.success(emptyMap<String, String>())
      "reset" -> result.success(null)
      "configure",
      "enableAppleAdsAttribution",
      "track",
      "flush" -> unsupported(result)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun unsupported(result: Result) {
    result.error(
      "adback_android_sdk_unavailable",
      "The Adback Flutter Android plugin is a compile-time stub until the native Adback Android SDK is released.",
      null
    )
  }
}
