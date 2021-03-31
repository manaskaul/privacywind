package com.example.privacywind.data;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.telecom.Call;
import android.util.Log;

import com.example.privacywind.model.Record;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import static android.util.Log.println;

public class MyDbHandler extends SQLiteOpenHelper {

    public static final int DB_VERSION = 1;
    public static final String DB_NAME = "records_db";
    public static final String TABLE_NAME = "records_table";

    public static final String KEY_ID = "id";
    public static final String KEY_APP_NAME = "app_name";
    public static final String KEY_PERMISSION_USED = "permission_used";
    public static final String KEY_PERMISSION_ALLOWED = "permission_allowed";
    public static final String KEY_START_TIME = "start_time";
    public static final String KEY_END_TIME = "end_time";

    public MyDbHandler(Context context) {
        super(context, DB_NAME, null, DB_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        String create = "CREATE TABLE " + TABLE_NAME + "("
                + KEY_ID + " INTEGER PRIMARY KEY ,"
                + KEY_APP_NAME + " TEXT,"
                + KEY_PERMISSION_USED + " TEXT,"
                + KEY_PERMISSION_ALLOWED + " INTEGER,"
                + KEY_START_TIME + " INTEGER,"
                + KEY_END_TIME + " INTEGER" + ")";
        Log.d("dbtest", "Query being run is : " + create);
        db.execSQL(create);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }

    public void addRecord(Record record) {

        Log.d("add called", record.getAppName());
        SQLiteDatabase db = this.getWritableDatabase();

        ContentValues values = new ContentValues();
        values.put(KEY_APP_NAME, record.getAppName());
        values.put(KEY_PERMISSION_USED, record.getPermissionUsed());
        values.put(KEY_PERMISSION_ALLOWED, record.getPermissionAllowed());
        values.put(KEY_START_TIME, convertDate(record.getStartTime()));
        values.put(KEY_END_TIME, convertDate(record.getEndTime()));

        db.insert(TABLE_NAME, null, values);
        Log.d("dbtest", "Successfully inserted");

        List<Record> recordList = getAllRecords();
        Log.d("data", String.valueOf(recordList.size()));
        for(Record recordItem : recordList){

            String txt = "Name - " + recordItem.getAppName() +
                    "  PermissionUsed - "+ recordItem.getPermissionUsed() +
                    "  StartTime - "+recordItem.getStartTime() +
                    "  EndTime - "+recordItem.getEndTime();

            Log.d("data", txt);
        }

        db.close();
    }

    public List<Record> getAllRecords() {
        List<Record> recordList = new ArrayList<>();
        SQLiteDatabase db = this.getReadableDatabase();

        // Generate the query to read from the database
        String select = "SELECT * FROM " + TABLE_NAME;
        Cursor cursor = db.rawQuery(select, null);

        //Loop through now
        if (cursor.moveToLast()) {
            do {
                Record record = new Record();
                record.setId(Integer.parseInt(cursor.getString(0)));
                record.setAppName(cursor.getString(1));
                record.setPermissionUsed(cursor.getString(2));
                record.setPermissionAllowed(cursor.getInt(3));
                record.setStartTime(getDate(cursor.getLong(4)));
                record.setEndTime(getDate(cursor.getLong(5)));

                recordList.add(record);
            } while (cursor.moveToPrevious());
        }

        return recordList;
    }

    public void deleteRecordsOld() {
        int day = 7;
        SQLiteDatabase db = this.getWritableDatabase();

        db.delete(TABLE_NAME, KEY_END_TIME + " <= " + (Calendar.getInstance().getTimeInMillis() - day * 24 * 60 * 60 * 1000), null);

        db.close();
    }

    public void deleteRecord(String appName){
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_NAME, KEY_APP_NAME + "=?", new String [] {appName});
        db.close();
    }

    public void deleteRecordsAll(){
        SQLiteDatabase db = this.getWritableDatabase();
        db.execSQL("delete from " + TABLE_NAME);
        db.close();
    }

    public String getDate(long milliSeconds)
    {
        String dateFormat = "hh:mm a dd-MM-yyyy";
        SimpleDateFormat formatter = new SimpleDateFormat(dateFormat);

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(milliSeconds);
        return formatter.format(calendar.getTime());
    }

    public long convertDate(String date)
    {
        String dateFormat = "hh:mm a dd-MM-yyyy";
        SimpleDateFormat formatter = new SimpleDateFormat(dateFormat);
        long milliSeconds = 0;

        try {
            Date date_object = formatter.parse(date);
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(date_object);

            milliSeconds = calendar.getTimeInMillis();
        } catch (ParseException e) {
            e.printStackTrace();
        }

        return milliSeconds;
    }
}


