import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/api_client.dart';
import '../../config/constants.dart';

/// Carpetas válidas en el backend (`ALLOWED_FOLDERS`).
enum UploadFolder { products, expenses, avatars, logos }

extension UploadFolderName on UploadFolder {
  String get name => switch (this) {
        UploadFolder.products => 'products',
        UploadFolder.expenses => 'expenses',
        UploadFolder.avatars => 'avatars',
        UploadFolder.logos => 'logos',
      };
}

class UploadsService {
  final ApiClient _api;
  UploadsService(this._api);

  /// Sube una imagen y devuelve la URL relativa devuelta por el backend
  /// (ej: `/uploads/products/abc.jpg`). Para mostrarla, concatená con
  /// [absoluteUrl] o [resolveUrl].
  ///
  /// [bytes] son los bytes del archivo. [filename] sólo se usa para inferir
  /// nombre legible — el backend genera un UUID.
  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
    required UploadFolder folder,
    String? mimeType,
  }) async {
    final form = FormData.fromMap({
      'folder': folder.name,
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: mimeType != null
            ? DioMediaType.parse(mimeType)
            : null,
      ),
    });

    final res = await _api.dio.post(
      '/uploads/image',
      data: form,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
    final data = res.data as Map<String, dynamic>;
    return data['url'] as String;
  }
}

/// Convierte una URL relativa (`/uploads/...`) en una URL absoluta usando el
/// origin correcto según plataforma. Si la URL ya es absoluta (http/https),
/// la devuelve tal cual.
String resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  final origin = kIsWeb ? AppConstants.apiOriginWeb : AppConstants.apiOrigin;
  if (url.startsWith('/')) return '$origin$url';
  return '$origin/$url';
}
