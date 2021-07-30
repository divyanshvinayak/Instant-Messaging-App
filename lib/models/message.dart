import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class Message extends HiveObject {
  @HiveField(0)
  String content;
  @HiveField(1)
  String type;
  @HiveField(2)
  String sender;
  @HiveField(3)
  String receiver;
  @HiveField(4)
  String date;
  @HiveField(5)
  String? refDate;
  @HiveField(6)
  String? readDate;
  Message({
    required this.content,
    required this.type,
    required this.sender,
    required this.receiver,
    required this.date,
    this.refDate,
    this.readDate,
  });
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
