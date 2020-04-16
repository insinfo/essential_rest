import 'package:angular/angular.dart';
import 'package:example/models/example_model.dart';
import 'package:example/services/example_service.dart';

//import 'package:universal_html/html.dart' as html;
import 'package:universal_html/prefer_universal/html.dart' as uhtml;
import 'dart:html' as html;

import 'package:essential_rest/essential_rest.dart';

@Component(
    selector: 'rest-example',
    styleUrls: ['rest_api_example.css'],
    templateUrl: 'rest_api_example.html',
    directives: [
      coreDirectives,
    ],
    exports: [],
    providers: [])
class RestExamplePage implements OnInit {
  //@ViewChild('fileInput')
  //html.FileUploadInputElement fileInput;

  ExampleService service;
  RList<ExampleModel> list;

  RestExamplePage() {
    service = ExampleService();
  }
  
  @override
  void ngOnInit() async {
    var resp = await service.getAll();
    list = resp.resultListT;
  }
}
