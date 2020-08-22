import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _inputItenController = TextEditingController();
  Color blackModeTop = Colors.blueAccent;
  Color blackModeall = Colors.white;
  Color blackModebody = Colors.blue;
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;
  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _inputItenController.text;
      _inputItenController.text = "";
      newTodo["ok"] = false;
      _toDoList.add(newTodo);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _toDoList.sort((firstItem, secItem) {
        if (firstItem["ok"] && !secItem["ok"]) {
          return 1;
        } else if (!firstItem["ok"] && secItem["ok"]) {
          return -1;
        } else {
          return 0;
        }
      });
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackModeall,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.check_circle),
              tooltip: 'black mode',
              onPressed: () {
                setState(() {
                  blackModeTop = Colors.black;
                  blackModebody = Colors.black;
                  blackModeall = Colors.blueGrey;
                });
              }),
          IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'blue mode',
              onPressed: () {
                setState(() {
                  blackModeall = Colors.white;
                  blackModeTop = Colors.blue;
                  blackModebody = Colors.blue;
                });
              }),
        ],
        title: Text(
          "Lista de Tarefas            Modes:",
          style: TextStyle(fontSize: 20.0),
        ),
        backgroundColor: blackModeTop,
        centerTitle: false,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle:
                            TextStyle(color: blackModebody, fontSize: 15.0)),
                    controller: _inputItenController,
                  ),
                ),
                RaisedButton(
                  color: blackModebody,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _toDoList.length,
                  itemBuilder: _buildItem),
            ),
          )
        ],
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    print("${directory.path}/data.json");
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (ErroToRead) {
      return ErroToRead.toString();
    }
  }

  Widget _buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          backgroundColor: blackModeTop,
          child: Icon(
            _toDoList[index]["ok"] ? Icons.check_circle : Icons.error,
            color: Colors.white,
          ),
        ),
        onChanged: (onPressCheck) {
          setState(() {
            _toDoList[index]["ok"] = onPressCheck;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa ${_lastRemoved["title"]} Removida."),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }
}
