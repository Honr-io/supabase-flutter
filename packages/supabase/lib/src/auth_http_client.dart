import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthHttpClient extends BaseClient {
  final Client _inner;

  final String _supabaseKey;
  final Future<String?> Function() _getAccessToken;
  final Future<bool> Function()? _isOnline;
  AuthHttpClient(this._supabaseKey, this._inner, this._getAccessToken, this._isOnline);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    bool newTokenNeeded = false;
    if (!request.headers.containsKey('Authorization')) {
      newTokenNeeded = true;
    } else {
      final currentAuthToken = request.headers['Authorization']!.split(' ')[1];
      if (JwtDecoder.isExpired(currentAuthToken)) {
        newTokenNeeded = true;
      } else if (!JwtDecoder.decode(currentAuthToken).containsKey('sub')) {
        newTokenNeeded = true;
      }
    }

    if (newTokenNeeded) {
      String? accessToken = (_isOnline != null && await _isOnline!()) ? await _getAccessToken() : null;
      final authBearer = accessToken ?? _supabaseKey;
      request.headers["Authorization"] = 'Bearer $authBearer';
    }

    request.headers.putIfAbsent("apikey", () => _supabaseKey);
    return _inner.send(request);
  }
}
