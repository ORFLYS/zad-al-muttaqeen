package com.huda.bag.hqepa

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scheduleAdhanAlarms") {
                val rawTimestamps = call.argument<List<Any>>("timestamps")
                val muezzinName = call.argument<String>("muezzinName") ?: "osama"
                if (rawTimestamps != null) {
                    val timestamps = rawTimestamps.mapNotNull {
                        when (it) {
                            is Long -> it
                            is Int -> it.toLong()
                            is Number -> it.toLong()
                            else -> null
                        }
                    }
                    scheduleNativeAlarms(context, timestamps, muezzinName)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "Timestamps list was null", null)
                }
            } else if (call.method == "cancelAdhanAlarms") {
                cancelNativeAlarms(context)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    companion object {
        private const val CHANNEL = "com.huda.bag.hqepa/adhan_alarm"

        fun scheduleNativeAlarms(context: Context, timestamps: List<Long>, muezzinName: String) {
            cancelNativeAlarms(context)
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

            for ((index, timeMs) in timestamps.withIndex()) {
                if (timeMs <= System.currentTimeMillis()) continue

                val intent = Intent(context, AdhanAudioReceiver::class.java).apply {
                    action = "com.huda.bag.hqepa.ACTION_PLAY_ADHAN"
                    putExtra("ADHAN_ID", index)
                    putExtra("muezzinName", muezzinName)
                }

                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }

                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    2000 + index,
                    intent,
                    flags
                )

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        timeMs,
                        pendingIntent
                    )
                } else {
                    alarmManager.setExact(
                        AlarmManager.RTC_WAKEUP,
                        timeMs,
                        pendingIntent
                    )
                }
            }
        }

        fun cancelNativeAlarms(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            for (i in 0 until 120) {
                val intent = Intent(context, AdhanAudioReceiver::class.java).apply {
                    action = "com.huda.bag.hqepa.ACTION_PLAY_ADHAN"
                }
                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    2000 + i,
                    intent,
                    flags
                )
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
            }
        }
    }
}
