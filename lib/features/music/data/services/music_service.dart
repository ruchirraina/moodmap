import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/music_constants.dart';
import '../../domain/models/music_result.dart';

class MusicService {
  static const String _baseUrl = 'https://itunes.apple.com/search';

  Future<List<MusicResult>> searchSongs(String query) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?term=${Uri.encodeComponent(query)}&entity=song&limit=20',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'MoodMap/1.0.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results
            .map(
              (json) => MusicResult(
                id: json['trackId'].toString(),
                title:
                    json['trackName'] as String? ??
                    MusicConstants.unknownSongText,
                artist:
                    json['artistName'] as String? ??
                    MusicConstants.unknownArtistText,
                coverUrl: json['artworkUrl100'] as String? ?? '',
                previewUrl: json['previewUrl'] as String? ?? '',
              ),
            )
            .where((song) => song.previewUrl.isNotEmpty)
            .toList();
      } else {
        throw Exception(MusicConstants.genericError);
      }
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socket') ||
          errorStr.contains('network') ||
          errorStr.contains('clientexception') ||
          errorStr.contains('failed host lookup')) {
        throw Exception(MusicConstants.networkError);
      }
      throw Exception(MusicConstants.genericError);
    }
  }
}
