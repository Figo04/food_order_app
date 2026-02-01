import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // Ganti dengan credentials dari https://cloudinary.com
  static const String _cloudName = 'dczwjcn2j';
  static const String _uploadPreset = 'food_order';

  static const String _uploadUrl =
      'https://api.cloudinary.com/v3/image/upload';

  final ImagePicker _picker = ImagePicker();

  /// Pick image dari gallery atau kamera
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// Upload image ke Cloudinary dan return secure URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      request.fields['cloud_name'] = _cloudName;
      request.fields['upload_preset'] = _uploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final json = jsonDecode(responseData.body);

      if (response.statusCode == 200) {
        return json['secure_url'];
      }

      throw Exception('Upload failed: ${json['error']?['message']}');
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}