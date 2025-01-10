import 'package:flutter/material.dart';
import 'package:melody/screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  final String? songTitle;
  final String? artistName;
  final String? imageUrl;
  final bool isPlaying;
  final VoidCallback? onPlayPause;

  const MiniPlayer({
    Key? key,
    this.songTitle,
    this.artistName,
    this.imageUrl,
    this.isPlaying = false,
    this.onPlayPause,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(
            songTitle: songTitle,
            artistName: artistName,
            imageUrl: imageUrl,
            isPlaying: isPlaying,
            onPlayPause: onPlayPause,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
            top: BorderSide(
              color: Colors.grey[800]!,
              width: 0.5,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Album Art
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                imageUrl ?? 'assets/playlist1.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    songTitle ?? 'No song playing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    artistName ?? 'Unknown artist',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: onPlayPause,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 