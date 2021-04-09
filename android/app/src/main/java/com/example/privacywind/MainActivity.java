package com.example.privacywind;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.privacywind.data.MyDbHandler;
import com.example.privacywind.manager.SharedPreferenceManager;
import com.example.privacywind.model.Record;
import com.example.privacywind.services.MonitorService;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.example.test_permissions_app/permissions";
    private SharedPreferenceManager sharedPreferenceManager;
    MyDbHandler dbHandler;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        sharedPreferenceManager = SharedPreferenceManager.getInstance(this);
        dbHandler = new MyDbHandler(this);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel("monitor", "AppMonitor", NotificationManager.IMPORTANCE_LOW);
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }

        new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {

            PackageManager packageManager = getPackageManager();
            HashMap<String, List<String>> permissionsForApp = new HashMap<>();

            String executeFunctionType = call.method;

            switch (executeFunctionType) {
                case "getAppPermission": {
                    final String packageName = call.arguments();
                    try {
                        PackageInfo packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS);

                        if (packageInfo.requestedPermissions != null) {
                            String[] permissionList = packageInfo.requestedPermissions;

                            int[] permissionCodeInt = packageInfo.requestedPermissionsFlags;
                            String[] permissionCode = new String[permissionCodeInt.length];
                            for (int i = 0; i < permissionCodeInt.length; i++) {
                                permissionCode[i] = String.valueOf(permissionCodeInt[i]);
                            }

                            permissionsForApp.put("permission_list", Arrays.asList(permissionList));
                            permissionsForApp.put("permission_code", Arrays.asList(permissionCode));

                            result.success(permissionsForApp);
                        }
                    } catch (Exception e) {
                        Log.i("ERROR ==>", e.getMessage());
                        result.error("-1", "Error", "Error in fetching permissions for the particular package");
                    }
                    break;
                }
                case "openAppInfo": {
                    final String packageName = call.arguments();
                    try {
                        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                        intent.setData(Uri.parse("package:" + packageName));
                        startActivity(intent);
                        result.success("SUCCESS");
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                        result.error("-1", "Error", "Error in opening app info settings for the particular package");
                    }
                    break;
                }

                case "checkAccessibilityEnabled": {
                    try {
                        result.success(checkAccessibilityEnabled());
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                    break;
                }
                case "openAccessibilitySettings": {
                    try {
                        openAccessibilitySettings();
                        result.success("done");
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                    break;
                }
                case "setSharedPref": {
                    try {
                        sharedPreferenceManager.setServiceState(checkAccessibilityEnabled());
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                }
                case "isServiceRunning": {
                    try {
                        boolean val = isServiceRunning();
                        result.success(val);
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                    break;
                }
                case "addAppToWatchList": {
                    try {
                        final String packageName = call.arguments();
                        sharedPreferenceManager.addAppToWatchList(packageName);
                        result.success("DONE");
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                    break;
                }
                case "getAppWatchList": {
                    try {
                        Set<String> res = sharedPreferenceManager.getAppWatchList();
                        ArrayList<String> watchList = new ArrayList<>();
                        if (res != null) {
                            watchList.addAll(res);
                        }
                        result.success(watchList);
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                    break;
                }
                case "removeAppFromWatchList": {
                    try {
                        final String packageName = call.arguments();
                        sharedPreferenceManager.removeAppFromWatchList(packageName);
                        result.success("DONE");
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                    break;
                }
                case "setAccessibilityInfoDialogSeen": {
                    try {
                        sharedPreferenceManager.setShowAccessibilityDialogStatus();
                        result.success("DONE");
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                    break;
                }
                case "getAccessibilityInfoDialogSeen": {
                    try {
                        boolean res = sharedPreferenceManager.getShowAccessibilityDialogStatus();
                        result.success(res);
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                    break;
                }
                case "setUserOnboardingInfo": {
                    try {
                        sharedPreferenceManager.setHasUserSeenOnboardingStatus();
                        result.success("DONE");
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                    break;
                }
                case "getUserOnboardingInfo": {
                    try {
                        boolean res = sharedPreferenceManager.getHasUserSeenOnboardingStatus();
                        result.success(res);
                    } catch (Exception e) {
                        Log.i("ERROR", e.getMessage());
                    }
                    break;
                }
                case "getAllLogsForApp": {
                    final String appName = call.arguments();
                    try {
                        List<Record> res = dbHandler.getRecordsForApp(appName);
                        Map<Integer, Map<String, String>> resultMap = new HashMap<>();
                        for (int i = 0; i < res.size(); i++) {
                            Map<String, String> temp = new HashMap<>();
                            temp.put("appName", res.get(i).getAppName());
                            temp.put("permissionUsed", res.get(i).getPermissionUsed());
                            temp.put("permissionAllowed", String.valueOf(res.get(i).getPermissionAllowed()));
                            temp.put("startTime", res.get(i).getStartTime());
                            temp.put("endTime", res.get(i).getEndTime());
                            resultMap.put(i, temp);
                        }
                        result.success(resultMap);
                    } catch (Exception e) {
                        Log.i("ERROR ==>", e.getMessage());
                    }
                    break;
                }
                case "clearLogsForApp": {
                    final String appName = call.arguments();
                    try {
                        dbHandler.deleteRecord(appName);
                        result.success("CLEAR DONE");
                    } catch (Exception e) {
                        Log.i("ERROR ==>", e.getMessage());
                    }
                    break;
                }
                case "clearOldLogs": {
                    try {
                        dbHandler.deleteRecordsOld();
                        result.success("CLEAR DONE");
                    } catch (Exception e) {
                        Log.i("ERROR ==>", e.getMessage());
                    }
                    break;
                }
                case "shareAllLogs": {
                    try {
                        List<Record> res = dbHandler.getAllRecords();
                        boolean retVal = shareRecords(res);
                        result.success(retVal);
                    } catch (Exception e) {
                        Log.i("ERROR ==>", e.getMessage());
                    }
                    break;
                }
            }
        });
    }

    // TODO : Complete this method to share logs to the developers
    public boolean shareRecords(List<Record> records) {
        try {

            return true;
        } catch (Exception e) {
            Log.i("ERROR", e.getMessage());
            return false;
        }
    }

    public boolean checkAccessibilityEnabled() {
        return isAccessibilityEnabled(getApplicationContext());
    }

    private void openAccessibilitySettings() {
        Intent intent = new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS);
        startActivity(intent);
    }

    private boolean isServiceRunning() {
        return sharedPreferenceManager.getServiceState();
    }

    public boolean isAccessibilityEnabled(Context context) {
        String logTag = "ACCESSIBILITY_ERROR";
        int accessibilityEnabled = 0;
        final String ACCESSIBILITY_SERVICE = context.getPackageName() + "/" + MonitorService.class.getCanonicalName();
        try {
            accessibilityEnabled = Settings.Secure.getInt(getActivity().getContentResolver(), android.provider.Settings.Secure.ACCESSIBILITY_ENABLED);
        } catch (Settings.SettingNotFoundException e) {
            Log.d(logTag, "Error finding setting, default accessibility to not found: " + e.getMessage());
        }

        TextUtils.SimpleStringSplitter mStringColonSplitter = new TextUtils.SimpleStringSplitter(':');

        if (accessibilityEnabled == 1) {
            String settingValue = Settings.Secure.getString(getActivity().getContentResolver(), Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES);
            Log.d(logTag, "Setting: " + settingValue);
            if (settingValue != null) {
                mStringColonSplitter.setString(settingValue);
                while (mStringColonSplitter.hasNext()) {
                    String accessibilityService = mStringColonSplitter.next();
                    if (accessibilityService.equalsIgnoreCase(ACCESSIBILITY_SERVICE)) {
                        return true;
                    }
                }
            }
        } else {
            Log.d(logTag, "***ACCESSIBILITY IS DISABLED***");
        }
        return false;
    }
}
