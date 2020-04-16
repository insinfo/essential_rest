import 'package:essential_rest/essential_rest.dart';
import '../models/example_model.dart';

class ExampleService {
  RestClientGeneric rest;
  ExampleService() {
    rest = RestClientGeneric<ExampleModel>(factory: {ExampleModel: (x) => ExampleModel.fromMap(x)});
    rest.protocol = ProtocolType.https;
    rest.host = 'jsonplaceholder.typicode.com';
  }

  ////get list of ExampleModel instance
  Future<RestResponseGeneric<ExampleModel>> getAll() {
    return rest.getAll('/todos');
  }
}
