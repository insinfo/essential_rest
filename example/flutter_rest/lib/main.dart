import 'package:flutter/material.dart';
import 'package:essential_rest/essential_rest.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Essential Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Essential Rest Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RList<ExampleModel> list = RList<ExampleModel>();
  var rest = RestClientGeneric<ExampleModel>(
      factory: {ExampleModel: (x) => ExampleModel.fromMap(x)});

  @override
  void initState() {
    super.initState();
    rest.protocol = ProtocolType.https;
    rest.host = 'jsonplaceholder.typicode.com';
    getData();
  }

  Future getData() async {
    //get list of ExampleModel
    var resp = await rest.getAll('/todos');
    setState(() {
      list = resp.resultListT;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Text(list[index].title);
          }),
    );
  }
}

//entity model definition
class ExampleModel {
  int id;
  int userId;
  String title;
  bool completed;

  ExampleModel({this.userId, this.id, this.title, this.completed});

  ExampleModel.fromMap(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    title = json['title'];
    completed = json['completed'];
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['userId'] = userId;
    data['id'] = id;
    data['title'] = title;
    data['completed'] = completed;
    return data;
  }
}
