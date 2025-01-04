import 'package:flutter/material.dart';
import 'package:melody/models/genre.dart';

class GenreCard extends StatelessWidget {
  final Genre genre;

  const GenreCard({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: 180,
      decoration: BoxDecoration(
        color: Color(0xFF282828),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(
            color: genre.borderColor,
            width: 4,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                genre.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 