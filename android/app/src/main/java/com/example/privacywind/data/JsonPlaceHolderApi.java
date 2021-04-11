package com.example.privacywind.data;

import org.json.JSONArray;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;

public interface JsonPlaceHolderApi {
    @POST("/api/updateRating")
    Call<JSONArray> postRatingUpdate(@Body JSONArray ratingUpdates);
}
