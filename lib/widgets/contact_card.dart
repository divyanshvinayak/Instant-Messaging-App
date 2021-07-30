import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:express/providers/app.dart';

class ContactCard extends StatelessWidget {
  final String user;
  final String name;
  final int color;
  final String? image;

  const ContactCard({
    required this.user,
    required this.name,
    required this.color,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        child: Stack(
          children: [
            image == null
                ? CircleAvatar(
                    maxRadius: 24,
                    backgroundColor: Color(color),
                    child: Text(
                      name
                          .split(' ')
                          .map((e) => e[0].toUpperCase())
                          .take(2)
                          .join(),
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ))
                : CircleAvatar(
                    backgroundImage: Image.file(File(
                            Provider.of<App>(context, listen: false)
                                .getProfilePhotoPath(image!)))
                        .image,
                    maxRadius: 24,
                  ),
          ],
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        user,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }
}
