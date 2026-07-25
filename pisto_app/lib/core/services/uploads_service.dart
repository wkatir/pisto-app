import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/api_client.dart';
import '../../config/constants.dart';

/// Valid folders on the backend (`ALLOWED_FOLDERS`).
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

  /// Uploads an image and returns the relative URL returned by the backend
  /// (e.g. `/uploads/products/abc.jpg`). To display it, concatenate with
  /// [absoluteUrl] or [resolveUrl].
  ///
  /// [bytes] is the file's raw bytes. [filename] is only used to infer a
  /// readable name — the backend generates a UUID.
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

/// Converts a relative URL (`/uploads/...`) into an absolute URL. The download
/// route lives under the same basePath `/api/v1` as the rest of the API (and
/// requires the same Bearer token), so it resolves against [apiBaseUrl],
/// not the bare origin.
String resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  final base = kIsWeb ? AppConstants.apiBaseUrlWeb : AppConstants.apiBaseUrl;
  if (url.startsWith('/')) return '$base$url';
  return '$base/$url';
}
