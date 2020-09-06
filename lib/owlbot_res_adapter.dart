import 'package:hive/hive.dart';
import 'package:owlbot_dart/owlbot_dart.dart';

class OwlBotResAdapter extends TypeAdapter<OwlBotResponse> {
  @override
  OwlBotResponse read(BinaryReader reader) {
    Map<String, dynamic> data = {
      "word": reader.readString(),
      "pronunciation": reader.readString(),
    };
      var definitions = reader.readList();
    final res = OwlBotResponse.fromJson(data);
    res.definitions = List<OwlBotDefinition>.from( definitions);
    return res;
    
  }

  @override
  int get typeId => 2;

  @override
  void write(BinaryWriter writer, OwlBotResponse obj) {
    writer.writeString(obj.word);
    writer.writeString(obj.pronunciation ?? '');
    writer.writeList(obj.definitions);
  }
}

class OwlBotDefinitionAdapter extends TypeAdapter<OwlBotDefinition> {
  @override
  OwlBotDefinition read(BinaryReader reader) {
    Map<String, dynamic> data = {
      "definition": reader.readString(),
      "type": reader.readString(),
      "emoji": reader.readString(),
      "example": reader.readString(),
      "image_url": reader.readString(),
    };
    return OwlBotDefinition.fromJson(data);
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, OwlBotDefinition obj) {
    writer.writeString(obj.definition);
    writer.writeString(obj.type);
    writer.writeString(obj.emoji ?? '');
    writer.writeString(obj.example);
    writer.writeString(obj.imageUrl ?? '');
  }
}
