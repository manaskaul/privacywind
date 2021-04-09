package com.example.privacywind.services;

import android.Manifest;
import android.accessibilityservice.AccessibilityService;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
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

import com.example.privacywind.data.MyDbHandler;
import com.example.privacywind.model.Record;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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

    private String cameraStartTime;
    private String micStartTime;
    private String locationStartTime;

    Set<String> appList;

    private MyDbHandler db;
    Map<String, Integer> appPermission = new HashMap<>();

    @Override
    protected void onServiceConnected() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "monitor")
                    .setContentText("This is running in Background")
                    .setContentTitle("Flutter Background");
            startForeground(101, builder.build());
        }
        db = new MyDbHandler(this);
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
                getPermissionListForRunningApp(currentRunningAppPackage);
            }
        } catch (Exception e) {
            Log.i("ERROR ~=>", e.getMessage());
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

    private void getPermissionListForRunningApp(String packageName) {
        appPermission.clear();
        PackageManager packageManager = getPackageManager();
        try {
            PackageInfo packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS);
            if (packageInfo.requestedPermissions != null) {
                Log.i("PERMISSIONS =>", "GOT Permission list");
                String[] permissionList = packageInfo.requestedPermissions;
                int[] permissionCode = packageInfo.requestedPermissionsFlags;

                appPermission.put("Camera", isCameraPermissionGranted(permissionList, permissionCode));
                appPermission.put("Location", isLocationPermissionGranted(permissionList, permissionCode));
                appPermission.put("Microphone", isMicrophonePermissionGranted(permissionList, permissionCode));
            }
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
    }

    private int isCameraPermissionGranted(String[] pList, int[] pCode) {
        boolean isPermAvailable = false;
        for (int i = 0; i < pList.length; i++) {
            if ("android.permission.CAMERA".equals(pList[i])) {
                isPermAvailable = true;
                if (pCode[i] == 3) {
                    return 1;
                }
            }
        }
        return isPermAvailable ? 0 : -1;
    }

    private int isLocationPermissionGranted(String[] pList, int[] pCode) {
        boolean isPermAvailable = false;
        for (int i = 0; i < pList.length; i++) {
            switch (pList[i]) {
                case "android.permission.ACCESS_COARSE_LOCATION":
                case "android.permission.ACCESS_FINE_LOCATION":
                case "android.permission.ACCESS_BACKGROUND_LOCATION": {
                    isPermAvailable = true;
                    if (pCode[i] == 3) {
                        return 1;
                    }
                    break;
                }
            }
        }
        return isPermAvailable ? 0 : -1;
    }

    private int isMicrophonePermissionGranted(String[] pList, int[] pCode) {
        boolean isPermAvailable = false;
        for (int i = 0; i < pList.length; i++) {
            switch (pList[i]) {
                case "android.permission.RECORD_AUDIO":
                case "android.permission.CAPTURE_AUDIO_OUTPUT": {
                    isPermAvailable = true;
                    if (pCode[i] == 3) {
                        return 1;
                    }
                    break;
                }
            }
        }
        return isPermAvailable ? 0 : -1;
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

                    Date date = Calendar.getInstance().getTime();
                    DateFormat dateFormat = new SimpleDateFormat("hh:mm a dd-MM-yyyy");
                    cameraStartTime = dateFormat.format(date);

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

                        Date date = Calendar.getInstance().getTime();
                        DateFormat dateFormat = new SimpleDateFormat("hh:mm a dd-MM-yyyy");
                        micStartTime = dateFormat.format(date);

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

                    if (currentRunningAppName != null) {
                        if (appList.contains(currentRunningAppPackage)) {

                            Log.i("EVENT => ", "Location use START");

                            Date date = Calendar.getInstance().getTime();
                            DateFormat dateFormat = new SimpleDateFormat("hh:mm a dd-MM-yyyy");
                            locationStartTime = dateFormat.format(date);

                            Toast.makeText(getApplicationContext(), currentRunningAppName + " has started using location", Toast.LENGTH_SHORT).show();

                        }
                    }
                }

                @Override
                public void onStopped() {
                    super.onStopped();

                    if (currentRunningAppName != null) {
                        if (appList.contains(currentRunningAppPackage)) {

                            Log.i("EVENT => ", "Location use end");

                            Date date = Calendar.getInstance().getTime();
                            DateFormat dateFormat = new SimpleDateFormat("hh:mm a dd-MM-yyyy");
                            String locationEndTime = dateFormat.format(date);

                            Record record = new Record(currentRunningAppName, "Location", getPermissionAllowed("Location"), locationStartTime, locationEndTime);
                            db.addRecord(record);

                            Toast.makeText(getApplicationContext(),currentRunningAppName + " has finished using Location", Toast.LENGTH_SHORT).show();

                        }
                    }
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

            if (currentRunningAppName != null) {
                if (appList.contains(currentRunningAppPackage)) {
                    Toast.makeText(this, currentRunningAppName + " stopped using Camera", Toast.LENGTH_SHORT).show();

                    Date date = Calendar.getInstance().getTime();
                    DateFormat dateFormat = new SimpleDateFormat("hh:mm a dd-MM-yyyy");
                    String cameraEndTime = dateFormat.format(date);

                    Record record = new Record(currentRunningAppName, "Camera", getPermissionAllowed("Camera"), cameraStartTime, cameraEndTime);
                    db.addRecord(record);
                }
            }
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

            if (currentRunningAppName != null) {
                if (appList.contains(currentRunningAppPackage)) {
                    Toast.makeText(this, currentRunningAppName + " stopped using Microphone", Toast.LENGTH_SHORT).show();

                    Date date = Calendar.getInstance().getTime();
                    DateFormat dateFormat = new SimpleDateFormat("hh:mm a dd-MM-yyyy");
                    String micEndTime = dateFormat.format(date);

                    Record record = new Record(currentRunningAppName, "Microphone", getPermissionAllowed("Microphone"), micStartTime, micEndTime);
                    db.addRecord(record);
                }
            }
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

    // getPermissionAllowed => 
    // -1 : permission not requested
    //  0 : permission is off
    //  1 : permission is on
    public int getPermissionAllowed(String permission) {
        return appPermission.get(permission);
    }

    @Override
    public void onDestroy() {
        destroyHardwareCallbacks();
        super.onDestroy();
    }
}
