// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 1;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      content: fields[0] as String,
      type: fields[1] as String,
      sender: fields[2] as String,
      receiver: fields[3] as String,
      date: fields[4] as String,
      refDate: fields[5] as String?,
      readDate: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.sender)
      ..writeByte(3)
      ..write(obj.receiver)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.refDate)
      ..writeByte(6)
      ..write(obj.readDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    content: json['content'] as String,
    type: json['type'] as String,
    sender: json['sender'] as String,
    receiver: json['receiver'] as String,
    date: json['date'] as String,
    refDate: json['refDate'] as String?,
    readDate: json['readDate'] as String?,
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'content': instance.content,
      'type': instance.type,
      'sender': instance.sender,
      'receiver': instance.receiver,
      'date': instance.date,
      'refDate': instance.refDate,
      'readDate': instance.readDate,
    };
