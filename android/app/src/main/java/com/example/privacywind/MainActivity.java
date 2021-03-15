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

import com.example.privacywind.manager.SharedPreferenceManager;
import com.example.privacywind.services.monitorService;


import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.example.test_permissions_app/permissions";
    private SharedPreferenceManager sharedPreferenceManager;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(getFlutterEngine());

        sharedPreferenceManager = SharedPreferenceManager.getInstance(this);

//        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
//            NotificationChannel channel = new NotificationChannel("monitor","AppMonitor", NotificationManager.IMPORTANCE_LOW);
//            NotificationManager manager = getSystemService(NotificationManager.class);
//            manager.createNotificationChannel(channel);
//        }

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

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
                        }
                        catch (Exception e) {
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
                }
            }
        });
    }

    public boolean checkAccessibilityEnabled() {
        return isAccessibilityEnabled(getApplicationContext());
    }

    private void openAccessibilitySettings() {
        Intent intent = new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS);
        startActivity(intent);
    }

    private boolean isServiceRunning() {
        return sharedPreferenceManager.isServiceEnabled();
    }

    public boolean isAccessibilityEnabled(Context context) {
        String LOGTAG = "ACCESSIBILITY_ERROR";
        int accessibilityEnabled = 0;
        final String ACCESSIBILITY_SERVICE = context.getPackageName() + "/" + monitorService.class.getCanonicalName();
        boolean accessibilityFound = false;
        try {
            accessibilityEnabled = Settings.Secure.getInt(getActivity().getContentResolver(), android.provider.Settings.Secure.ACCESSIBILITY_ENABLED);
        } catch (Settings.SettingNotFoundException e) {
            Log.d(LOGTAG, "Error finding setting, default accessibility to not found: " + e.getMessage());
        }

        TextUtils.SimpleStringSplitter mStringColonSplitter = new TextUtils.SimpleStringSplitter(':');

        if (accessibilityEnabled == 1) {

            String settingValue = Settings.Secure.getString(getActivity().getContentResolver(), Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES);
            Log.d(LOGTAG, "Setting: " + settingValue);
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
            Log.d(LOGTAG, "***ACCESSIBILITY IS DISABLED***");
        }
        return accessibilityFound;
    }
}
