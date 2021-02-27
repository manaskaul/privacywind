package com.example.privacywind;

import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import org.json.JSONObject;
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

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(getFlutterEngine());


        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @RequiresApi(api = Build.VERSION_CODES.M)
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
                        } catch (PackageManager.NameNotFoundException e) {
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
                        }
                        break;
                    }
                    case "getAppSearchResult": {
                        final String searchTerm = call.arguments();
                        Log.i("DISPLAY", "hii there");
                        Toast.makeText(MainActivity.this, searchTerm, Toast.LENGTH_LONG).show();
                        try {

                            if(searchTerm != "" || searchTerm != null) {
                                Log.i("DISPLAY", "This fun is called");

                                ArrayList<List<String>> mockResultList = new ArrayList<>();
                                mockResultList.add(Arrays.asList("TestApp-0", "AppPackage-0"));
                                mockResultList.add(Arrays.asList("TestApp-1", "AppPackage-1"));
                                mockResultList.add(Arrays.asList("TestApp-2", "AppPackage-2"));
                                mockResultList.add(Arrays.asList("TestApp-3", "AppPackage-3"));
                                mockResultList.add(Arrays.asList("TestApp-4", "AppPackage-4"));
                                mockResultList.add(Arrays.asList("TestApp-5", "AppPackage-5"));
                                mockResultList.add(Arrays.asList("TestApp-6", "AppPackage-6"));
                                mockResultList.add(Arrays.asList("TestApp-7", "AppPackage-7"));
                                mockResultList.add(Arrays.asList("TestApp-8", "AppPackage-8"));
                                mockResultList.add(Arrays.asList("TestApp-9", "AppPackage-9"));

                                String url = "https://permission-api.herokuapp.com/app/search";
                                //String url = "https://jsonplaceholder.typicode.com/posts";
                                StringRequest stringRequest = new StringRequest(Request.Method.GET, url,
                                        new Response.Listener<String>() {
                                            @Override
                                            public void onResponse(String response) {
                                                Log.i("DISPLAY", response);
                                                Toast.makeText(MainActivity.this, "Akash Jain", Toast.LENGTH_LONG).show();
                                            }
                                        },
                                        new Response.ErrorListener() {
                                            @Override
                                            public void onErrorResponse(VolleyError error) {
                                                Toast.makeText(MainActivity.this, error.toString(), Toast.LENGTH_LONG).show();
                                            }
                                        }) {
                                    @Override
                                    protected Map<String, String> getParams() {
                                        Map<String, String> params = new HashMap<String, String>();
                                        params.put("search", searchTerm);

                                        return params;
                                    }
                                };
                                RequestQueue requestQueue = Volley.newRequestQueue(MainActivity.this);
                                requestQueue.add(stringRequest);

                                result.success(mockResultList);
                            }
                        } catch (Exception e) {
                            Log.i("DISPLAY", "I am here");
                            Log.i("ERROR", e.getMessage());
                        }
                    }
                    case "getSearchAppPermissions": {
                        final String packageName = call.arguments();
                        try {
                            // TODO : Write logic to get permissions for app from play API

                            ArrayList<String> mockPermissionList = new ArrayList<>();
                            mockPermissionList.add("Camera");
                            mockPermissionList.add("Microphone");
                            mockPermissionList.add("Phone");
                            mockPermissionList.add("Storage");
                            
                            result.success(mockPermissionList);
                        } catch (Exception e) {
                            Log.i("ERROR", e.getMessage());
                        }
                    }

                }
            }
        });
    }
}
