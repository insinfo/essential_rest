import 'package:essential_rest/essential_rest.dart';
import 'package:essential_rest/src/response_list.dart';

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

  @override
  Map<String, dynamic> toMap() {
    final data = Map<String, dynamic>();
    data['userId'] = userId;
    data['id'] = id;
    data['title'] = title;
    data['completed'] = completed;
    return data;
  }
}

void main() async {
  var rest = RestClientGeneric<ExampleModel>(factory: {ExampleModel: (x) => ExampleModel.fromMap(x)});
  rest.protocol = ProtocolType.https;
  rest.host = 'jsonplaceholder.typicode.com';

  //get list of ExampleModel
  var resp = await rest.getAll('/todos');
  RList<ExampleModel> list = resp.resultListT;
  list.forEach((item) {
    print('list item: ${item.title}');
  });

  //get single ExampleModel
  resp = await rest.get('/todos/1');
  var item = resp.resultT;
  print('single item: ${item.title}');

  //create new item
  resp = await rest.post('/todos', body: ExampleModel(title: 'test').toMap());
  print('create item: ${resp.status}');
}
