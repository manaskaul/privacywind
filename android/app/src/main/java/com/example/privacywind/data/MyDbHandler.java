package com.example.privacywind.data;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;
import android.widget.Toast;

import com.example.privacywind.model.Record;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

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
    public static final String KEY_PACKAGE_NAME = "package_name";

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
                + KEY_END_TIME + " INTEGER,"
                + KEY_PACKAGE_NAME + " TEXT" + ")";
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
        values.put(KEY_PACKAGE_NAME, record.getPackageName());

        db.insert(TABLE_NAME, null, values);
        Log.d("dbtest", "Successfully inserted");

        /*List<Record> recordList = getRecordsForApp("WhatsApp");
        Log.d("data", String.valueOf(recordList.size()));
        for(Record recordItem : recordList){

            String txt = "Name - " + recordItem.getAppName() +
                    "  PermissionUsed - "+ recordItem.getPermissionUsed() +
                    " Permission Allowed - "+ recordItem.getPermissionAllowed() +
                    "  StartTime - "+recordItem.getStartTime() +
                    "  EndTime - "+recordItem.getEndTime();

            Log.d("data", txt);
        }
*/
        db.close();
    }

    public List<Record> getAllRecords() {
        List<Record> recordList = new ArrayList<>();
        SQLiteDatabase db = this.getReadableDatabase();

        // Generate the query to read from the database
        String select = "SELECT * FROM " + TABLE_NAME;
        Cursor cursor = db.rawQuery(select, null);

        if (cursor.moveToLast()) {
            do {
                Record record = new Record();
                record.setId(Integer.parseInt(cursor.getString(0)));
                record.setAppName(cursor.getString(1));
                record.setPermissionUsed(cursor.getString(2));
                record.setPermissionAllowed(cursor.getInt(3));
                record.setStartTime(getDate(cursor.getLong(4)));
                record.setEndTime(getDate(cursor.getLong(5)));
                record.setPackageName(cursor.getString(6));

                recordList.add(record);
            } while (cursor.moveToPrevious());
        }

        return recordList;
    }
    
    public List<Record> getRecordsForApp(String appName) {
        List<Record> recordList = new ArrayList<>();
        SQLiteDatabase db = this.getReadableDatabase();

        // Generate the query to read from the database
        String select = "SELECT * FROM " + TABLE_NAME + " WHERE "+ KEY_APP_NAME + "=?";
        Cursor cursor = db.rawQuery(select, new String [] {appName});

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
                record.setPackageName(cursor.getString(6));

                recordList.add(record);
            } while (cursor.moveToPrevious());
        }

        return recordList;
    }

    public void UpdateRatings(Context context) {
        SQLiteDatabase db = this.getReadableDatabase();

        String select = "SELECT " + KEY_PACKAGE_NAME + ", " + KEY_PERMISSION_USED + ", " + "min("+ KEY_PERMISSION_ALLOWED +") as minval FROM "
                + TABLE_NAME + " group by " +  KEY_PACKAGE_NAME + ", " + KEY_PERMISSION_USED;
        Cursor cursor = db.rawQuery(select, null);

        //Loop through now
        JSONArray jsonArray = new JSONArray();
        if (cursor.moveToLast()) {
            do {
                JSONObject jsonObject = new JSONObject();

                try {
                    jsonObject.put("appID", cursor.getString(0));
                    jsonObject.put("permission", cursor.getString(1));
                    jsonObject.put("coefficient", cursor.getInt(2));

                    jsonArray.put(jsonObject);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

            } while (cursor.moveToPrevious());
        }


        Log.e("JSONArray", String.valueOf(jsonArray));


        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl("https://permission-api.herokuapp.com/")
                .addConverterFactory(GsonConverterFactory.create())
                .build();

        JsonPlaceHolderApi jsonPlaceHolderApi = retrofit.create(JsonPlaceHolderApi.class);

        Call<JSONArray> call = jsonPlaceHolderApi.postRatingUpdate(jsonArray);

        call.enqueue(new Callback<JSONArray>() {
            @Override
            public void onResponse(Call<JSONArray> call, Response<JSONArray> response) {
                Toast.makeText(context, "Thanks for Contribution", Toast.LENGTH_LONG).show();
            }

            @Override
            public void onFailure(Call<JSONArray> call, Throwable t) {
                Toast.makeText(context, "Sorry, some error occurred", Toast.LENGTH_LONG).show();

            }
        });
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


