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
            ListView.builder(
              padding: EdgeInsets.only(top:10.0),
              itemCount: _todoList.length,
              itemBuilder: (context,index){
                return CheckboxListTile(
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
                );
              }
            )
          )
        ],
      ),
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





