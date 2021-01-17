import 'package:flutter/material.dart';
import 'package:flutter_note_app/model/notes.dart';
import 'package:flutter_note_app/utils/db_helper.dart';
import 'package:flutter_note_app/utils/theme_bloc.dart';
import 'package:flutter_note_app/utils/theme_data.dart';
import 'package:flutter_note_app/widgets/alertdialog_widget.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNoteScreen extends StatefulWidget {
  final String  title;
  final Note  note;
  final bool darkThemeEnabled;
  final bool editFlag;
  AddNoteScreen(this.note, this.title, this.darkThemeEnabled, this.editFlag,);

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  bool _isEditiable = false;
  String title = 'Add Note';
  List<Widget> icons;
  String _themeType;
  String appBarTitle;
  TextEditingController _titleController = TextEditingController();
  TextEditingController __noteControllor = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final DatabaseHelper helper = DatabaseHelper();

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


  _setPref(bool res) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkTheme', res);
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = widget.note.title != null ? widget.note.title : '' ;
    __noteControllor.text = widget.note.description != null ? widget.note.description : '' ;
    return WillPopScope(
        onWillPop: () {
          _isEditiable ? showDiscardDialog(context) : moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
              )


            ),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  _isEditiable ? showDiscardDialog(context) : moveToLastScreen();
                }),
            actions: <Widget>[
              Visibility(
                  child: IconButton(
                    onPressed: () {
                      Share.share(widget.note.title+'\n\n'+widget.note.date+'\n\n'+widget.note.description);
                    },
                    icon: Icon(Icons.share),
                  ),
                visible: widget.editFlag,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  showDeleteDialog(context);
                },
              ),
              PopupMenuButton<bool>(
                onSelected: (res) {
                  bloc.changeTheme(!Themes.darkThemeEnabled);
                  _setPref(Themes.darkThemeEnabled);
                  setState(() {
                    if (_themeType == 'Dark Theme') {
                      _themeType = 'Light Theme';
                      Themes.darkThemeEnabled = false;
                    } else {
                      _themeType = 'Dark Theme';
                      Themes.darkThemeEnabled = true;
                    }
                  });
                },
                itemBuilder: (context) {
                  return <PopupMenuEntry<bool>>[
                    PopupMenuItem<bool>(
                      value: Themes.darkThemeEnabled,
                      child: Text(_themeType),
                    )
                  ];
                },
              )
            ],
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _titleController,
                    maxLength: 255,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      height:1.3,
                      color : !Themes.darkThemeEnabled ? Colors.white :Colors.black,
                    ),
                    onChanged: (value) {
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color : !Themes.darkThemeEnabled ? Colors.white :Colors.grey,
                        )
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      height: 300,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        maxLength: 300,
                        controller: __noteControllor,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          height:1.3,
                          color : !Themes.darkThemeEnabled ? Colors.white :Colors.black,
                        ),
                        onChanged: (value) {
                          updateDescription();
                        },
                        decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color : !Themes.darkThemeEnabled ? Colors.white :Colors.grey,
                            )
                        ),
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _titleController.text.length == 0
                  ? showEmptyTitleDialog(context)
                  : _save();
            },
            tooltip: 'Save',
            shape: CircleBorder(side: BorderSide(color: !Themes.darkThemeEnabled ? Colors.redAccent:Colors.indigo, width: 6.0)),
            child: Icon(Icons.save, color: Colors.white),
            backgroundColor: !Themes.darkThemeEnabled ? Colors.redAccent:Colors.indigo,
          ),
        ));
  }

  void showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialogWidget(
          contentTitle: "Discard Changes",
          contentText: "Are you sure you want to discard changes?",
          confirmFunction: () async {
            Navigator.of(context).pop();
            moveToLastScreen();
          },
          declineFunction: () {
            Navigator.of(context).pop();
            },
        );
      },
    );
  }

  void showEmptyTitleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Title is empty!",
            style: Theme.of(context).textTheme.body1,
          ),
          content: Text('The title of the note cannot be empty.',
              style: Theme.of(context).textTheme.body2),
          actions: <Widget>[
            FlatButton(
              child: Text("Okay",
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },


    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialogWidget(
          contentTitle: "Delete Note?",
          contentText: "Are you sure you want to delete this note?",
          confirmFunction: () async {
            Navigator.of(context).pop();
            _delete();
          },
          declineFunction: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateTitle() {
    _isEditiable = true;
    widget.note.title = _titleController.text;
  }

  void updateDescription() {
    _isEditiable = true;
    widget.note.description = __noteControllor.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    widget.note.date = DateFormat.yMMMd().format(DateTime.now());

    if (widget.note.id != null) {
      await helper.updateNote(widget.note);
    } else {
      await helper.insertNote(widget.note);
    }
  }

  void _delete() async {
    await helper.deleteNote(widget.note.id);
    moveToLastScreen();
  }
}
