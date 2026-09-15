import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/track_data.dart';
import '../services/api_service.dart';
import 'settings_screen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late ApiService _apiService;
  TrackData _currentTrack = TrackData.empty();

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(
      onTrackUpdate: (track) {
        if (mounted) setState(() => _currentTrack = track);
      },
      onError: (msg) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: const Color(0xFFFF0000),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
    );
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService.updateConfig(
      trackingUrl: prefs.getString('trackingApiUrl') ?? '',
      remoteUrl: prefs.getString('remoteApiUrl') ?? '',
      secret: prefs.getString('secretToken') ?? '',
    );
    _apiService.startPolling();
  }

  @override
  void dispose() {
    _apiService.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _currentTrack.image.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.gear_alt_fill, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const SettingsScreen()),
              );
              _loadConfig();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            CachedNetworkImage(
              imageUrl: _currentTrack.highResImage,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const SizedBox(),
            ),
          if (hasImage)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                color: const Color(0xFF030303).withOpacity(0.6),
              ),
            ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: _currentTrack.highResImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: const Color(0xFF1C1C1E)),
                            errorWidget: (context, url, error) => _buildPlaceholderArt(),
                          )
                        : _buildPlaceholderArt(),
                  ),
                ),
                
                const SizedBox(height: 50),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Text(
                        _currentTrack.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentTrack.artist,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlBtn(
                      icon: CupertinoIcons.backward_fill,
                      size: 36,
                      onTap: () => _apiService.sendCommand('prev'),
                    ),
                    _buildControlBtn(
                      icon: _currentTrack.isPlaying 
                          ? CupertinoIcons.pause_fill 
                          : CupertinoIcons.play_fill,
                      size: 56,
                      isPrimary: true,
                      onTap: () => _apiService.sendCommand('play_pause'),
                    ),
                    _buildControlBtn(
                      icon: CupertinoIcons.forward_fill,
                      size: 36,
                      onTap: () => _apiService.sendCommand('next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderArt() {
    return Container(
      color: const Color(0xFF1C1C1E),
      child: const Center(
        child: Icon(
          CupertinoIcons.music_note,
          size: 80,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(isPrimary ? 24 : 16),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFF0000) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }
}
