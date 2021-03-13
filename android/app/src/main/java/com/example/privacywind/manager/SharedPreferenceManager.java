package com.example.privacywind.manager;

import android.content.Context;
import android.content.SharedPreferences;

import com.example.privacywind.BuildConfig;

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
        setBoolean(context, "SERVICE.STATE", value);
    }

    public boolean isServiceEnabled() {
        return getBoolean(context, "SERVICE.STATE", false);
    }

    // Getters and Setters
    public void setString(Context context, String key, String value) {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(key, value);
        editor.apply();
    }

    public String getString(Context context, String key, String def_value) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SHARED_PREFERENCE_NAME, ACCESS_MODE);
        return sharedPreferences.getString(key, def_value);
    }

    public void setInteger(Context context, String key, int value) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SHARED_PREFERENCE_NAME, ACCESS_MODE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(key, value);
        editor.apply();
    }

    public int getInteger(Context context, String key, int def_value) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SHARED_PREFERENCE_NAME, ACCESS_MODE);
        return sharedPreferences.getInt(key, def_value);
    }

    public void setBoolean(Context context, String key, boolean value) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SHARED_PREFERENCE_NAME, ACCESS_MODE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean(key, value);
        editor.apply();
    }

    public boolean getBoolean(Context context, String key, boolean def_value) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SHARED_PREFERENCE_NAME, ACCESS_MODE);
        return sharedPreferences.getBoolean(key, def_value);
    }

}
