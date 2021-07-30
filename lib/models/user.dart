import 'package:hive/hive.dart';
import 'package:express/models/message.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  HiveList<Message> messages;
  @HiveField(3)
  int color;
  @HiveField(4)
  String? about;
  @HiveField(5)
  String? image;
  User({
    required this.id,
    required this.name,
    required this.messages,
    required this.color,
    this.about,
    this.image,
  });
}
