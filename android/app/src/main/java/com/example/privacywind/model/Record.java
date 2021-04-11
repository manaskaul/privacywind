package com.example.privacywind.model;

public class Record {
    private int id;
    private String appName;
    private String permissionUsed;
    private int permissionAllowed;
    private String startTime;
    private  String endTime;
    private String packageName;

    public Record(int id, String appName, String permissionUsed, int permissionAllowed, String startTime, String endTime, String packageName) {
        this.id = id;
        this.appName = appName;
        this.permissionUsed = permissionUsed;
        this.permissionAllowed = permissionAllowed;
        this.startTime = startTime;
        this.endTime = endTime;
        this.packageName = packageName;
    }

    public Record(String appName, String permissionUsed, int permissionAllowed, String startTime, String endTime, String packageName) {
        this.appName = appName;
        this.permissionUsed = permissionUsed;
        this.permissionAllowed = permissionAllowed;
        this.startTime = startTime;
        this.endTime = endTime;
        this.packageName = packageName;
    }

    public Record() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getAppName() {
        return appName;
    }

    public void setAppName(String appName) {
        this.appName = appName;
    }

    public String getPermissionUsed() {
        return permissionUsed;
    }

    public void setPermissionUsed(String permissionUsed) {
        this.permissionUsed = permissionUsed;
    }

    public int getPermissionAllowed() {
        return permissionAllowed;
    }

    public void setPermissionAllowed(int permissionAllowed) {
        this.permissionAllowed = permissionAllowed;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }
}
