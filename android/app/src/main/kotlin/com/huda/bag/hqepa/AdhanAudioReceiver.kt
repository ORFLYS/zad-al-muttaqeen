package com.huda.bag.hqepa

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.util.Log

class AdhanAudioReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AdhanAudioReceiver"

        @Volatile
        private var mediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null) return
        Log.d(TAG, "Adhan broadcast received!")

        synchronized(AdhanAudioReceiver::class.java) {
            try {
                // If already playing, stop existing mediaPlayer cleanly to prevent duplicate audio overlaps
                if (mediaPlayer != null) {
                    try {
                        if (mediaPlayer!!.isPlaying) {
                            mediaPlayer!!.stop()
                        }
                    } catch (e: Exception) {
                        Log.w(TAG, "Error stopping existing mediaPlayer: ${e.message}")
                    } finally {
                        mediaPlayer?.release()
                        mediaPlayer = null
                    }
                }

                val muezzinName = intent?.getStringExtra("muezzinName") ?: "osama"
                val rawResId = context.resources.getIdentifier(muezzinName, "raw", context.packageName)
                if (rawResId == 0) {
                    Log.e(TAG, "Resource R.raw.$muezzinName not found in package ${context.packageName}")
                    return
                }

                val audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()

                val player = MediaPlayer.create(context, rawResId, audioAttributes, 0)
                if (player == null) {
                    Log.e(TAG, "Failed to create MediaPlayer for raw resource $rawResId")
                    return
                }

                mediaPlayer = player

                player.setOnCompletionListener { mp ->
                    Log.d(TAG, "Adhan playback completed cleanly.")
                    synchronized(AdhanAudioReceiver::class.java) {
                        try {
                            mp.release()
                        } catch (e: Exception) {
                            Log.w(TAG, "Error releasing mp on completion: ${e.message}")
                        }
                        if (mediaPlayer == mp) {
                            mediaPlayer = null
                        }
                    }
                }

                player.setOnErrorListener { mp, what, extra ->
                    Log.e(TAG, "MediaPlayer error occurred: what=$what, extra=$extra")
                    synchronized(AdhanAudioReceiver::class.java) {
                        try {
                            mp.release()
                        } catch (e: Exception) {
                            Log.w(TAG, "Error releasing mp on error: ${e.message}")
                        }
                        if (mediaPlayer == mp) {
                            mediaPlayer = null
                        }
                    }
                    true
                }

                player.start()
                Log.d(TAG, "Adhan MediaPlayer started successfully!")

            } catch (e: Exception) {
                Log.e(TAG, "Exception during Adhan audio playback: ${e.message}", e)
                try {
                    mediaPlayer?.release()
                } catch (_: Exception) {}
                mediaPlayer = null
            }
        }
    }
}
