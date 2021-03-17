package com.example.privacywind.manager;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.example.privacywind.BuildConfig;

import java.util.HashSet;
import java.util.Set;

public class SharedPreferenceManager {
    
    static final String SHARED_PREFERENCE_NAME = BuildConfig.APPLICATION_ID;
    public static final int ACCESS_MODE = Context.MODE_PRIVATE;

    private static SharedPreferenceManager sharedPreferenceManager;
    private SharedPreferences sharedPreferences;
    private Context context;

    public static SharedPreferenceManager getInstance(Context context) {
        if (sharedPreferenceManager == null) {
            sharedPreferenceManager = new SharedPreferenceManager(context.getApplicationContext());
        }
        return sharedPreferenceManager;
    }

    public SharedPreferenceManager(Context context) {
        this.context = context;
        this.sharedPreferences = context.getSharedPreferences(SHARED_PREFERENCE_NAME, ACCESS_MODE);
    }

    public void setServiceState(boolean value) {
        setBoolean(context, "service_state", value);
    }

    public boolean getServiceState() {
        return getBoolean(context, "service_state", false);
    }

    Set<String> watchList = new HashSet<>();
    public void addAppToWatchList(String packageName) {
        watchList = getAppWatchList();
        watchList.add(packageName);
        setStringSet(context, "watch_list", watchList);
    }

    public Set<String> getAppWatchList() {
        return getStringSet(context, "watch_list", watchList);
    }

    public void removeAppFromWatchList(String packageName) {
        watchList = getAppWatchList();
        try {
            watchList.remove(packageName);
        }
        catch (Exception e) {
            Log.i("ERROR =>", "app is not in the list");
        }
        setStringSet(context, "watch_list", watchList);
    }

    // Getters and Setters
    public void setString(Context context, String key, String value) {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(key, value);
        editor.apply();
    }

    public String getString(Context context, String key, String def_value) {
        return sharedPreferences.getString(key, def_value);
    }

    public void setInteger(Context context, String key, int value) {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(key, value);
        editor.apply();
    }

    public int getInteger(Context context, String key, int def_value) {
        return sharedPreferences.getInt(key, def_value);
    }

    public void setBoolean(Context context, String key, boolean value) {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(key, value);
        editor.apply();
    }

    public boolean getBoolean(Context context, String key, boolean def_value) {
        return sharedPreferences.getBoolean(key, def_value);
    }

    public void setStringSet(Context context, String key, Set<String> value) {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putStringSet(key, value);
        editor.apply();
    }

    public Set<String> getStringSet(Context context, String key, Set<String> defaultVal) {
        return sharedPreferences.getStringSet(key, defaultVal);
    }
}
