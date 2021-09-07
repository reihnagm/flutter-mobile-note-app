import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:package_info/package_info.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import 'package:note_app/helpers/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;
  runApp(MyApp(
    version: version,
    buildNumber: buildNumber
  ));
}

class MyApp extends StatelessWidget {
  final String version;
  final String buildNumber;
  MyApp({
    this.version,
    this.buildNumber
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alba Note',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        seconds: 3,
        navigateAfterSeconds: MyHomeScreen(),
        title: Text('Alba Note ${this.version}+${this.buildNumber}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
          color: Colors.white
        )),
        image: Image.asset("assets/images/notepad.png",
          color: Colors.white,
        ),
        useLoader: false,
        backgroundColor: Colors.purple[200],
        styleTextUnderTheLoader: TextStyle(),
        photoSize: 100.0,
        onClick: () => print("..."),
        loaderColor: Colors.red
      ),
    );
  }
}

class MyHomeScreen extends StatefulWidget {

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  
  List notesWidget = [{
    "id": Uuid().v4(),
    "title": TextField(
      style: TextStyle(
        fontSize: 12.0,
        color: Colors.black
      ),
      controller: TextEditingController(),
      decoration: InputDecoration(
        hintText: "E.g Fruits",
        hintStyle: TextStyle(
          fontSize: 12.0,
          color: Colors.grey
        ),
        contentPadding: EdgeInsets.all(16.0),
        enabledBorder: UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder()
      ),
    ),
    "description": [{
      "id": Uuid().v4(),
      "title": TextField(
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.black
        ),
        controller: TextEditingController(),
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "E.g Apple",
          hintStyle: TextStyle(
            fontSize: 12.0,
            color: Colors.grey
          ),
          contentPadding: EdgeInsets.all(16.0),
          enabledBorder: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder()
        ),
      ),
    }]
  }];

  List<Map<String, dynamic>> notes = [];
  Future<List<Map<String, dynamic>>> fetchAndSetNotes() async {       
    notes = [];
    final dataList = await DBHelper.getData();
    for (var item in dataList) {
      notes.add({
        "note_id": item["note_id"],
        "desc_id": item["desc_id"],
        "note_desc_id": item["note_desc_id"],
        "date": item["date"],
        "title": item["parentTitle"],
        "descs": item["childTitle"]
      });
    }
    return notes;
  }

  ScrollController notesController = ScrollController();
  void addItem(Function setState) {
    setState(() {
      notesWidget.add({
        "id": Uuid().v4(),
        "title": TextField(
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black
          ),
          controller: TextEditingController(),
          decoration: InputDecoration(
            hintText: "E.g Fruits",
            hintStyle: TextStyle(
              fontSize: 12.0,
              color: Colors.grey
            ),
            contentPadding: EdgeInsets.all(16.0),
            enabledBorder: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder()
          ),
        ),
        "description": [{
          "id": Uuid().v4(),
          "title": TextField(
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black
            ),
            controller: TextEditingController(),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "E.g Apple",
              hintStyle: TextStyle(
                fontSize: 12.0,
                color: Colors.grey
              ),
              contentPadding: EdgeInsets.all(16.0),
              enabledBorder: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder()
            ),
          ),
        }]
      });
    });
    Future.delayed(Duration.zero, () {
      notesController.animateTo(notesController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  void removeItem(Function setState, String id) {
    setState(() {
      notesWidget.removeWhere((item) => item["id"] == id);
    });
  }

  void addItemDesc(Function setState, String id) {
    setState(() {
      int index = notesWidget.indexWhere((item) => item["id"] == id);
      notesWidget[index]["description"].add({
        "id": Uuid().v4(),
        "title": TextField(
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black
          ),
          controller: TextEditingController(),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "E.g Apple",
            hintStyle: TextStyle(
              fontSize: 12.0,
              color: Colors.grey
            ),
            contentPadding: EdgeInsets.all(16.0),
            enabledBorder: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder()
          ),
        ),
      });
    });
  }

  void removeItemDesc(Function setState, String idParent, String idChild) {
    setState(() {
      int indexParent = notesWidget.indexWhere((item) => item["id"] == idParent);
      int indexChild = notesWidget[indexParent]["description"].indexWhere((item) => item["id"] == idChild);
      notesWidget[indexParent]["description"].removeAt(indexChild);
    });
  }

  void submitNote() {
    for (var note in notesWidget) {
      String notesId = Uuid().v4();
      TextField titleParent = note["title"];
      for (var noteDesc in note["description"]) {
        String descsId = Uuid().v4();
        TextField titleChild = noteDesc["title"];
        DBHelper.insert("notes", {
          "id": notesId,
          "title": titleParent.controller.text,
          "date": DateTime.now().toString()
        });
        DBHelper.insert("descs", {
          "id": descsId,
          "title": titleChild.controller.text
        });
        DBHelper.insert("note_descs", {
          "id": Uuid().v4(),
          "note_id": notesId,
          "desc_id": descsId
        });
      }
    }
    Navigator.of(context).pop();
    setState(() {});
  }

  void updateNote() {
    for (var note in notesWidget) {
      TextField titleParent = note["title"];
      for (var noteDesc in note["description"]) {
        TextField titleChild = noteDesc["title"];
        DBHelper.insert("notes", {
          "id": note["id"],
          "title": titleParent.controller.text,
          "date": DateTime.now().toString()
        });
        DBHelper.insert("descs", {
          "id": noteDesc["id"],
          "title": titleChild.controller.text
        });
        DBHelper.insert("note_descs", {
          "id": Uuid().v4(),
          "note_id": note["id"],
          "desc_id": noteDesc["id"]
        });
      }
    }
    Navigator.of(context).pop();
    setState(() {});
  }

  void addNotes() {
    notesWidget = [{
      "id": Uuid().v4(),
      "title": TextField(
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.black
        ),
        controller: TextEditingController(),
        decoration: InputDecoration(
          hintText: "E.g Fruits",
          hintStyle: TextStyle(
            fontSize: 12.0,
            color: Colors.grey
          ),
          contentPadding: EdgeInsets.all(16.0),
          enabledBorder: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder()
        ),
      ),
      "description": [{
        "id": Uuid().v4(),
        "title": TextField(
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black
          ),
          controller: TextEditingController(),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "E.g Apple",
            hintStyle: TextStyle(
              fontSize: 12.0,
              color: Colors.grey
            ),
            contentPadding: EdgeInsets.all(16.0),
            enabledBorder: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder()
          ),
        ),
      }]
    }];
    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2, Widget widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
        return StatefulBuilder(
          builder: (BuildContext context, Function s) {
            return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                title: Text('Add Note',
                  style: TextStyle(
                    fontSize: 16.0
                  ),
                ),
                content: Container(
                width: 300.0,
                height: 300.0,
                child: ListView(
                  controller: notesController,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => addItem(s), 
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple[200],
                        elevation: 2.0
                      ),
                      icon: Icon(Icons.add_circle), 
                      label: Text("Add Item",
                        style: TextStyle(
                          fontSize: 14.0
                        ),
                      )
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black
                        ),
                        borderRadius: BorderRadius.circular(10.0)
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: notesWidget.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: notesWidget[i]["title"] 
                                  ),
                                  if(i > 0) 
                                    InkWell(
                                      onTap: () => removeItem(s, notesWidget[i]["id"]),
                                      child: Icon(
                                        Icons.remove_circle,
                                        color: Colors.purple[200]
                                      ),
                                    )
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: notesWidget[i]["description"].length,
                                  itemBuilder:(BuildContext context, int z) {
                                    return Container(
                                      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 6,
                                            child: notesWidget[i]["description"][z]["title"]
                                          ),
                                          z > 0 
                                          ? Flexible(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () => z > 0 ? removeItemDesc(s, notesWidget[i]["id"], notesWidget[i]["description"][z]["id"]) : addItemDesc(s, notesWidget[i]["id"]),
                                              child: Icon(
                                                z > 0 ? Icons.remove_circle : Icons.add_circle,
                                                color: Colors.purple[200],  
                                              ),
                                            )) 
                                          : Container()
                                        ],
                                      ),
                                    );          
                                  },
                                ),
                              )
                            ]
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple[200],
                        elevation: 2.0
                      ),
                      onPressed: submitNote,
                      child: Text("Save",
                        style: TextStyle(
                          fontSize: 14.0
                        ),
                      ),
                    )
                  ],
                )
              )),
            ));
          },
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (BuildContext context, Animation<double>animation1, Animation<double> animation2) {}
    );
  }

  void editNote(String noteId) {
    final notesSelected = notes.where((item) => item["note_id"] == noteId).toList();
    for (var note in notesSelected) {   
      notesWidget = [{
        "id": noteId,
        "title": TextField(
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black
          ),
          controller: TextEditingController(text: note["title"]),
          decoration: InputDecoration(
            hintText: "E.g Fruits",
            hintStyle: TextStyle(
              fontSize: 12.0,
              color: Colors.grey
            ),
            contentPadding: EdgeInsets.all(16.0),
            enabledBorder: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder()
          ),
        ),
        "description": [{
          "id": note["desc_id"],
          "title": TextField(
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black
            ),
            controller: TextEditingController(text: note["descs"]),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "E.g Apple",
              hintStyle: TextStyle(
                fontSize: 12.0,
                color: Colors.grey
              ),
              contentPadding: EdgeInsets.all(16.0),
              enabledBorder: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder()
            ),
          ),
        }]
      }]; 
    }
    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2, Widget widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
        return StatefulBuilder(
          builder: (BuildContext context, Function s) {
            return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                title: Text('Edit Note',
                  style: TextStyle(
                    fontSize: 16.0
                  ),
                ),
                content: Container(
                width: 300.0,
                height: 300.0,
                child: ListView(
                  controller: notesController,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => addItem(s), 
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple[200],
                        elevation: 2.0
                      ),
                      icon: Icon(Icons.add_circle), 
                      label: Text("Add Item",
                        style: TextStyle(
                          fontSize: 14.0
                        ),
                      )
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black
                        ),
                        borderRadius: BorderRadius.circular(10.0)
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: notesWidget.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: notesWidget[i]["title"] 
                                  ),
                                  if(i > 0) 
                                    InkWell(
                                      onTap: () => removeItem(s, notesWidget[i]["id"]),
                                      child: Icon(
                                        Icons.remove_circle,
                                        color: Colors.purple[200]
                                      ),
                                    )
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: notesWidget[i]["description"].length,
                                  itemBuilder:(BuildContext context, int z) {
                                    return Container(
                                      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 6,
                                            child: notesWidget[i]["description"][z]["title"]
                                          ),
                                          z > 0 
                                          ? Flexible(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () => z > 0 ? removeItemDesc(s, notesWidget[i]["id"], notesWidget[i]["description"][z]["id"]) : addItemDesc(s, notesWidget[i]["id"]),
                                              child: Icon(
                                                z > 0 ? Icons.remove_circle : Icons.add_circle,
                                                color: Colors.purple[200],  
                                              ),
                                            )) 
                                          : Container()
                                        ],
                                      ),
                                    );          
                                  },
                                ),
                              )
                            ]
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple[200],
                        elevation: 2.0
                      ),
                      onPressed: updateNote,
                      child: Text("Save",
                        style: TextStyle(
                          fontSize: 14.0
                        ),
                      ),
                    )
                  ],
                )
              )),
            ));
          },
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {}
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        centerTitle: true,
        title: Text("Alba Note"),
        backgroundColor: Colors.purple[200],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: fetchAndSetNotes(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if(notes.isEmpty) 
              return Center(
                child: Text("No Notes",
                  style: TextStyle(
                    fontSize: 16.0
                  ),
                )
              );
            return Container(
              margin: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 4,
                itemCount: notes.length,
                itemBuilder: (BuildContext context, int i) => items(context, notes, i),
                staggeredTileBuilder: (int i) => StaggeredTile.count(2, i.isEven ? 3 : 2),
                mainAxisSpacing: 6.0,
                crossAxisSpacing: 6.0,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNotes,
        elevation: 2.0,
        backgroundColor: Colors.purple[200],
        tooltip: 'Add a Note',
        child: Icon(
          Icons.add,
          color: Colors.white,  
        ),
      ),
    );
  }

  Widget items(BuildContext context, List notes, int i) {
    return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 20,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notes[i]["title"],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Text(DateFormat('dd MMM yyyy kk:mm').format(DateTime.parse(notes[i]["date"])),
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PopupMenuButton<String>(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  onSelected: (val) {
                    switch (val) {
                      case "1":
                      showGeneralDialog(
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2, Widget widget) {
                          final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
                          return StatefulBuilder(
                            builder: (BuildContext context, Function s) {
                              return Transform(
                              transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
                              child: Opacity(
                                opacity: a1.value,
                                child: AlertDialog(
                                  shape: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10.0)
                                  ),
                                  title: Text('Detail Note',
                                    style: TextStyle(
                                      fontSize: 16.0
                                    ),
                                  ),
                                  content: Container(
                                  width: 300.0,
                                  height: MediaQuery.of(context).size.height / 5.0,
                                  child: ListView(
                                    children: [
                                      Text(notes[i]["title"],
                                        style: TextStyle(
                                          fontSize: 16.0
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      Container(
                                        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                                        child: Text("${notes[i]["descs"]}",
                                          style: TextStyle(
                                            height: 1.6,
                                            fontSize: 14.0
                                          ),
                                        )
                                      )
                                    ],
                                  )
                                )),
                              ));
                            },
                          );
                        },
                        transitionDuration: Duration(milliseconds: 200),
                        barrierDismissible: true,
                        barrierLabel: '',
                        context: context,
                        pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {}
                      );
                      break;
                      case "2":
                        editNote(notes[i]["note_id"]);
                      break;
                      case "3":
                        showGeneralDialog(
                          barrierColor: Colors.black.withOpacity(0.5),
                          transitionBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2, Widget widget) {
                            final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
                            return StatefulBuilder(
                              builder: (BuildContext context, Function s) {
                                return Transform(
                                transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
                                child: Opacity(
                                  opacity: a1.value,
                                  child: AlertDialog(
                                    shape: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10.0)
                                    ),
                                    title: Text('Delete note ?',
                                      style: TextStyle(
                                        fontSize: 16.0
                                      ),
                                    ),
                                    content: Container(
                                    width: 300.0,
                                    height: 40.0,
                                    child: ListView(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("No",
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.black
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16.0),
                                            InkWell(
                                              onTap: () {                       
                                                DBHelper.delete("notes", notes[i]["note_id"]);
                                                DBHelper.delete("descs", notes[i]["desc_id"]);
                                                DBHelper.delete("note_descs", notes[i]["note_desc_id"]);
                                                setState(() { });      
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Yes",
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.black
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  )),
                                ));
                              },
                            );
                          },
                          transitionDuration: Duration(milliseconds: 200),
                          barrierDismissible: true,
                          barrierLabel: '',
                          context: context,
                          pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {}
                        );
                      break;
                      default:
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      {
                        "id": 1,
                        "icon": Icons.visibility
                      }, 
                      {
                        "id": 2,
                        "icon": Icons.edit
                      },
                      {
                        "id": 3,
                        "icon": Icons.remove_circle
                      }].map((choice) {
                        return PopupMenuItem<String>(
                        value: choice["id"].toString(),
                        child: Center(
                          child: Icon(
                            choice["icon"],
                            color: choice["id"] == 1
                            ? Colors.blue[200] 
                            : choice["id"] == 2 
                            ? Colors.brown[200] 
                            : Colors.red[200],
                          )
                        ),
                      );
                    }).toList();
                  },
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Text("${notes[i]["descs"]}",
              textAlign: TextAlign.justify,
              style: TextStyle(
                height: 1.6,
                fontSize: 13.0
              ),
            )
          )
        ),
      ]
    ));
  }
}
