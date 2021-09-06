import 'dart:io';

class NoteModel {
  NoteModel({
    this.id,
    this.title,
    this.description,
  });

  String id;
  String title;
  List<Description> description;

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json["id"] == null ? null : json["id"],
    title: json["title"] == null ? null : json["title"],
    description: json["description"] == null ? null : List<Description>.from(json["description"].map((x) => Description.fromJson(x))),
  );
}

class Description {
  Description({
    this.id,
    this.desc,
    this.image,
  });

  String id;
  String desc;
  File image;

  factory Description.fromJson(Map<String, dynamic> json) => Description(
    id: json["id"] == null ? null : json["id"],
    desc: json["desc"] == null ? null : json["desc"],
    image: json["image"] == null ? null : json["image"],
  );
}