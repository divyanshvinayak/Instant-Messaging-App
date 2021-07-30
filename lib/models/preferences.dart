import 'package:hive/hive.dart';
import 'package:express/models/user.dart';

part 'preferences.g.dart';

@HiveType(typeId: 2)
class Preferences extends HiveObject {
  @HiveField(0)
  User? authUser;
  @HiveField(1)
  bool? contactsSaved;

  Preferences({
    this.authUser,
    this.contactsSaved,
  });
}
