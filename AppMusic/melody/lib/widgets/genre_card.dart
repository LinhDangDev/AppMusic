import 'package:flutter/material.dart';
import 'package:melody/models/genre.dart';

class GenreCard extends StatelessWidget {
  final Genre genre;

  const GenreCard({required this.genre});

  IconData _getGenreIcon(String genreName) {
    switch (genreName.toLowerCase()) {
      case 'pop':
        return Icons.music_note;
      case 'rock':
        return Icons.audiotrack;
      case 'jazz':
        return Icons.piano;
      case 'classical':
        return Icons.queue_music;
      case 'hip hop':
        return Icons.mic;
      default:
        return Icons.album;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            genre.borderColor.withOpacity(0.8),
            genre.borderColor.withOpacity(0.5),
          ],
        ),
      ),
      child: Row(
        children: [
          // Icon container for genre
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Icon(
              _getGenreIcon(genre.name),
              color: Colors.white,
              size: 24,
            ),
          ),
          // Genre name
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                genre.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
