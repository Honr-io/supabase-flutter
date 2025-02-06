import 'package:http/http.dart';

class AuthHttpClient extends BaseClient {
  final Client _inner;

  final String _supabaseKey;
  final Future<String?> Function() _getAccessToken;
  final bool Function()? _isOnline;
  AuthHttpClient(this._supabaseKey, this._inner, this._getAccessToken, this._isOnline);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    String? accessToken;
    if (_isOnline == null) {
      accessToken = await _getAccessToken();
    } else {
      accessToken = _isOnline!() ? await _getAccessToken() : null;
    }
    final authBearer = accessToken ?? _supabaseKey;

    request.headers.putIfAbsent("Authorization", () => 'Bearer $authBearer');
    request.headers.putIfAbsent("apikey", () => _supabaseKey);
    return _inner.send(request);
  }
}
