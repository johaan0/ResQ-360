import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class CloudinaryService {
  static const String cloudName = "dfmvvzvzp";
  static const String apiKey = "469745596822797";
  static const String uploadPreset = "volunteer-kyc";
  static const String apiUrl = "https://api.cloudinary.com/v1_1/$cloudName/upload";

  Future<String> uploadFile(File file) async {
    var request = http.MultipartRequest("POST", Uri.parse(apiUrl))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse['secure_url']; // Return the Cloudinary URL
    } else {
      throw Exception("Failed to upload file to Cloudinary");
    }
  }
}
