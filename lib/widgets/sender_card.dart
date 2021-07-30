import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:express/models/message.dart';

class SenderCard extends StatelessWidget {
  final Message message;

  const SenderCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.indigo,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
          child: Stack(
            children: message.content == ''
                ? [
                    Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 50,
                          top: 10,
                          bottom: 10,
                        ),
                        child: const Text(
                          'You deleted this message.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        )),
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
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ]
                : [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 70,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        message.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 10,
                      child: Row(
                        children: [
                          Text(
                            DateFormat.Hm().format(
                              DateTime.parse(message.date)
                                  .add(DateTime.now().timeZoneOffset),
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          message.refDate == null
                              ? const Icon(
                                  Icons.done,
                                  size: 16,
                                  color: Colors.white70,
                                )
                              : message.readDate == null
                                  ? const Icon(
                                      Icons.done_all,
                                      size: 16,
                                      color: Colors.white70,
                                    )
                                  : const Icon(
                                      Icons.done_all,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                        ],
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
