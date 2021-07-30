import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:express/providers/app.dart';
import 'package:express/models/user.dart';
import 'package:express/screens/chat_screen.dart';
import 'package:express/widgets/button_card.dart';
import 'package:express/widgets/contact_card.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  bool _show = false;
  bool _numeric = false;
  bool _status = false;
  bool _loading = true;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _askPermissions();
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
    print('Loading contacts!');
    if (Provider.of<App>(context, listen: false)
            .preferencesBox
            .getAt(0)
            ?.contactsSaved ==
        false) {
      _refreshContacts();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _askPermissions() async {
    final PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      setState(() {
        _status = true;
        _focusNode.requestFocus();
      });
    } else {
      setState(() {
        _status = false;
      });
      _handleInvalidPermissions(permissionStatus);
    }
    setState(() {
      _loading = false;
    });
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      permission = await Permission.contacts.request();
    }
    return permission;
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const SnackBar snackBar =
          SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const SnackBar snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _refreshContacts() async {
    if (_status == true) {
      await Provider.of<App>(context, listen: false).refresh();
    }
  }

  Future<void> _openContactForm() async {
    try {
      final Contact contact = await ContactsService.openContactForm();
      _refreshContacts();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.errorCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
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
              Navigator.of(context).pop();
            });
          },
        ),
        leadingWidth: 40,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: _numeric ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          decoration: const InputDecoration(
            hintText: 'Enter name or number',
            hintStyle: const TextStyle(color: Colors.black38),
            border: InputBorder.none,
          ),
        ),
        actions: [
          _show
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black54),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                    });
                  },
                )
              : IconButton(
                  icon: _numeric
                      ? const Icon(Icons.keyboard, color: Colors.black54)
                      : const Icon(Icons.phone_android, color: Colors.black54),
                  onPressed: () {
                    setState(() {
                      _focusNode.unfocus();
                      _numeric = !_numeric;
                      Future.delayed(const Duration(milliseconds: 10), () {
                        FocusScope.of(context).requestFocus(_focusNode);
                      });
                    });
                  },
                ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Refresh') {
                _refreshContacts();
              }
              print(value);
            },
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  child: const Text('Refresh'),
                  value: 'Refresh',
                ),
                const PopupMenuItem(
                  child: const Text('New group'),
                  value: 'New group',
                ),
                const PopupMenuItem(
                  child: const Text('Invite friends'),
                  value: 'Invite friends',
                ),
              ];
            },
          ),
        ],
      ),
      body: _loading
          ? Container()
          : _status
              ? Consumer<App>(builder: (context, value, child) {
                  final List<User> sortedUsers = value.userBox.values
                      .where((user) =>
                          user.id.contains(_controller.text) ||
                          user.name
                              .toLowerCase()
                              .contains(_controller.text.toLowerCase()))
                      .toList()
                        ..sort((k1, k2) => k1.name.compareTo(k2.name));
                  return ListView.builder(
                    itemCount: _controller.text.isEmpty
                        ? sortedUsers.length + 2
                        : sortedUsers.length,
                    itemBuilder: (context, index) {
                      if (_controller.text.isEmpty) {
                        if (index == 0) {
                          return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: const ButtonCard(
                              icon: Icons.group,
                              name: 'New group',
                            ),
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (builder) => ContactsScreen()));
                            },
                          );
                        } else if (index == 1) {
                          return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: const ButtonCard(
                              icon: Icons.person_add,
                              name: 'New contact',
                            ),
                            onTap: () {
                              _openContactForm();
                              // Navigator.push(context, MaterialPageRoute(builder: (builder) => ContactsScreen()));
                            },
                          );
                        }
                      }
                      if (_controller.text.isEmpty) {
                        index -= 2;
                      }
                      return InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: ContactCard(
                          user: sortedUsers[index].id,
                          name: sortedUsers[index].name,
                          color: sortedUsers[index].color,
                          image: sortedUsers[index].image,
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (builder) =>
                                    ChatScreen(user: sortedUsers[index])),
                          );
                        },
                      );
                    },
                  );
                })
              : Center(
                  child: Container(
                  child: ElevatedButton(
                      child: const Text('SHOW CONTACTS'),
                      onPressed: () {
                        _askPermissions();
                      }),
                  alignment: Alignment.center,
                )),
    );
  }
}
