class TrackData {
  final String title;
  final String artist;
  final String image;
  final bool isPlaying;

  TrackData({
    required this.title,
    required this.artist,
    required this.image,
    required this.isPlaying,
  });

  String get highResImage {
    return image.replaceAllMapped(RegExp(r'([=\-])w\d+-h\d+'), (match) {
      return '${match.group(1)}w1024-h1024';
    });
  }

  factory TrackData.fromJson(Map<String, dynamic> json) {
    return TrackData(
      title: json['title'] ?? 'Not Playing',
      artist: json['artist'] ?? '',
      image: json['image'] ?? '',
      isPlaying: json['is_playing'] ?? false,
    );
  }

  factory TrackData.empty() {
    return TrackData(
      title: 'Not Playing',
      artist: '',
      image: '',
      isPlaying: false,
    );
  }
}
