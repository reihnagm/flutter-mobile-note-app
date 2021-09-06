import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:note_app/helpers/db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      debugShowCheckedModeBanner: false,
      home: MyHomeScreen(),
    );
  }
}

class MyHomeScreen extends StatefulWidget {

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {

  List<Map<String, dynamic>> notes = [];

  Future<List<Map<String, dynamic>>> fetchAndSetNotes() async {       
    notes = [];
    final dataList = await DBHelper.getData("notes");
    notes.addAll(dataList);
    return notes;
  }

  @override
  Widget build(BuildContext context) {

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
              suffixIcon: Icon(
                Icons.add_a_photo,
                color: Colors.purple[200],   
              ),
              enabledBorder: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder()
            ),
          ),
        }]
      }];

      void addItem(Function s) {
        s(() {
          notesWidget.add({
            "id": Uuid().v4(),
            "title": TextField(
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black
              ),
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
                  suffixIcon: Icon(
                    Icons.add_a_photo,
                    color: Colors.purple[200],   
                  ),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder()
                ),
              ),
            }]
          });
        });
      }

    void removeItem(Function s, String id) {
      s(() {
        notesWidget.removeWhere((item) => item["id"] == id);
      });
    }

    void addItemDesc(Function s, String id) {
      s(() {
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
              suffixIcon: Icon(
                Icons.add_a_photo,
                color: Colors.purple[200],   
              ),
              enabledBorder: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder()
            ),
          ),
        });
      });
    }

    void removeItemDesc(Function s, String idParent, String idChild) {
      s(() {
        int indexParent = notesWidget.indexWhere((item) => item["id"] == idParent);
        int indexChild = notesWidget[indexParent]["description"].indexWhere((item) => item["id"] == idChild);
        notesWidget[indexParent]["description"].removeAt(indexChild);
      });
    }

    void submitNote() {
      String userNotesId = Uuid().v4();
      for (var note in notesWidget) {
        TextField titleParent = note["title"];
        for (var noteDesc in note["description"]) {
          TextField titleChild = noteDesc["title"];
          DBHelper.insert("notes", {
            "id": userNotesId,
            "title": titleParent.controller.text,
          });
          DBHelper.insert("descs", {
            "id": Uuid().v4(),
            "title": titleChild.controller.text,
            "note_id": userNotesId
          });
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    }

    void addNotes() {
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
                  title: Text('Add Item',
                    style: TextStyle(
                      fontSize: 16.0
                    ),
                  ),
                  content: Container(
                  width: 300.0,
                  height: 300.0,
                  child: ListView(
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
                                notesWidget[i]["title"],
                                if(i > 0) 
                                  Row(
                                    children: [
                                      Flexible(
                                        child: notesWidget[i]["title"] 
                                      ),
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
                                            Flexible(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () => z > 0 ? removeItemDesc(s, notesWidget[i]["id"], notesWidget[i]["description"][z]["id"]) : addItemDesc(s, notesWidget[i]["id"]),
                                                child: Icon(
                                                  z > 0 ? Icons.remove_circle : Icons.add_circle,
                                                  color: Colors.purple[200],  
                                                ),
                                              )
                                            )
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
                        child: Text("Submit",
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
        pageBuilder: (context, animation1, animation2) {}
      );
    }
      
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text("Note App"),
        backgroundColor: Colors.purple[200],
      ),
      body: FutureBuilder(
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
          return StatefulBuilder(
            builder: (BuildContext context, Function s) {
              return ListView(
                children: notes.asMap().map((i, e) => 
                 MapEntry(i, Container(
                    margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Text("${(i + 1).toString()}.",
                                style: TextStyle(
                                  fontSize: 13.0
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e["title"],
                                style: TextStyle(
                                  fontSize: 16.0
                                ),
                              ),
                              // SizedBox(height: 8.0),
                              // Text(e["desc"],
                              //   style: TextStyle(
                              //     fontSize: 13.0
                              //   ),
                              // )
                            ],
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              notes.removeWhere((item) => item["id"] == e["id"]);
                              setState(() { });                             
                              DBHelper.delete("notes", e["id"]);
                            },
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red[200],
                            ),
                          )
                        )
                      ],
                    ),
                  )
                )).values.toList());
            
              // return ListView.separated(
              //   separatorBuilder: (BuildContext context, int i) => Divider(), 
              //   itemCount: notes.length,
              //   itemBuilder: (BuildContext context, int i) {
              //     return Container(
              //       margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: [
              //           Expanded(
              //             flex: 1,
              //             child: Column(
              //               children: [
              //                 Text("${(i + 1).toString()}.",
              //                   style: TextStyle(
              //                     fontSize: 13.0
              //                   ),
              //                 )
              //               ],
              //             ),
              //           ),
              //           Expanded(
              //             flex: 3,
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(notes[i]["title"],
              //                   style: TextStyle(
              //                     fontSize: 16.0
              //                   ),
              //                 ),
              //                 SizedBox(height: 8.0),
              //                 Text(notes[i]["desc"],
              //                   style: TextStyle(
              //                     fontSize: 13.0
              //                   ),
              //                 )
              //               ],
              //             ),
              //           ),
              //           Expanded(
              //             child: InkWell(
              //               onTap: () {
              //                 s(() {  
              //                   notes = [];
              //                 });
              //                 DBHelper.delete("user_notes", notes[i]["id"]);
              //               },
              //               child: Icon(
              //                 Icons.remove_circle,
              //                 color: Colors.red[200],
              //               ),
              //             )
              //           )
              //         ],
              //       ),
              //     );
              //   }, 
              // );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNotes,
        elevation: 2.0,
        backgroundColor: Colors.white,
        tooltip: 'Add a Note',
        child: Icon(
          Icons.add,
          color: Colors.purple[200],  
        ),
      ),
    );
  }
}
