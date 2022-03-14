package com.krisx.time_management.time_management;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.engine.FlutterEngine;
import androidx.annotation.NonNull;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private Intent forService;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        forService = new Intent(MainActivity.this,MyService.class);

    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.krisx.time_management")
                .setMethodCallHandler((call, result) -> {
                    if(call.method.equals("startService")){
                        startService();
                        result.success("Service Started");
                    }
                });
    }

    private void startService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            startForegroundService(forService);
        } else {
            startService(forService);
        }
    }
}
