import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Compresión ─────────────────────────────────────────────────────────────

  Future<File> _compressImage(
    File file,
    int targetSizeKB, {
    int minWidth = 800,
    int minHeight = 600,
  }) async {
    final fileName = file.absolute.path;
    final extension = fileName.split('.').last.toLowerCase();
    
    // Si no es jpg/png/webp intentamos devolver tal cual (o convertir a jpg)
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      debugPrint('⚠️ Formato no ideal para comprimir, se usará el original');
      return file;
    }

    // Carpeta temporal
    final outPath = '${fileName.substring(0, fileName.lastIndexOf('.'))}_clamped.jpg';

    int quality = 85; // Calidad inicial
    File? resultFile;
    int currentSizeKB = (await file.length()) ~/ 1024;

    // Si ya pesa menos que el target, igual conviene hacer un resize inicial para estandarizar
    resultFile = File((await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: CompressFormat.jpeg,
    ))?.path ?? file.absolute.path);

    currentSizeKB = (await resultFile.length()) ~/ 1024;

    // Bajar calidad hasta cumplir target, con un limite de quality 30 para no destruir la imagen
    while (currentSizeKB > targetSizeKB && quality > 30) {
      quality -= 10;
      final tempOut = '${fileName.substring(0, fileName.lastIndexOf('.'))}_clamped_$quality.jpg';
      
      final compressed = await FlutterImageCompress.compressAndGetFile(
        resultFile!.absolute.path,
        tempOut,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      
      if (compressed != null) {
        // Borrar el paso anterior
        if (resultFile.path != file.absolute.path) {
          try { await resultFile.delete(); } catch(_) {}
        }
        resultFile = File(compressed.path);
        currentSizeKB = (await resultFile.length()) ~/ 1024;
      } else {
        break; // Fallo la compresion, quedarse con lo q se tenia
      }
    }

    return resultFile ?? file;
  }

  // ── Subidas ───────────────────────────────────────────────────────────────

  /// Sube la foto de perfil comprimida a ≤ 200KB (aprox). Reemplaza foto actual.
  Future<String?> uploadProfileImage(String uid, File image) async {
    try {
      final compressed = await _compressImage(image, 200, minWidth: 400, minHeight: 400);
      final ref = _storage.ref().child('users').child(uid).child('profile.jpg');

      final uploadTask = await ref.putFile(
        compressed,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      return null;
    }
  }

  /// Sube una foto de servicio comprimida a ≤ 500KB (aprox).
  Future<String?> uploadServiceImage(String serviceId, File image, int index) async {
    try {
      final compressed = await _compressImage(image, 500);
      final filename = 'img_${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
      final ref = _storage.ref().child('services').child(serviceId).child(filename);

      final uploadTask = await ref.putFile(
        compressed,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading service photo: $e');
      return null;
    }
  }

  // ── Rollback & Gestión ────────────────────────────────────────────────────

  /// Borra un archivo utilizando su URL de descarga de Storage.
  /// Útil si de repente falla Firestore tras haber subido imágenes exitosamente (Orphans rollback).
  Future<void> deleteImageByUrl(String url) async {
    try {
      if (url.isEmpty || !url.contains('firebasestorage.googleapis.com')) return;
      final ref = _storage.refFromURL(url);
      await ref.delete();
      debugPrint('🗑️ Storage Rollback: Eliminado $url');
    } catch (e) {
      debugPrint('⚠️ Storage Rollback: Podría haber quedado un huérfano. Falló borrar $url -> $e');
    }
  }
}
