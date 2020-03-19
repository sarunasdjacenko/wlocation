package com.sarunasdjacenko.wlocation

import android.os.Bundle

import android.content.Context
import android.content.IntentFilter
import android.net.wifi.WifiManager

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "sarunasdjacenko.com/wlocation"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
    val intentFilter = IntentFilter()
    intentFilter.addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "getWifiResults") {
        result.success(getWifiResults(wifiManager))
      } else {
        result.notImplemented()
      }
    }
  }

  private fun getWifiResults(wifiManager: WifiManager): List<Map<String, Any>> {
    wifiManager.startScan()
    return wifiManager.scanResults.map {
      mapOf(
              "ssid" to it.SSID,
              "bssid" to it.BSSID,
              "frequency" to it.frequency,
              "level" to it.level
      )
    }
  }
}
