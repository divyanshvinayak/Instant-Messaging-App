import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:express/models/user.dart';
import 'package:express/models/message.dart';
import 'package:express/models/preferences.dart';
import 'package:express/constants/constants.dart';

class App extends ChangeNotifier {
  late final IO.Socket socket;
  late final Box<User> userBox;
  late final Box<Message> messageBox;
  late final Box<Preferences> preferencesBox;
  late final String profilePhotoDirectory;
  final Map<String, Timer> isTyping = {};

  Future<void> initDirs() async {
    final Directory applicationDocumentsDirectory =
        await getApplicationDocumentsDirectory();
    profilePhotoDirectory =
        '${applicationDocumentsDirectory.path}/media/profile_photos';
    await Directory(profilePhotoDirectory).create(recursive: true);
  }

  Future<void> openBoxes() async {
    userBox = await Hive.openBox<User>(userBoxName);
    messageBox = await Hive.openBox<Message>(messageBoxName);
    preferencesBox = await Hive.openBox<Preferences>(preferencesBoxName);
  }

  String formatName(String name) {
    return name.trim().split(RegExp('\\s+')).join(' ');
  }

  int getRandomColor() {
    return Colors
        .primaries[Random().nextInt(Colors.primaries.length)]
            [(Random().nextInt(5) + 5) * 100]!
        .value;
  }

  Future<String?> saveProfilePhoto(XFile? image) async {
    if (image == null) {
      return null;
    }
    final String imageName =
        base64.encode(utf8.encode(DateTime.now().toUtc().toIso8601String()));
    final String imagePath = '$profilePhotoDirectory/$imageName';
    await File(image.path).copy(imagePath);
    return imageName;
  }

  Future<void> registerUser(String id, String name, XFile? image) async {
    final User user = User(
      id: id,
      name: formatName(name),
      messages: HiveList<Message>(messageBox),
      color: getRandomColor(),
      image: await saveProfilePhoto(image),
    );
    await userBox.put(id, user);
  }

  Future<void> login(String id, String name, XFile? image) async {
    await registerUser(id, name, image);
    final Preferences preferences = Preferences(
      authUser: userBox.get(id),
      contactsSaved: false,
    );
    await preferencesBox.add(preferences);
  }

  String getProfilePhotoPath(String imageName) {
    return '$profilePhotoDirectory/$imageName';
  }

  void init() {
    socket =
        IO.io('<ENTER_YOUR_SERVER_URL_HERE>', <String, dynamic>{
      'transports': ['websocket'],
      'forceNew': true,
    });
    socket.connect();
    socket.emit('join', preferencesBox.getAt(0)!.authUser!.id);
    socket.onConnect(
      (data) => {
        socket.on('receive', (data) async {
          final Message message = Message.fromJson(json.decode(data));
          if (!userBox.containsKey(message.sender)) {
            await registerUser(message.sender, message.sender, null);
          }
          message.refDate = message.date;
          message.date = DateTime.now().toUtc().toIso8601String();
          socket.emit(
            'delivered',
            [
              message.sender,
              json.encode({
                'date': message.refDate,
                'refDate': message.date,
              }),
            ],
          );
          await messageBox.put(message.date, message);
          final User user = userBox.get(message.sender)!;
          user.messages.add(message);
          await user.save();
          notifyListeners();
        }),
        socket.on('delivered', (data) async {
          final info = json.decode(data);
          final Message? obj = messageBox.get(info['date']);
          if (obj != null) {
            obj.refDate = info['refDate'];
            await obj.save();
          }
          notifyListeners();
        }),
        socket.on('read', (data) async {
          final info = json.decode(data);
          for (final message in info['messages']) {
            final Message? obj = messageBox.get(message);
            if (obj != null) {
              obj.readDate = info['date'];
              await obj.save();
            }
          }
          notifyListeners();
        }),
        socket.on('typing', (data) {
          final info = json.decode(data);
          if (userBox.containsKey(info['who'])) {
            isTyping[info['who']]?.cancel();
            isTyping[info['who']] =
                Timer(const Duration(milliseconds: 4500), () {
              isTyping.remove(info['who']);
              notifyListeners();
            });
            notifyListeners();
          }
        }),
        socket.on(
          'delete',
          (data) async {
            final info = json.decode(data);
            for (final message in info['messages']) {
              final Message? obj = messageBox.get(message);
              if (obj != null) {
                obj.content = '';
                await obj.save();
              }
            }
            notifyListeners();
          },
        ),
      },
    );
  }

  Future<void> refresh() async {
    final Set<String> contacts = {preferencesBox.getAt(0)!.authUser!.id};
    final Iterable<Contact> _contacts =
        await ContactsService.getContacts(withThumbnails: false);
    _contacts.forEach((_contact) async {
      if (_contact.phones!.isNotEmpty) {
        final String id =
            _contact.phones!.first.value!.replaceAll(RegExp(r'[^0-9+]'), '');
        final String name = formatName(_contact.displayName!);
        contacts.add(id);
        if (userBox.containsKey(id)) {
          final User user = userBox.get(id)!;
          user.name = name;
          await user.save();
        } else {
          await registerUser(id, name, null);
        }
      }
    });
    await userBox.deleteAll(userBox.values
        .where((user) => !contacts.contains(user.id) && user.messages.isEmpty)
        .map((user) => user.id));
    final Preferences preferences = preferencesBox.getAt(0)!;
    if (preferences.contactsSaved == false) {
      preferences.contactsSaved = true;
      await preferences.save();
    }
    notifyListeners();
  }

  Future<void> send(Message message) async {
    await messageBox.put(message.date, message);
    final User user = userBox.get(message.receiver)!;
    user.messages.add(message);
    await user.save();
    socket.emit('send', [
      message.receiver,
      json.encode(message),
    ]);
    notifyListeners();
  }

  Future<void> readAllFrom(String user) async {
    final List<String> messages = [];
    final String now = DateTime.now().toUtc().toIso8601String();
    for (final Message message in userBox.get(user)!.messages.reversed) {
      if (message.readDate == null) {
        message.readDate = now;
        await message.save();
        messages.add(message.refDate!);
      } else {
        break;
      }
    }
    socket.emit('read', [
      user,
      json.encode({
        'date': now,
        'messages': messages,
      }),
    ]);
    notifyListeners();
  }

  void isTypingTo(String user) {
    socket.emit('typing', [
      user,
      json.encode({
        'who': preferencesBox.getAt(0)!.authUser!.id,
      }),
    ]);
  }

  Future<void> deleteMessages(Iterable<String> selected) async {
    await messageBox.deleteAll(selected);
    notifyListeners();
  }

  void deleteConversations(Set<String> selected) {
    selected.forEach((user) async {
      await messageBox.deleteAll(
          userBox.get(user)!.messages.map((message) => message.date));
    });
    notifyListeners();
  }

  Future<void> deleteForEveryone(String user, Iterable<String> selected) async {
    final List<String> messages = [];
    for (final message in selected) {
      final Message obj = messageBox.get(message)!;
      obj.content = '';
      obj.save();
      messages.add(obj.refDate!);
    }
    socket.emit('delete', [
      user,
      json.encode({
        'messages': messages,
      }),
    ]);
    notifyListeners();
  }
}
