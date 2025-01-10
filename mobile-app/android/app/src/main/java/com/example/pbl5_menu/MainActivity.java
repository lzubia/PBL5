package com.example.pbl5_menu;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.pbl5_menu/endSession";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onStart() {
        super.onStart();
        // Call startSession when the activity starts, e.g., when app is foregrounded
        MethodChannel channel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL);
        channel.invokeMethod("startSession", null); // Trigger start session method if app is started
    }

    @Override
    protected void onStop() {
        super.onStop();
        // Also call endSession when the activity stops, e.g., when app is backgrounded
        MethodChannel channel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL);
        channel.invokeMethod("endSession", null); // Trigger end session method if app is stopped
    }
}
