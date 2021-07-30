import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:express/providers/app.dart';
import 'package:express/models/message.dart';
import 'package:express/widgets/time_ago.dart';
import 'package:express/widgets/typing_indicator.dart';

class ConversationList extends StatelessWidget {
  final String user;
  final String name;
  final Message lastMessage;
  final int color;
  final String? image;

  const ConversationList({
    required this.user,
    required this.name,
    required this.lastMessage,
    required this.color,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final String id = Provider.of<App>(context, listen: false)
        .preferencesBox
        .getAt(0)!
        .authUser!
        .id;
    final bool showTypingIndicator =
        Provider.of<App>(context).isTyping.containsKey(user);
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 11, top: 11),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                image == null
                    ? CircleAvatar(
                        maxRadius: 25,
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
                        maxRadius: 25,
                      ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        showTypingIndicator
                            ? Container(
                                height: 16,
                                child: TypingIndicator(
                                  left: -8,
                                  bottom: -1,
                                  width: 64,
                                  height: 16,
                                  diameter: 10,
                                  padding: const EdgeInsets.all(0),
                                  showTypingIndicator: showTypingIndicator,
                                  bubbleColor: const Color(0xFFffffff),
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width - 130,
                                height: 16,
                                child: lastMessage.content == ''
                                    ? Text(
                                        lastMessage.sender == id
                                            ? 'You deleted this message.'
                                            : 'This message was deleted.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                    : Text(
                                        lastMessage.content
                                            .replaceAll('\n', ' '),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: lastMessage.readDate ==
                                                      null &&
                                                  lastMessage.receiver == id &&
                                                  lastMessage.sender !=
                                                      lastMessage.receiver
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            TimeAgo.timeAgoSinceDate(lastMessage.date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: lastMessage.readDate == null &&
                      lastMessage.receiver == id &&
                      lastMessage.content != '' &&
                      lastMessage.sender != lastMessage.receiver
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
