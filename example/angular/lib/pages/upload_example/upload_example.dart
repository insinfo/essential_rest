import 'package:angular/angular.dart';

//import 'package:universal_html/html.dart' as html;
import 'package:universal_html/prefer_universal/html.dart' as uhtml;
import 'dart:html' as html;

import 'package:essential_rest/essential_rest.dart';


@Component(
    selector: 'upload-page',
    styleUrls: ['upload_example.css'],
    templateUrl: 'upload_example.html',
    directives: [
      coreDirectives,     
    ],
    exports: [],
    providers: [])
class UploadPage implements OnInit {
  //@ViewChild('fileInput')
  //html.FileUploadInputElement fileInput;

  UploadPage();

  @override
  void ngOnInit() {}

  void upload(e) async {
    var fileInput = html.querySelector('body #fileInput') as html.FileUploadInputElement;   
    if (fileInput != null && fileInput.files.isNotEmpty) {
      var rest = RestClientGeneric();     
      var resp = await rest.uploadFiles(
        '/',
        fileInput.files as List<uhtml.File>,
        body: {'nome': 'Isaque'},
        protocol: 'http',
        hosting: 'localhost',
        hostPort: 8888,
        basePath: '',
      );
      print(resp.data);
    }
  }
}
