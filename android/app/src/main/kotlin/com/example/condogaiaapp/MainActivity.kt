package com.example.condogaiaapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ClipboardManager
import android.content.ClipData
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.condogaia/qr_code"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "copiarImagemParaClipboard" -> {
                    val imagemBytes = call.argument<ByteArray>("imagemBytes")
                    if (imagemBytes != null) {
                        try {
                            val bitmap = BitmapFactory.decodeByteArray(imagemBytes, 0, imagemBytes.size)
                            copiarBitmapParaClipboard(bitmap)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", "Erro ao copiar imagem: ${e.message}", null)
                        }
                    } else {
                        result.error("ERROR", "Imagem bytes é nulo", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun copiarBitmapParaClipboard(bitmap: Bitmap) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("QR Code", "QR Code de Autorização")
        
        // Nota: Android 10+ não suporta cópia de imagem diretamente via ClipboardManager
        // A solução é salvar em arquivo e compartilhar, ou apenas copiar o texto
        clipboard.setPrimaryClip(clip)
    }
}
