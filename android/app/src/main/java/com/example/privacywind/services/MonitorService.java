package com.example.privacywind.services;

import android.Manifest;
import android.accessibilityservice.AccessibilityService;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.hardware.camera2.CameraManager;
import android.location.GnssStatus;
import android.location.LocationManager;
import android.media.AudioManager;
import android.media.AudioRecordingConfiguration;
import android.os.Build;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.example.privacywind.BuildConfig;
import com.example.privacywind.manager.SharedPreferenceManager;

import java.util.List;
import java.util.Set;

public class MonitorService extends AccessibilityService {

    private CameraManager cameraManager;
    private CameraManager.AvailabilityCallback cameraCallback;
    private AudioManager audioManager;
    private AudioManager.AudioRecordingCallback micCallback;
    private LocationManager locationManager;
    private GnssStatus.Callback locationCallback;

    private boolean isCameraUnavailable = false;
    private boolean isMicUnavailable = false;

    private String currentRunningAppPackage;
    private String currentRunningAppName;

    Set<String> appList;

    @Override
    protected void onServiceConnected() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "monitor")
                    .setContentText("This is running in Background")
                    .setContentTitle("Flutter Background");
            startForeground(101, builder.build());
        }
        initializeHardwareCallbacks();

        SharedPreferenceManager sharedPreferenceManager = SharedPreferenceManager.getInstance(this);
        appList = sharedPreferenceManager.getAppWatchList();
    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        try {
            if (accessibilityEvent.getEventType() == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED && accessibilityEvent.getPackageName() != null) {
                ComponentName componentName = new ComponentName(accessibilityEvent.getPackageName().toString(), accessibilityEvent.getClassName().toString());
                currentRunningAppPackage = componentName.getPackageName();
                currentRunningAppName = getAppNameFromPackageName(this, currentRunningAppPackage);
            }
        } catch (Exception e) {
            Log.i("ERROR =>", e.getMessage());
        }
    }

    private static String getAppNameFromPackageName(Context context, String packageName) {
        final PackageManager packageManager = context.getPackageManager();
        ApplicationInfo applicationInfo;
        try {
            applicationInfo = packageManager.getApplicationInfo(packageName, 0);
        } catch (final PackageManager.NameNotFoundException e) {
            applicationInfo = null;
        }
        return (String) (applicationInfo != null ? packageManager.getApplicationLabel(applicationInfo) : "(unknown)");
    }

    @Override
    public void onInterrupt() {
    }

    private CameraManager.AvailabilityCallback getCameraCallback() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            cameraCallback = new CameraManager.AvailabilityCallback() {
                @Override
                public void onCameraAvailable(@NonNull String cameraId) {
                    super.onCameraAvailable(cameraId);
                    isCameraUnavailable = false;
                    recordCameraAccess();
                }

                @Override
                public void onCameraUnavailable(@NonNull String cameraId) {
                    super.onCameraUnavailable(cameraId);
                    isCameraUnavailable = true;
                    recordCameraAccess();
                }
            };
        }
        return cameraCallback;
    }

    private AudioManager.AudioRecordingCallback getMicCallback() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            micCallback = new AudioManager.AudioRecordingCallback() {
                @Override
                public void onRecordingConfigChanged(List<AudioRecordingConfiguration> configs) {
                    if (configs.size() > 0) {
                        isMicUnavailable = true;
                    } else {
                        isMicUnavailable = false;
                    }
                    recordMicAccess();
                }
            };
        }
        return micCallback;
    }

    private GnssStatus.Callback getLocationCallback(){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            locationCallback = new GnssStatus.Callback() {
                @Override
                public void onStarted() {
                    super.onStarted();
                    Log.i("EVENT => ", "Location use START");
                    Toast.makeText(getApplicationContext(), currentRunningAppName + " has started using location", Toast.LENGTH_SHORT).show();
                }

                @Override
                public void onStopped() {
                    super.onStopped();
                    Log.i("EVENT => ", "Location use end");
                    Toast.makeText(getApplicationContext(),currentRunningAppName + " has finished using Location", Toast.LENGTH_SHORT).show();
                }
            };
        }
        return locationCallback;
    }

    private void initializeHardwareCallbacks() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            cameraManager = (CameraManager) getSystemService(Context.CAMERA_SERVICE);
            cameraManager.registerAvailabilityCallback(getCameraCallback(), null);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
            audioManager.registerAudioRecordingCallback(getMicCallback(), null);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            locationManager = (LocationManager)getSystemService(Context.LOCATION_SERVICE);
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                locationManager.registerGnssStatusCallback(getLocationCallback());
                Log.i("Location callback","now");
            }
        }
    }

    private void recordCameraAccess() {
        if (isCameraUnavailable) {
            Log.i("EVENT => ", "Camera use START");
            if (currentRunningAppName != null) {
                if (appList.contains(currentRunningAppPackage)) {
                    Toast.makeText(this, currentRunningAppName + " is using Camera", Toast.LENGTH_SHORT).show();
                }
            } else {
                Toast.makeText(this, "An app is using Camera", Toast.LENGTH_SHORT).show();
            }
        } else {
            Log.i("EVENT => ", "Camera use STOP");
        }
    }

    private void recordMicAccess() {
        if (isMicUnavailable) {
            Log.i("EVENT => ", "Mic use START");
            if (currentRunningAppName != null) {
                if (appList.contains(currentRunningAppPackage)) {
                    Toast.makeText(this, currentRunningAppName + " is using Microphone", Toast.LENGTH_SHORT).show();
                }
            } else {
                Toast.makeText(this, "An app is using Microphone", Toast.LENGTH_SHORT).show();
            }
        } else {
            Log.i("EVENT => ", "Mic use STOP");
        }
    }

    private void destroyHardwareCallbacks() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (cameraManager != null && cameraCallback != null) {
                cameraManager.unregisterAvailabilityCallback(cameraCallback);
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if (audioManager != null && micCallback != null) {
                audioManager.unregisterAudioRecordingCallback(micCallback);
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if (locationManager != null && locationCallback != null) {
                locationManager.unregisterGnssStatusCallback(locationCallback);
            }
        }
    }


    @Override
    public void onDestroy() {
        destroyHardwareCallbacks();
        super.onDestroy();
    }
}
