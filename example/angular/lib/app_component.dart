import 'package:angular/angular.dart';
import 'package:essential_rest/essential_rest.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [coreDirectives],
)
class AppComponent implements OnInit {
  RList<ExampleModel> list;
  @override
  void ngOnInit() async {
    var rest = RestClientGeneric<ExampleModel>(factory: {ExampleModel: (x) => ExampleModel.fromMap(x)});
    rest.protocol = ProtocolType.https;
    rest.host = 'jsonplaceholder.typicode.com';

    //get list of ExampleModel
    var resp = await rest.getAll('/todos');
    list = resp.resultListT;
    /*list.forEach((item) {
      print('list item: ${item.title}');
    });*/
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

  @override
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['userId'] = userId;
    data['id'] = id;
    data['title'] = title;
    data['completed'] = completed;
    return data;
  }
}
