import 'package:flutter/material.dart';
import 'package:flutter_note_app/model/notes.dart';
import 'package:flutter_note_app/utils/db_helper.dart';
import 'package:flutter_note_app/utils/theme_bloc.dart';
import 'package:flutter_note_app/utils/theme_data.dart';
import 'package:flutter_note_app/views/add_note_screen.dart';
import 'package:flutter_note_app/views/search_note.dart';
import 'package:flutter_note_app/widgets/alertdialog_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

final routeObserver = RouteObserver<PageRoute>();
final duration = const Duration(milliseconds: 300);

class HomeScreen extends StatefulWidget {
  final bool darkThemeEnabled;
  HomeScreen(this.darkThemeEnabled);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  GlobalKey _fabKey = GlobalKey();
  String _themeType;
  List<Note> noteList;
  int count = 0;
  int axisCount = 2;

  @override
  void initState() {
    if (!widget.darkThemeEnabled) {
      _themeType = 'Light Theme';
      Themes.darkThemeEnabled = false;
    } else {
      _themeType = 'Dark Theme';
      Themes.darkThemeEnabled = true;
    }
    super.initState();
  }

  final DatabaseHelper databaseHelper = DatabaseHelper();


  _setPref(bool res) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkTheme', res);
  }


  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () async {
                final Note result = await showSearch(
                    context: context, delegate: NotesSearch(notes: noteList));
                if (result != null) {
                  navigateToDetail(result, 'Edit Note',widget.darkThemeEnabled,true);
              }
            },
          ),
            noteList.length == 0
                ? Container(

            )
                : IconButton(
              icon: Icon(
                axisCount == 2 ? Icons.list : Icons.grid_on,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  axisCount = axisCount == 2 ? 4 : 2;
                });
              },
            ) ,
          PopupMenuButton<String>(
            onSelected: (res) {
              if(res == 'Theme') {
                bloc.changeTheme(!Themes.darkThemeEnabled);
                _setPref(!Themes.darkThemeEnabled);
                setState(() {
                  if (_themeType == 'Dark Theme') {
                    _themeType = 'Light Theme';
                    Themes.darkThemeEnabled = false;
                  } else {
                    _themeType = 'Dark Theme';
                    Themes.darkThemeEnabled = true;
                  }
                });
              }
              else if(res == 'Delete'){
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialogWidget(
                      contentText: "Are you sure you want to delete all notes?",
                      confirmFunction: () async {
                        databaseHelper.deleteAllNotes();
                        setState(() {
                          noteList = new List<Note>();
                        });
                        Navigator.of(context).pop();
                      },
                      declineFunction: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              }
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Theme',
                  child: Text(
                      _themeType,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  )

                ),
                PopupMenuItem(
                  value: 'Delete',
                  child: Text(
                    "Delete All Notes",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                )
              ];
            },
          ),
        ],
        title: Text('All Notes'),
      ),
      body: noteList.length == 0
      ? AnimatedContainer(
        duration: Duration(milliseconds: 200),
        color: !widget.darkThemeEnabled ? Colors.black54 :Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Click on the add button to add a new note!',
                style: Theme.of(context).textTheme.body1),
          ),
        ),
      )
          : AnimatedContainer(
        duration: Duration(milliseconds: 200),
        color: !widget.darkThemeEnabled ? Colors.black45:Colors.white,
        child: getNotesList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', ''), 'Add Note',widget.darkThemeEnabled,false);
        },
        tooltip: 'Add Note',
        shape: CircleBorder(side: BorderSide(color: !widget.darkThemeEnabled ? Colors.redAccent:Colors.indigo, width: 6.0)),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: !widget.darkThemeEnabled ? Colors.redAccent:Colors.indigo,
      ),
    );
  }

  Widget getNotesList() {
    return StaggeredGridView.countBuilder(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 4,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
        onTap: () {
          navigateToDetail(this.noteList[index], 'Edit Note', widget.darkThemeEnabled,true);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: !widget.darkThemeEnabled ? Colors.black54 :Colors.white,
              boxShadow: [BoxShadow(
                color: !widget.darkThemeEnabled ? Colors.black12 :Colors.grey,
                offset: const Offset(
                  5.0,
                  5.0,
                ),
                blurRadius: 20.0,
                spreadRadius: 4.0,
              ), //BoxShadow
              BoxShadow(
                color: Colors.white,
                offset: const Offset(0.0, 0.0),
                blurRadius: 0.0,
                spreadRadius: 0.0,
              ),
            ],//BoxShadow
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: !widget.darkThemeEnabled ? Colors.black12 :Colors.blueGrey,
                  width: 3,
                )
            ),
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          this.noteList[index].title,
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child:
                            Text(this.noteList[index].date,
                                style: Theme.of(context).textTheme.subtitle),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                            this.noteList[index].description == null
                                ? ''
                                : this.noteList[index].description,
                            style: Theme.of(context).textTheme.body2),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  void updateListView() {
 databaseHelper.initializeDatabase();
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
  }

  void navigateToDetail(Note note, String title, bool darkThemeEnabled, bool editFlag) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddNoteScreen(note, title,darkThemeEnabled,editFlag)));

    if (result == true) {
      updateListView();
    }
  }
}
