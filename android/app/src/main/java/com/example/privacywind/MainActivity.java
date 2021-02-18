package com.example.privacywind;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(getFlutterEngine());


        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

                final String packageName = call.arguments();
                PackageManager packageManager = getPackageManager();
                HashMap<String, List<String>> permissionsForApp = new HashMap<>();

                if (call.method.equals("getAppPermission")) {
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
                    } catch (PackageManager.NameNotFoundException e) {
                        Log.i("ERROR ==>", e.getMessage());
                        result.error("-1", "Error", "Error in fetching permissions for the particular package");
                    }
                }
            }
        });
    }
}
