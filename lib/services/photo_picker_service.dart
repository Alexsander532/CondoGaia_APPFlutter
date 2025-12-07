import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

/// Serviço unificado para seleção de fotos - PhotoPicker Nativo
/// 
/// ✅ Android 13+ (API 33+): image_picker usa PhotoPicker automático (ZERO permissões)
/// ✅ Web: image_picker usa <input type="file"> nativo do navegador
/// ✅ iOS: image_picker usa UIImagePickerController nativo
/// ✅ Câmera: image_picker + CAMERA permission (OK para Google Play)
/// 
/// ❌ Removido: device_info_plus (não precisa verificar SDK)
/// ❌ Removido: READ_MEDIA_IMAGES permission
/// ❌ Removido: MANAGE_EXTERNAL_STORAGE permission
/// ❌ Removido: READ_EXTERNAL_STORAGE permission
/// 
/// Por que image_picker continua?
/// - Fornece tipos essenciais (XFile, ImageSource)
/// - Câmera funciona sem permissões extras
/// - Galeria usa PhotoPicker automático no Android 13+
/// 
/// Uso:
/// ```dart
/// final photoPickerService = PhotoPickerService();
/// final XFile? image = await photoPickerService.pickImage();  // Galeria
/// final XFile? camera = await photoPickerService.pickImageFromCamera();  // Câmera
/// ```
class PhotoPickerService {
  static final PhotoPickerService _instance = PhotoPickerService._internal();

  factory PhotoPickerService() {
    return _instance;
  }

  PhotoPickerService._internal();

  final _imagePicker = ImagePicker();

  /// Selecionar arquivo usando PhotoPicker (Android 13+)
  /// No web, usa input type="file" nativo
  Future<XFile?> _selectImageFromPhotoPicker() async {
    try {
      if (kIsWeb) {
        // Web: usar input nativo
        return await _selectImageFromWebFilePicker();
      } else {
        // Android 13+: usar PhotoPicker nativo
        return await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao selecionar foto: $e');
      return null;
    }
  }

  /// Selecionar arquivo no web usando input nativo
  Future<XFile?> _selectImageFromWebFilePicker() async {
    try {
      debugPrint('🌐 Abrindo file picker web...');
      
      // No web, usar ImagePicker normalmente (ele faz o fallback)
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        debugPrint('✅ Arquivo web selecionado: ${image.name}');
      }
      
      return image;
    } catch (e) {
      debugPrint('❌ Erro ao selecionar foto web: $e');
      return null;
    }
  }

  /// Selecionar uma foto
  /// 
  /// Usa PhotoPicker no Android 13+ (mais seguro, sem permissões)
  /// No web, usa input nativo type="file"
  /// 
  /// Parâmetros:
  /// - maxWidth: largura máxima da imagem (padrão: 800)
  /// - maxHeight: altura máxima da imagem (padrão: 800)
  /// - imageQuality: qualidade da imagem 0-100 (padrão: 85)
  Future<XFile?> pickImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      debugPrint('🎯 Iniciando seleção de foto...');
      
      // Usar PhotoPicker (Android 13+) ou file picker (Web)
      final XFile? image = await _selectImageFromPhotoPicker();

      if (image != null) {
        debugPrint('✅ Foto selecionada');
      }
      
      return image;
    } catch (e) {
      debugPrint('❌ Erro ao selecionar foto: $e');
      return null;
    }
  }

  /// Selecionar múltiplas fotos
  /// 
  /// Usa PhotoPicker no Android 13+
  /// No web, usa input nativo (uma imagem por vez)
  Future<List<XFile>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      debugPrint('🎯 Iniciando seleção de múltiplas fotos...');
      
      if (kIsWeb) {
        // No web, selecionar uma imagem por vez
        debugPrint('⚠️ Web: Selecionando uma imagem por vez');
        final image = await _selectImageFromPhotoPicker();
        return image != null ? [image] : [];
      } else {
        // Android 13+: PhotoPicker com suporte a múltiplas imagens
        final images = await _imagePicker.pickMultiImage(
          maxWidth: maxWidth ?? 800,
          maxHeight: maxHeight ?? 800,
          imageQuality: imageQuality ?? 85,
        );

        debugPrint('✅ ${images.length} fotos selecionadas');
        return images;
      }
    } catch (e) {
      debugPrint('❌ Erro ao selecionar múltiplas fotos: $e');
      return [];
    }
  }

  /// Tirar foto com a câmera
  /// 
  /// Usa PhotoPicker/Câmera nativa
  Future<XFile?> pickImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      debugPrint('📷 Abrindo câmera...');
      
      if (kIsWeb) {
        debugPrint('⚠️ Web não suporta câmera, usando seleção de arquivo');
        return await _selectImageFromWebFilePicker();
      } else {
        // Android 13+: usar câmera com PhotoPicker
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: maxWidth ?? 800,
          maxHeight: maxHeight ?? 800,
          imageQuality: imageQuality ?? 85,
        );

        if (image != null) {
          debugPrint('✅ Foto capturada da câmera');
        }
        
        return image;
      }
    } catch (e) {
      debugPrint('❌ Erro ao tirar foto: $e');
      return null;
    }
  }

  /// Tirar vídeo com a câmera
  /// 
  /// Usa câmera nativa para gravação
  Future<XFile?> pickVideoFromCamera({
    Duration? maxDuration,
  }) async {
    try {
      debugPrint('🎥 Abrindo câmera para vídeo...');
      
      if (kIsWeb) {
        debugPrint('⚠️ Web não suporta câmera para vídeo');
        return null;
      } else {
        // Android 13+: usar câmera nativa para vídeo
        final XFile? video = await _imagePicker.pickVideo(
          source: ImageSource.camera,
          maxDuration: maxDuration,
        );

        if (video != null) {
          debugPrint('✅ Vídeo capturado');
        }
        
        return video;
      }
    } catch (e) {
      debugPrint('❌ Erro ao gravar vídeo: $e');
      return null;
    }
  }

}
