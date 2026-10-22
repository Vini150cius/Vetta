// android/app/src/main/kotlin/<SEU/PACOTE>/MainActivity.kt
package com.example.financas_app // PLACEHOLDER: use o seu applicationId

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth exige FlutterFragmentActivity (BiometricPrompt).
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Bloqueia screenshots e a miniatura no "recentes": o saldo não vaza para fora do app.
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    }
}
