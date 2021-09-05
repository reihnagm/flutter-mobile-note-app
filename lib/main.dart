import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:note_app/helpers/db_helper.dart';
import 'package:note_app/models/note.dart';

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
  NoteModel _notes;

  List notesWidget = [{
    "id": "abc",
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
      "field": Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 6,
            child: TextField(
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black
              ),
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
          ),
          Flexible(
            flex: 1,
            child: Icon(
              Icons.add_circle,
              color: Colors.purple[200],  
            )
          )
        ],
      )
    }]
  }];

  void addNotes() {
    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2, Widget widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
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
              content: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                width: 300.0,
                height: 300.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {}, 
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
                      child: Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: notesWidget.length,
                          itemBuilder: (BuildContext context, int i) {
                            return Column(
                              children: [
                                notesWidget[i]["title"],
                                Container(
                                  margin: EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: notesWidget[i]["description"].length,
                                    itemBuilder:(BuildContext context, int z) {
                                      return notesWidget[i]["description"][z]["field"];           
                                    },
                                  ),
                                )
                              ]
                            );
                          },
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple[200],
                        elevation: 2.0
                      ),
                      onPressed: () {

                      },
                      child: Text("Submit",
                        style: TextStyle(
                          fontSize: 14.0
                        ),
                      ),
                    )
                  ],
                )
              ),
            ),
          ),
        ));
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {}
    );
  }

  @override
  Widget build(BuildContext context) {

    Future<NoteModel> fetchAndSetNotes() async {
      final dataList = await DBHelper.getData("notes");
      for (var item in dataList) {
        setState(() {        
          _notes = NoteModel(
            id: item['id'],
            title: item['title'],
            description: [
              Description(
                id: item['description']['id'],
                desc: item['description']['desc'],
                image: File(item['description']['image']),
              )
            ]
          );
        });
      }
      return _notes;
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
          _notes = snapshot.data;
          if(_notes == null) 
            return Center(
              child: Text("No Notes",
                style: TextStyle(
                  fontSize: 16.0
                ),
              )
            );
          return Text("ada");
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
