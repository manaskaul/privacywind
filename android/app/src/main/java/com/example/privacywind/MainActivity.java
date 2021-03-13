package com.example.privacywind;

import android.content.ComponentName;
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

import org.json.JSONObject;

import android.view.accessibility.AccessibilityManager;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.example.privacywind.manager.SharedPreferenceManager;
import com.example.privacywind.services.monitorService;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
                        }
                        catch (Exception e) {
                            Log.i("ERROR", e.getMessage());
                        }
                        break;
                    }
                    case "startMonitorService": {
                        try {
                            boolean res = startService();
                            result.success(res);
                        } catch (Exception e) {
                            Log.i("ERROR", e.getMessage());
                        }
                        break;
                    }
                    case "stopMonitorService": {
                        try {
                            boolean res = stopService();
                            result.success(res);
                        } catch (Exception e) {
                            Log.i("ERROR", e.getMessage());
                        }
                        break;
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

    private boolean startService() {
        try {
            sharedPreferenceManager.setServiceState(true);
            startService(new Intent(MainActivity.this, monitorService.class));
            return true;
        }
        catch (Exception e) {
            Log.i("ERROR", e.getMessage());
            return false;
        }
    }

    private boolean stopService() {
        try {
            sharedPreferenceManager.setServiceState(false);
            stopService(new Intent(MainActivity.this, monitorService.class));
            return false;
        }
        catch (Exception e) {
            Log.i("ERROR", e.getMessage());
            return true;
        }
    }

    private boolean checkAccessibilityEnabled() {
        return accessibilityPermission(getApplicationContext(), monitorService.class);
    }

    private void openAccessibilitySettings() {
        Intent intent = new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS);
        startActivity(intent);
    }

    public static boolean accessibilityPermission(Context context, Class<?> cls) {
        ComponentName componentName = new ComponentName(context, cls);
        String string = Settings.Secure.getString(context.getContentResolver(), "enabled_accessibility_services");
        if (string == null) {
            return false;
        }
        TextUtils.SimpleStringSplitter simpleStringSplitter = new TextUtils.SimpleStringSplitter(':');
        simpleStringSplitter.setString(string);
        while (simpleStringSplitter.hasNext()) {
            ComponentName unflattenFromString = ComponentName.unflattenFromString(simpleStringSplitter.next());
            if (unflattenFromString != null && unflattenFromString.equals(componentName)) {
                return true;
            }
        }
        return false;
    }

    private boolean isServiceRunning() {
        return sharedPreferenceManager.isServiceEnabled();
    }
}
