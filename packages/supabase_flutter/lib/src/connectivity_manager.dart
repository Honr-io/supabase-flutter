import 'dart:async';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ConnectivityManager extends ChangeNotifier {
  late bool isOnline;
  Timer? _timer;

  Future<void> initAsync() async {
    await checkIfOnline(firstTime: true);
  }

  Future<void> checkIfOnline({bool firstTime = false}) async {
    final newIsOnline = await _isDbAvailable();
    if (!firstTime && newIsOnline == isOnline) return;
    isOnline = newIsOnline;
    if (!isOnline && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        checkIfOnline();
      });
    }
    if (isOnline && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    notifyListeners();
  }

  Future<bool> _isDbAvailable() async {
      final supabaseHost = Uri.parse(Supabase.instance.client.rest.url).host;
      try {
        final pingResult = await Ping(supabaseHost, count: 1).stream.first;
        return pingResult.error == null;
      } catch (_) {
        return false;
      }
  }
}
