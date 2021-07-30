import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:express/models/message.dart';

class ReceiverCard extends StatelessWidget {
  final Message message;

  const ReceiverCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.grey[200],
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 50,
                  top: 10,
                  bottom: 10,
                ),
                child: message.content == ''
                    ? const Text(
                        'This message was deleted.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Text(
                        message.content,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Text(
                  DateFormat.Hm().format(
                    DateTime.parse(message.date)
                        .add(DateTime.now().timeZoneOffset),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
