package com.example.nfc_toolkit

import android.app.Activity
import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.NdefMessage
import android.os.Build
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** NfcToolkitPlugin */
class NfcToolkitPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.NewIntentListener {
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.nfc_toolkit/nfc")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getLaunchNdefMessage") {
      result.success(getLaunchNdefMessageMap())
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // --- ActivityAware ---

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addOnNewIntentListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addOnNewIntentListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  // --- NewIntentListener ---

  override fun onNewIntent(intent: Intent): Boolean {
    // Update the activity's intent so that 'getLaunchNdefMessage' returns the latest one
    // if called after a new intent arrives (e.g. while app is in background and brought to front)
    activity?.intent = intent
    return false // Allow other listeners to handle it too
  }

  // --- Logic ---

  private fun getLaunchNdefMessageMap(): Map<String, Any>? {
    val currentActivity = activity ?: return null
    val intent = currentActivity.intent ?: return null
    
    if (NfcAdapter.ACTION_NDEF_DISCOVERED == intent.action) {
      val rawMessages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES, NdefMessage::class.java)
      } else {
        @Suppress("DEPRECATION")
        intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)
      }
      
      if (rawMessages != null && rawMessages.isNotEmpty()) {
        val message = rawMessages[0] as NdefMessage
        val records = message.records.map { record ->
          mapOf(
            "typeNameFormat" to record.tnf,
            "type" to record.type,
            "identifier" to record.id,
            "payload" to record.payload
          )
        }
        return mapOf("records" to records)
      }
    }
    return null
  }
}
