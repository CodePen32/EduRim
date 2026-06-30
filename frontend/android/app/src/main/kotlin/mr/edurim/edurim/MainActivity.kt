package mr.edurim.edurim

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // FLAG_SECURE: blocks in-app screenshots and screen recording across
        // the whole app, and blanks the app's preview in the Recent Apps
        // switcher. Applied app-wide (not just the video screen) to protect
        // paid lessons, PDFs, and exercises everywhere. NOTE: this cannot
        // stop someone filming the screen with another physical camera.
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE,
        )
    }
}
