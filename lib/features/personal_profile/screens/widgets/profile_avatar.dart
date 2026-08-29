import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Widget? badge;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 56,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: imageUrl == null ? Colors.white24 : null,
            ),
            child: imageUrl == null
                ? Icon(Icons.person_rounded,
                    color: Colors.white, size: size * 0.5)
                : null,
          ),
          if (badge != null) Positioned(bottom: -2, right: -2, child: badge!),
        ],
      ),
    );
  }
}
