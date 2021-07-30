import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:express/providers/app.dart';
import 'package:express/models/user.dart';
import 'package:express/models/message.dart';
import 'package:express/widgets/sender_card.dart';
import 'package:express/widgets/receiver_card.dart';
import 'package:express/widgets/typing_indicator.dart';
import 'package:express/widgets/bottom_sheet_icon.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  const ChatScreen({required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  XFile? _image;
  int _previous = 0;
  bool _show = false;
  bool _send = false;
  Timer _timer = Timer(const Duration(seconds: 0), () {});
  final Set<Message> _selected = {};
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final String _id = Provider.of<App>(context, listen: false)
      .preferencesBox
      .getAt(0)!
      .authUser!
      .id;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _show = false;
        });
      }
    });
    _controller.addListener(() {
      setState(() {
        _send = _controller.text.trim().isNotEmpty;
      });
      if (!_timer.isActive && _controller.text.length > _previous) {
        Provider.of<App>(context, listen: false).isTypingTo(widget.user.id);
        _timer = Timer(const Duration(milliseconds: 2250), () {});
      }
      _previous = _controller.text.length;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selected.isEmpty
          ? AppBar(
              leadingWidth: 80,
              titleSpacing: 0,
              elevation: 0,
              backgroundColor: Colors.white,
              leading:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () {
                    _focusNode.unfocus();
                  },
                  child: widget.user.image == null
                      ? CircleAvatar(
                          maxRadius: 18,
                          backgroundColor: Color(widget.user.color),
                          child: Text(
                            widget.user.name
                                .split(' ')
                                .map((e) => e[0].toUpperCase())
                                .take(2)
                                .join(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ))
                      : CircleAvatar(
                          backgroundImage: Image.file(File(
                                  Provider.of<App>(context, listen: false)
                                      .getProfilePhotoPath(widget.user.image!)))
                              .image,
                          maxRadius: 18,
                        ),
                ),
              ]),
              title: InkWell(
                onTap: () {
                  _focusNode.unfocus();
                },
                child: Container(
                  margin: const EdgeInsets.all(3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                    icon: const Icon(
                      Icons.videocam_outlined,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      _focusNode.unfocus();
                    }),
                IconButton(
                    icon: const Icon(
                      Icons.call_outlined,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      _focusNode.unfocus();
                    }),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) {
                    print(value);
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        child: const Text('View contact'),
                        value: 'View contact',
                      ),
                      const PopupMenuItem(
                        child: const Text('All media'),
                        value: 'All media',
                      ),
                      const PopupMenuItem(
                        child: const Text('Search'),
                        value: 'Search',
                      ),
                      const PopupMenuItem(
                        child: const Text('Mute notifications'),
                        value: 'Mute notifications',
                      ),
                      const PopupMenuItem(
                        child: const Text('Wallpaper'),
                        value: 'Wallpaper',
                      ),
                    ];
                  },
                ),
              ],
            )
          : AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).splashColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _selected.clear();
                  });
                },
              ),
              title: Text(
                '${_selected.length}',
                style: const TextStyle(color: Colors.black87),
              ),
              actions: [
                _selected.length == 1
                    ? IconButton(
                        icon: const Icon(Icons.reply_outlined,
                            color: Colors.black87),
                        onPressed: () {},
                      )
                    : Container(),
                IconButton(
                  icon: const Icon(Icons.star_outline, color: Colors.black87),
                  onPressed: () {},
                ),
                IconButton(
                    icon: const Icon(Icons.delete_outlined,
                        color: Colors.black87),
                    onPressed: () {
                      _showDeleteDialog();
                    }),
                _selected.length > 1 || _selected.first.sender != _id
                    ? IconButton(
                        icon: const Icon(Icons.copy_outlined,
                            color: Colors.black87),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: _selected
                                  .map((message) => message.content)
                                  .join('\n')));
                        })
                    : Container(),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: IconButton(
                    icon:
                        const Icon(Icons.reply_outlined, color: Colors.black87),
                    onPressed: () {},
                  ),
                ),
                _selected.length == 1 && _selected.first.sender == _id
                    ? PopupMenuButton<String>(
                        icon:
                            const Icon(Icons.more_vert, color: Colors.black87),
                        onSelected: (value) {
                          print(value);
                          if (value == 'Copy') {
                            Clipboard.setData(
                                ClipboardData(text: _selected.first.content));
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              child: const Text('Info'),
                              value: 'Info',
                            ),
                            const PopupMenuItem(
                              child: const Text('Copy'),
                              value: 'Copy',
                            ),
                          ];
                        },
                      )
                    : Container(),
              ],
            ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: WillPopScope(
          child: Column(
            children: [
              Expanded(
                child: Consumer<App>(
                  builder: (context, value, child) {
                    final List<Message> messages = value.userBox
                        .get(widget.user.id)!
                        .messages
                        .reversed
                        .toList();
                    final Map<int, String> date = {};
                    if (messages.isNotEmpty) {
                      if (messages.first.sender != _id &&
                          messages.first.readDate == null) {
                        Provider.of<App>(context, listen: false)
                            .readAllFrom(widget.user.id);
                      }
                      final DateTime now = DateTime.now();
                      final DateTime today =
                          DateTime(now.year, now.month, now.day);
                      final DateTime yesterday =
                          DateTime(now.year, now.month, now.day - 1);
                      String _getDate(DateTime date) {
                        date = DateTime(date.year, date.month, date.day);
                        if (date == today) {
                          return 'Today';
                        } else if (date == yesterday) {
                          return 'Yesterday';
                        } else {
                          return DateFormat.yMMMd().format(date);
                        }
                      }

                      DateTime current = DateTime.parse(messages.first.date)
                          .add(now.timeZoneOffset);
                      current =
                          DateTime(current.year, current.month, current.day);
                      for (int i = 1; i < messages.length; i++) {
                        DateTime next = DateTime.parse(messages[i].date)
                            .add(now.timeZoneOffset);
                        next = DateTime(next.year, next.month, next.day);
                        if (current != next) {
                          date[i - 1] = _getDate(current);
                          current = next;
                        }
                      }
                      date[messages.length - 1] = _getDate(current);
                    }
                    return Scrollbar(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shrinkWrap: true,
                        reverse: true,
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              date[index] == null
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        date[index]!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                              InkWell(
                                splashColor: const Color(0xFFACCEF7),
                                highlightColor: const Color(0x8FACCEF7),
                                onTap: () {
                                  if (_selected.contains(messages[index])) {
                                    setState(() {
                                      _selected.remove(messages[index]);
                                    });
                                  } else {
                                    if (_selected.isNotEmpty) {
                                      setState(() {
                                        _selected.add(messages[index]);
                                      });
                                    }
                                  }
                                },
                                onLongPress: () {
                                  setState(() {
                                    if (_selected.contains(messages[index])) {
                                      _selected.remove(messages[index]);
                                    } else {
                                      _selected.add(messages[index]);
                                    }
                                  });
                                },
                                child: Ink(
                                  color: _selected.contains(messages[index])
                                      ? const Color(0xFFACCEF7)
                                      : Colors.white,
                                  child: messages[index].sender == _id
                                      ? SenderCard(
                                          message: messages[index],
                                        )
                                      : ReceiverCard(
                                          message: messages[index],
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                heightFactor: 0.97,
                child: TypingIndicator(
                  showTypingIndicator: Provider.of<App>(context)
                      .isTyping
                      .containsKey(widget.user.id),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 60,
                            child: Card(
                              margin: const EdgeInsets.only(
                                  left: 2, right: 2, bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              color: Colors.grey[50],
                              child: TextFormField(
                                controller: _controller,
                                focusNode: _focusNode,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.multiline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: 5,
                                minLines: 1,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Write message',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: IconButton(
                                    icon: Icon(
                                      _show
                                          ? Icons.keyboard
                                          : Icons.emoji_emotions_outlined,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      if (!_show) {
                                        _focusNode.unfocus();
                                        _focusNode.canRequestFocus = false;
                                      }
                                      setState(() {
                                        _show = !_show;
                                      });
                                    },
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.rotate(
                                        angle: pi / 4,
                                        child: IconButton(
                                          icon: const Icon(Icons.attach_file),
                                          color: Colors.grey[600],
                                          onPressed: () {
                                            _focusNode.unfocus();
                                            _focusNode.canRequestFocus = false;
                                            setState(() {
                                              _show = false;
                                            });
                                            showModalBottomSheet(
                                              backgroundColor:
                                                  Colors.transparent,
                                              context: context,
                                              builder: (builder) =>
                                                  _bottomSheet(),
                                            );
                                            Future(() {
                                              _focusNode.canRequestFocus = true;
                                            });
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.camera_alt),
                                        color: Colors.grey[600],
                                        onPressed: () {
                                          _onImageButtonPressed(
                                              ImageSource.camera,
                                              context: context);
                                        },
                                      ),
                                    ],
                                  ),
                                  contentPadding: const EdgeInsets.all(5),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8,
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  child: IconButton(
                                    icon: _send
                                        ? const Icon(
                                            Icons.send,
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Icons.mic,
                                            color: Colors.white,
                                          ),
                                    onPressed: () {
                                      if (_send) {
                                        Message message = Message(
                                          content: _controller.text.trim(),
                                          type: 'text',
                                          sender: _id,
                                          receiver: widget.user.id,
                                          date: DateTime.now()
                                              .toUtc()
                                              .toIso8601String(),
                                        );
                                        Provider.of<App>(context, listen: false)
                                            .send(message);
                                        setState(() {
                                          _controller.clear();
                                          _scrollController.animateTo(
                                            _scrollController
                                                .position.minScrollExtent,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.fastOutSlowIn,
                                          );
                                          _send = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _show
                          ? SizedBox(
                              height: 0.35 * MediaQuery.of(context).size.height,
                              child: EmojiPicker(
                                onEmojiSelected: (category, emoji) {
                                  setState(() {
                                    _controller.text =
                                        _controller.text + emoji.emoji;
                                    _send = true;
                                  });
                                },
                                config: const Config(
                                  columns: 8,
                                  emojiSizeMax: 25,
                                  recentsLimit: 40,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          onWillPop: () {
            if (_show) {
              setState(() {
                _show = false;
              });
            } else if (_selected.isNotEmpty) {
              setState(() {
                _selected.clear();
              });
            } else {
              return Future.value(true);
            }
            return Future.value(false);
          },
        ),
      ),
    );
  }

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      final SnackBar snackBar = SnackBar(content: Text('$e'));
      ScaffoldMessenger.of(context!).showSnackBar(snackBar);
    }
  }

  Widget _bottomSheet() {
    return Container(
      height: 270,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BottomSheetIcon(
                    icon: Icons.insert_drive_file,
                    backgroundColor: Colors.indigo,
                    text: 'Document',
                    radius: 30,
                    function: () {},
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  BottomSheetIcon(
                    icon: Icons.camera_alt,
                    backgroundColor: Colors.pink,
                    text: 'Camera',
                    radius: 30,
                    function: () {
                      _onImageButtonPressed(ImageSource.camera,
                          context: context);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  BottomSheetIcon(
                    icon: Icons.insert_photo,
                    backgroundColor: Colors.purple,
                    text: 'Gallery',
                    radius: 30,
                    function: () {
                      _onImageButtonPressed(ImageSource.gallery,
                          context: context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BottomSheetIcon(
                    icon: Icons.headset,
                    backgroundColor: Colors.orange,
                    text: 'Audio',
                    radius: 30,
                    function: () {},
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  BottomSheetIcon(
                    icon: Icons.location_pin,
                    backgroundColor: Colors.teal,
                    text: 'Location',
                    radius: 30,
                    function: () {},
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  BottomSheetIcon(
                    icon: Icons.person,
                    backgroundColor: Colors.blue,
                    text: 'Contact',
                    radius: 30,
                    function: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: _selected.length == 1
              ? const Text('Delete selected message?')
              : Text('Delete all ${_selected.length} selected messages?'),
          actions: widget.user.id == _id ||
                  _selected.any((message) =>
                      message.content == '' ||
                      message.refDate == null ||
                      message.sender != _id)
              ? [
                  TextButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('DELETE FOR ME'),
                    onPressed: () {
                      _deleteMessages();
                    },
                  ),
                ]
              : [
                  TextButton(
                    child: const Text('DELETE FOR ME'),
                    onPressed: () {
                      _deleteMessages();
                    },
                  ),
                  TextButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('DELETE FOR EVERYONE'),
                    onPressed: () {
                      _deleteForEveryone();
                    },
                  ),
                ],
        );
      },
    );
  }

  void _deleteMessages() {
    Provider.of<App>(context, listen: false)
        .deleteMessages(_selected.map((message) => message.date));
    setState(() {
      _selected.clear();
    });
    Navigator.of(context).pop();
  }

  void _deleteForEveryone() {
    Provider.of<App>(context, listen: false).deleteForEveryone(
        widget.user.id, _selected.map((message) => message.date));
    setState(() {
      _selected.clear();
    });
    Navigator.of(context).pop();
  }
}
