import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todoController = TextEditingController();
  List _todoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    _readData().then((data){
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }

  void _addTodo(){
     setState(() {
       Map<String,dynamic> newTodo = Map();
       newTodo["title"] = todoController.text;
       todoController.text = "";
       newTodo["ok"] = false;
       _todoList.add(newTodo);
       _saveData();
     });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds:1));
    setState(() {
      _todoList.sort((a,b){
        if(a["ok"] && !b["ok"]) return 1;
        else if(!a["ok"] && b["ok"]) return -1;
        else return 0;
        _saveData();
      });
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de compras"),
        backgroundColor: Colors.lightGreenAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: todoController,
                        decoration: InputDecoration(
                            labelText: "Nova tarefa",
                            labelStyle: TextStyle(color: Colors.lightGreenAccent)
                        )
                    ),
                  ),
                  RaisedButton(
                    color: Colors.lightGreenAccent,
                    child: Icon(Icons.add,size: 25.0,),
                    textColor: Colors.white,
                    onPressed: _addTodo,
                  )
                ],
              ),
            ),
          Expanded(child:
            RefreshIndicator(
              child: ListView.builder(
                  padding: EdgeInsets.only(top:10.0),
                  itemCount: _todoList.length,
                  itemBuilder: (context,index){
                    return buildItem(context,index);
                  }
              ),
              onRefresh: _refresh,
            )
          )
        ],
      ),
    );
  }

  Widget buildItem(context,index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9,0.0),
          child: Icon(Icons.delete,color: Colors.white,),

        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_todoList[index]["title"]),
        value: _todoList[index]["ok"],
        onChanged: (c){
          setState(() {
            _todoList[index]["ok"] = c;
            _saveData();
          });
        },
        secondary: CircleAvatar(
          child: Icon(
              (_todoList[index]["ok"] ? Icons.check : Icons.error)
          ),
        ),
      ),
      onDismissed: (dismissed){
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPos = index;
          _todoList.removeAt(index);
          _saveData();
          final snack = SnackBar(
            content: Text("Tarefa ${_lastRemoved["title"]} removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  _todoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 5),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async{
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async{
    try{
      final file = await _getFile();
      return file.readAsString();
    }catch(e){

        print(e);
        return null;
    }
  }
}





