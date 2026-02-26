import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final CloudinaryService instance = CloudinaryService._internal();

  CloudinaryService._internal();

  // Cloudinary Config - Securely loaded from .env
  String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String get uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  String get apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  String get apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery and uploads it to Cloudinary.
  /// Returns the secure URL if successful, or null on failure.
  Future<String?> pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    try {
      final bytes = await pickedFile.readAsBytes();
      
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: pickedFile.name,
          ),
        );

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      
      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        print('Upload Failed: ${response.statusCode} - $responseString');
        return null;
      }
    } catch (e) {
      print('Cloudinary Upload Exception: $e');
      return null;
    }
  }

  /// Deletes an image from Cloudinary using its secure URL.
  Future<bool> deleteImageByUrl(String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.contains('cloudinary.com')) return true;

    try {
      // Extract public_id from the URL
      // Example URL: https://res.cloudinary.com/demo/image/upload/v1234567890/folder_name/image_name.jpg
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the 'upload' segment index
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex + 2 >= pathSegments.length) {
        return false; // Cannot parse
      }

      // the public ID includes everything after the version number (if present), without the extension
      final idSegments = pathSegments.sublist(uploadIndex + 1);
      if (idSegments.isNotEmpty && idSegments[0].startsWith('v') && int.tryParse(idSegments[0].substring(1)) != null) {
        idSegments.removeAt(0); // Removing version tag
      }
      
      String publicId = idSegments.join('/');
      // Remove file extension
      final lastDotIndex = publicId.lastIndexOf('.');
      if (lastDotIndex != -1) {
        publicId = publicId.substring(0, lastDotIndex);
      }

      return await deleteImageByPublicId(publicId);
    } catch (e) {
      print('Cloudinary Exctraction Error: $e');
      return false;
    }
  }

  /// Deletes an image from Cloudinary using its public_id.
  Future<bool> deleteImageByPublicId(String publicId) async {
    if (apiSecret.isEmpty) {
      print('Cannot delete image: API Secret is missing in .env');
      return false;
    }

    try {
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      
      // To generate signature:
      // Signature MUST be generated using the API secret.
      // String to sign: "public_id=my_image&timestamp=1234567890" + API_SECRET
      final stringToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
      
      final bytes = utf8.encode(stringToSign);
      final digest = sha1.convert(bytes);
      final signature = digest.toString();

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');
      final response = await http.post(
        url,
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        return jsonMap['result'] == 'ok';
      } else {
        print('Delete Failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Cloudinary Delete Exception: $e');
      return false;
    }
  }
}
