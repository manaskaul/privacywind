package com.example.privacywind.model;

public class Record {
    private int id;
    private String appName;
    private String permissionUsed;
    private int permissionAllowed;
    private String startTime;
    private  String endTime;

    public Record(int id, String appName, String permissionUsed, int permissionAllowed, String startTime, String endTime) {
        this.id = id;
        this.appName = appName;
        this.permissionUsed = permissionUsed;
        this.permissionAllowed = permissionAllowed;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public Record(String appName, String permissionUsed, int permissionAllowed, String startTime, String endTime) {
        this.appName = appName;
        this.permissionUsed = permissionUsed;
        this.permissionAllowed = permissionAllowed;
        this.startTime = startTime;
        this.endTime = endTime;
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
}
