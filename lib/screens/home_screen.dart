import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:express/providers/app.dart';
import 'package:express/models/user.dart';
import 'package:express/screens/chat_screen.dart';
import 'package:express/screens/contacts_screen.dart';
import 'package:express/widgets/conversation_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _image;
  bool _show = false;
  bool _searching = false;
  final Set<String> _selected = {};
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  late final User _authUser = Provider.of<App>(context, listen: false)
      .preferencesBox
      .getAt(0)!
      .authUser!;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _show = false;
        });
      } else {
        setState(() {
          _show = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<App>(context, listen: false).init();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selected.isNotEmpty
          ? AppBar(
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
                Transform.rotate(
                  angle: pi / 4,
                  child: IconButton(
                    icon: const Icon(Icons.push_pin_outlined,
                        color: Colors.black87),
                    onPressed: () {},
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.archive_outlined, color: Colors.black87),
                  onPressed: () {},
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outlined, color: Colors.black87),
                  onPressed: () {
                    _showDeleteDialog();
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) {
                    print(value);
                    if (value == 'Select all') {
                      setState(() {
                        Provider.of<App>(context, listen: false)
                            .userBox
                            .values
                            .where((user) => user.messages.isNotEmpty)
                            .forEach((message) {
                          _selected.add(message.id);
                        });
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return _selected.length == 1
                        ? [
                            const PopupMenuItem(
                              child: const Text('View contact'),
                              value: 'View contact',
                            ),
                            const PopupMenuItem(
                              child: const Text('Mark as unread'),
                              value: 'Mark as unread',
                            ),
                            const PopupMenuItem(
                              child: const Text('Select all'),
                              value: 'Select all',
                            ),
                          ]
                        : [
                            const PopupMenuItem(
                              child: const Text('Mark as unread'),
                              value: 'Mark as unread',
                            ),
                            const PopupMenuItem(
                              child: const Text('Select all'),
                              value: 'Select all',
                            ),
                          ];
                  },
                ),
              ],
            )
          : _searching
              ? AppBar(
                  backgroundColor: Colors.white,
                  leading: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.arrow_back, color: Colors.black54),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _searching = false;
                        _controller.clear();
                      });
                    },
                  ),
                  leadingWidth: 40,
                  title: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.black38),
                      border: InputBorder.none,
                    ),
                  ),
                  actions: _show
                      ? [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Colors.black54),
                              onPressed: () {
                                setState(() {
                                  _controller.clear();
                                });
                              },
                            ),
                          ),
                        ]
                      : null,
                )
              : AppBar(
                  leadingWidth: 57,
                  leading:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    InkWell(
                      onTap: () {},
                      child: _authUser.image == null
                          ? CircleAvatar(
                              maxRadius: 16,
                              backgroundColor: Color(_authUser.color),
                              child: Text(
                                _authUser.name
                                    .split(' ')
                                    .map((e) => e[0].toUpperCase())
                                    .take(2)
                                    .join(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage: Image.file(File(Provider.of<App>(
                                          context,
                                          listen: false)
                                      .getProfilePhotoPath(_authUser.image!)))
                                  .image,
                              maxRadius: 16,
                            ),
                    ),
                  ]),
                  title: const Text(
                    'Express',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.white,
                  actions: [
                    IconButton(
                        icon: const Icon(Icons.search, color: Colors.black87),
                        onPressed: () {
                          setState(() {
                            _searching = true;
                            _focusNode.requestFocus();
                          });
                        }),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.black87),
                      onSelected: (value) {
                        print(value);
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem(
                            child: const Text('New group'),
                            value: 'New group',
                          ),
                          const PopupMenuItem(
                            child: const Text('Invite friends'),
                            value: 'Invite friends',
                          ),
                          const PopupMenuItem(
                            child: const Text('Settings'),
                            value: 'Settings',
                          ),
                        ];
                      },
                    ),
                  ],
                ),
      body: SingleChildScrollView(
        child: WillPopScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<App>(
                builder: (context, value, child) {
                  final List<User> sortedUsers = value.userBox.values
                      .where((user) => user.messages.isNotEmpty)
                      .toList()
                        ..sort((k1, k2) => DateTime.parse(k2.messages.last.date)
                            .compareTo(DateTime.parse(k1.messages.last.date)));
                  return ListView.builder(
                    itemCount: sortedUsers.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        splashColor: const Color(0xFFACCEF7),
                        highlightColor: const Color(0x8FACCEF7),
                        onTap: () {
                          if (_selected.contains(sortedUsers[index].id)) {
                            setState(() {
                              _selected.remove(sortedUsers[index].id);
                            });
                          } else {
                            if (_selected.isNotEmpty) {
                              setState(() {
                                _selected.add(sortedUsers[index].id);
                              });
                            } else {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ChatScreen(
                                  user: sortedUsers[index],
                                );
                              })).then((_) => setState(() {}));
                            }
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            if (_selected.contains(sortedUsers[index].id)) {
                              _selected.remove(sortedUsers[index].id);
                            } else {
                              _selected.add(sortedUsers[index].id);
                            }
                          });
                        },
                        child: Ink(
                          color: _selected.contains(sortedUsers[index].id)
                              ? const Color(0xFFACCEF7)
                              : Colors.white,
                          child: ConversationList(
                            user: sortedUsers[index].id,
                            name: sortedUsers[index].name,
                            lastMessage: sortedUsers[index].messages.last,
                            color: sortedUsers[index].color,
                            image: sortedUsers[index].image,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          onWillPop: () {
            if (_selected.isNotEmpty) {
              setState(() {
                _selected.clear();
                if (_searching) {
                  _focusNode.requestFocus();
                }
              });
            } else if (_searching) {
              setState(() {
                _searching = false;
                _controller.clear();
              });
            } else {
              return Future.value(true);
            }
            return Future.value(false);
          },
        ),
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          onPressed: () {
            _onImageButtonPressed(ImageSource.camera, context: context);
          },
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.black54,
          ),
          backgroundColor: Colors.white,
          heroTag: 'camera',
        ),
        const SizedBox(
          height: 16,
        ),
        FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => ContactsScreen()))
                .then((_) => setState(() {}));
          },
          child: const Icon(
            Icons.edit,
            color: Colors.white,
          ),
          heroTag: 'contacts',
        ),
      ]),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.grey, size: 36),
              const SizedBox(
                width: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: _selected.length == 1
                    ? const Text('Delete selected conversation?')
                    : const Text('Delete selected conversations?'),
              )
            ],
          ),
          content: _selected.length == 1
              ? Text(
                  'This will permanently delete the conversation with "${Provider.of<App>(context, listen: false).userBox.get(_selected.first)?.name}".')
              : Text(
                  'This will permanently delete all ${_selected.length} selected conversations.'),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('DELETE'),
              onPressed: () {
                Provider.of<App>(context, listen: false)
                    .deleteConversations(_selected);
                setState(() {
                  _selected.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
}
