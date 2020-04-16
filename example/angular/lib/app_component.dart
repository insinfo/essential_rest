import 'package:angular/angular.dart';
import 'package:essential_rest/essential_rest.dart';

import './models/example_model.dart';
import './services/example_service.dart';
import './pages/upload_example/upload_example.dart';
import './pages/rest_api_example/rest_api_example.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [coreDirectives, UploadPage, RestExamplePage],
)
class AppComponent implements OnInit {
  ExampleService service;
  RList<ExampleModel> list;

  AppComponent() {
    service = ExampleService();
  }
  @override
  void ngOnInit() async {
    var resp = await service.getAll();
    list = resp.resultListT;
  }
}
