package com.example.kazgeowarningmobile

import io.flutter.embedding.android.FlutterActivity
import android.content.Context
import androidx.multidex.MultiDex

class MainActivity : FlutterActivity() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}

