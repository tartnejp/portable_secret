package com.example.portable_sec

import android.nfc.NfcAdapter
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.toolart.portablesec/nfc"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getLaunchNdefMessage") {
                result.success(getLaunchNdefMessageMap())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getLaunchNdefMessageMap(): Map<String, Any>? {
        val intent = intent ?: return null
        if (NfcAdapter.ACTION_NDEF_DISCOVERED == intent.action) {
            val rawMessages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES, android.nfc.NdefMessage::class.java)
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
