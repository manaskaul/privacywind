package com.example.privacywind.services;

import android.accessibilityservice.AccessibilityService;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;

import androidx.core.app.NotificationCompat;

public class monitorService extends AccessibilityService {
    @Override
    public void onAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
    }

    @Override
    public void onInterrupt() {
    }

    @Override
    public void onCreate() {
        super.onCreate();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this,"monitor")
                    .setContentText("This is running in Background")
                    .setContentTitle("Flutter Background");

            startForeground(101, builder.build());
        }
    }

    @Override
    protected void onServiceConnected() {
        Log.i("RESULT =>", "Service has connected");
    }

    @Override
    public void onDestroy() {
        Log.i("RESULT =>", "Service has dis-connected");
        super.onDestroy();
    }
}
