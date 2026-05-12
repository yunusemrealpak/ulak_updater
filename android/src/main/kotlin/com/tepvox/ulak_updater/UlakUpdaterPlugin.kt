package com.tepvox.ulak_updater

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

class UlakUpdaterPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var appContext: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "tepvox.ulak/installer")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        appContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val ctx = appContext
        if (ctx == null) {
            result.error("no_context", "plugin not attached", null)
            return
        }
        when (call.method) {
            "canInstall"               -> handleCanInstall(ctx, result)
            "requestInstallPermission" -> handleRequestInstall(ctx, result)
            "installApk"               -> handleInstallApk(ctx, call, result)
            else                       -> result.notImplemented()
        }
    }

    private fun handleCanInstall(ctx: Context, result: Result) {
        val canInstall = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            ctx.packageManager.canRequestPackageInstalls()
        } else {
            true
        }
        result.success(canInstall)
    }

    private fun handleRequestInstall(ctx: Context, result: Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                    data = Uri.parse("package:" + ctx.packageName)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                (activity ?: ctx).startActivity(intent)
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("settings_failed", e.message, null)
        }
    }

    private fun handleInstallApk(ctx: Context, call: MethodCall, result: Result) {
        val path = call.argument<String>("path")
        if (path.isNullOrEmpty()) {
            result.error("bad_args", "missing 'path'", null)
            return
        }
        try {
            val file = File(path)
            if (!file.exists()) {
                result.error("file_missing", "APK not found at $path", null)
                return
            }
            val authority = ctx.packageName + ".ulakprovider"
            val uri: Uri = FileProvider.getUriForFile(ctx, authority, file)

            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            (activity ?: ctx).startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            result.error("install_failed", e.message, null)
        }
    }
}
