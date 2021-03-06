import 'dart:io';

import 'package:essential_rest/essential_rest.dart';

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

void main() async {
  print('start execution');
  var rest = RestClientGeneric<ExampleModel>(factory: {ExampleModel: (x) => ExampleModel.fromMap(x)});
  rest.protocol = ProtocolType.https;
  rest.host = 'jsonplaceholder.typicode.com';

  //get list of ExampleModel
  print('get list of ExampleModel');
  var resp = await rest.getAll('/todos');
  var list = resp.resultListT;
  list.forEach((item) {
    print('list item: ${item.title}');
  });

  //get single ExampleModel
  resp = await rest.get('/todos/1');
  var item = resp.resultT;
  print('single item: ${item.title}');

  //create new item ExampleModel
  var resps = await rest.post('/todos', body: ExampleModel(title: 'test').toMap());
  print('create item: ${resps.status}');
  print('end execution');
  exit(0);
}
