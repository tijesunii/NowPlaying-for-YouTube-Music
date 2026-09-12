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

  /// Updates internal configuration and triggers an immediate fetch if valid.
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

  /// Begins a 3-second periodic polling loop to fetch live track data.
  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchNowPlaying();
    });
  }

  /// Stops the polling loop (e.g. when app goes to background).
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Fetches the live JSON from the tracking endpoint.
  Future<void> _fetchNowPlaying() async {
    if (_trackingUrl.isEmpty) return;

    try {
      // Append a cache-buster timestamp just in case the server/ISP caches GET requests
      final cacheBusterUrl = '$_trackingUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      
      // We must spoof the Referer header to match the domain so your .htaccess firewall
      // doesn't block the GET request (since we blocked empty referers earlier).
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
      // Intentionally suppressing periodic network errors to avoid console spam 
      // when the user loses connection or server is briefly unreachable.
    }
  }

  /// Sends a playback command via POST to the remote endpoint.
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
        // Optimistically fetch the new track state immediately after sending command
        Future.delayed(const Duration(milliseconds: 500), _fetchNowPlaying);
        return true;
      } else {
        onError("Server rejected command: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      onError("Network error: $e");
      return false;
    }
  }
}
