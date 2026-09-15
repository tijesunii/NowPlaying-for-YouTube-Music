import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track_data.dart';

class ApiService {
  Timer? _pollingTimer;
  String _trackingUrl = '';
  String _remoteUrl = '';
  String _secret = '';

  final Function(TrackData) onTrackUpdate;
  final Function(String) onError;

  ApiService({
    required this.onTrackUpdate,
    required this.onError,
  });

  void updateConfig({
    required String trackingUrl,
    required String remoteUrl,
    required String secret,
  }) {
    _trackingUrl = trackingUrl;
    _remoteUrl = remoteUrl;
    _secret = secret;
    
    if (_trackingUrl.isNotEmpty) {
      _fetchNowPlaying();
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchNowPlaying();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchNowPlaying() async {
    if (_trackingUrl.isEmpty) return;

    try {
      final cacheBusterUrl = '$_trackingUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      
      final uri = Uri.parse(_trackingUrl);
      final referer = '${uri.scheme}://${uri.host}/';

      final response = await http.get(
        Uri.parse(cacheBusterUrl),
        headers: {
          'Referer': referer,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final track = TrackData.fromJson(data);
        onTrackUpdate(track);
      }
    } catch (e) {
    }
  }

  Future<bool> sendCommand(String command) async {
    if (_remoteUrl.isEmpty || _secret.isEmpty) {
      onError("Missing configuration. Please check settings.");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_remoteUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'secret': _secret,
          'command': command,
        }),
      );

      if (response.statusCode == 200) {
        Future.delayed(const Duration(milliseconds: 500), _fetchNowPlaying);
        return true;
      } else {
        onError("Server rejected command: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        onError("Could not reach the server. Please check your internet connection and URL.");
      } else {
        onError("An unexpected network error occurred.");
      }
      return false;
    }
  }
}
