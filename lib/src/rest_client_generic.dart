import 'dart:async';
import 'dart:convert';
//import 'html_fake.dart' if (condition) 'dart:html';

import 'package:universal_html/prefer_universal/html.dart' if (dart.library.js) 'package:universal_html/html.dart';
//;
//import 'dart:html' if (dart.library.html) 'html_fake.dart';

import 'essential_uri.dart';
//import 'map_serialization.dart';
import 'rest_response.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'response_list.dart';

/// is an API to consume REST web services, it does the JSON mapping for the Entity,
/// besides allowing to keep the data in CACHE using Local Storage for fast loading 
/// and load reduction to the Server
class RestClientGeneric<T> {
  final Map<Type, Function> factory; // = <Type, Function>{};
  //ex: DiskCache<Agenda>(factories: {Agenda: (x) => Agenda.fromJson(x)});

  //cache duration
  Duration cacheValidDuration = Duration(minutes: 30);
  //disabilita o cache
  bool _disableAllCache = true;

  bool get disableAllCache {
    return _disableAllCache;
  }

  set disableAllCache(bool disable) {
    _disableAllCache = disable;
  }

  //check if is update the cache
  bool _isShouldRefresh(String key) {
    return (isInLocalStorage(key) == false ||
        _getLastFetchTime(key) == null ||
        _getLastFetchTime(key).isBefore(DateTime.now().subtract(cacheValidDuration)));
  }

  http.Client client;
  ProtocolType protocol;

  bool setHostFromBrowser = false;
  String defaultHost = 'local.riodasostras.rj.gov.br';
  String host;
  int port;
  String basePath = '';

  //EssentialUri _uriMuProto;
  static RestClientGeneric _instance;
  RestClientGeneric getInstance() {
    _instance ??= RestClientGeneric();
    return _instance;
  }

  static Map<String, String> headersDefault = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ' + window.sessionStorage['YWNjZXNzX3Rva2Vu'].toString()
  };

  Uri uri(
    String apiEndPoint, {
    Map<String, String> queryParameters,
    String basePath,
    String protocol,
    String host,
    int port,
  }) {
    if (apiEndPoint == null) {
      throw Exception('UriMuProto: api Endpoint cannot be null or empty');
    }

    if (basePath != null) {
      this.basePath = basePath;
    }

    if (host != null) {
      this.host = host;
    }

    if (this.host == null) {
      this.host = window.location.host.contains(':') ? defaultHost : window.location.host;
    }

    if (setHostFromBrowser) {
      this.host = window.location.host;
    }

    if (port != null) {
      this.port = port;
    }

    this.basePath ??= '';
    apiEndPoint = '${this.basePath}$apiEndPoint';
    var proLen = window.location.protocol.length;

    var scheme = '';
    if (protocol != null) {
      scheme = protocol;
    } else if (this.protocol == ProtocolType.notDefine || this.protocol == null) {
      scheme = window.location.protocol.substring(0, proLen - 1);
      if (window.location.protocol.contains('memory')) {
        scheme = 'http';
      }
    } else if (this.protocol == ProtocolType.https) {
      scheme = 'https';
    } else if (this.protocol == ProtocolType.http) {
      scheme = 'http';
    }

    //queryParameters ??= {};

    return Uri(
        scheme: scheme,
        userInfo: '',
        host: this.host,
        port: this.port,
        pathSegments: apiEndPoint.split('/'),
        queryParameters: queryParameters);
  }

  RestClientGeneric({this.factory}) {
    client = http.Client();
  }

  /// Todo implementar
  /*Future<RestResponseGeneric<T>> getAllT<T>(String apiEndPoint,
      {bool forceRefresh = false, String topNode, Map<String, String> headers, Map<String, String> queryParameters}) {
    throw UnimplementedError('This feature is not implemented yet.');
    return null;
  }*/

  /// This method allows uploading files within the Web Browser
  /// ```dart
  ///  var fileInput = html.querySelector('body #fileInput') as html.FileUploadInputElement;
  ///  if (fileInput != null && fileInput.files.isNotEmpty) {
  ///    var rest = RestClientGeneric();
  ///    var resp = await rest.uploadFiles(
  ///      '/',
  ///      fileInput.files as List<uhtml.File>,
  ///      body: {'nome': 'Isaque'},
  ///      protocol: 'http',
  ///      hosting: 'localhost',
  ///      hostPort: 8888,
  ///      basePath: '',
  ///    );
  ///    print(resp.data);
  ///  }
  /// ```
  /// [apiEndPoint] endpoint is the location from which APIs can access the resources 
  /// [files] is list of dart:html File implementation
  Future<RestResponseGeneric<T>> uploadFiles(
    String apiEndPoint,
    List<dynamic> files, {
    String topNode,
    Map<String, String> headers,
    Map<String, dynamic> body,
    Map<String, String> queryParameters,
    String basePath,
    String protocol,
    String hosting,
    int hostPort,
  }) async {
    try {
      var url = uri(
        apiEndPoint,
        queryParameters: queryParameters,
        protocol: protocol,
        host: hosting,
        port: hostPort,
        basePath: basePath,
      );

      var headersDefault = {
        //'Content-type': 'application/json',
        // 'Accept': 'application/json',
        'Authorization': 'Bearer ' + window.sessionStorage['YWNjZXNzX3Rva2Vu'].toString()
      };
      var request = http.MultipartRequest('POST', url);

      if (headers != null) {
        request.headers.addAll(headers);
      } else {
        request.headers.addAll(headersDefault);
      }

      if (body != null) {
        request.fields['data'] = jsonEncode(body);
      }

      if (files != null && files is File) {
        var reader = FileReader();
        for (var file in files) {
          reader.readAsArrayBuffer(file);
          await reader.onLoadEnd.first;
          request.files.add(await http.MultipartFile.fromBytes('file[]', reader.result,
              contentType: MediaType('application', 'octet-stream'), filename: file.name));
        }
      } else {
        throw Exception('RestClientGeneric@uploadFiles files cannot be null');
      }

      //fields.forEach((k, v) => request.fields[k] = v);
      var streamedResponse = await request.send();
      var resp = await http.Response.fromStream(streamedResponse);
      var respJson = jsonDecode(resp.body);

      return RestResponseGeneric<T>(
        headers: resp.headers,
        data: respJson,
        message: 'Sucesso',
        status: RestStatus.SUCCESS,
        statusCode: 200,
      );
    } catch (e, stacktrace) {
      print('RestClientGeneric@uploadFiles exception: ${e} stacktrace: ${stacktrace}');
      return RestResponseGeneric(message: 'Erro ${e}', status: RestStatus.DANGER, statusCode: 400);
    }
  }

  Future<RestResponseGeneric<T>> getAll(
    String apiEndPoint, {
    bool forceRefresh = false,
    String topNode,
    RestClientMethod method,
    Map<String, dynamic> body,
    Map<String, String> headers,
    Map<String, String> queryParameters,
    String basePath,
    String protocol,
    String hosting,
    int hostPort,
    String encoding,
  }) async {
    try {
      var url = uri(
        apiEndPoint,
        queryParameters: queryParameters,
        protocol: protocol,
        host: hosting,
        port: hostPort,
        basePath: basePath,
      );

      headers ??= headersDefault;

      //Obtem da REST API se o cache estiver vazio, vencido ou desativado
      if (_isShouldRefresh(url.toString()) || forceRefresh || disableAllCache) {
        //var resp = await client.get(url, headers: headers);
        http.Response resp;
        if (method == null) {
          resp = await client.get(url, headers: headers);
        } else if (method == RestClientMethod.POST) {
          resp = await client.post(url, headers: headers, body: jsonEncode(body));
        } else {
          resp = await client.get(url, headers: headers);
        }

        var totalReH = resp.headers.containsKey('total-records') ? resp.headers['total-records'] : null;
        var totalRecords = totalReH != null ? int.tryParse(totalReH) : 0;
        var message = '${resp.body}';
        var exception = '${resp.body}';

        var respBody = resp.body;
        if (encoding == 'utf8') {
          //String.fromCharCodes
          respBody = utf8.decode(resp.bodyBytes);
        }

        var jsonDecoded = jsonDecode(respBody);
        //print("from API");
        if (resp.statusCode == 200) {
          //coloca no cache
          if (disableAllCache == false) {
            _setToLocalStorage(url.toString(), resp.body, headers: resp.headers);
          }

          var list = RList<T>();
          list.totalRecords = totalRecords;
          if (topNode != null) {
            jsonDecoded[topNode].forEach((item) {
              list.add(factory[T](item));
            });
          } else {
            jsonDecoded.forEach((item) {
              list.add(factory[T](item));
            });
          }

          return RestResponseGeneric<T>(
              headers: resp.headers,
              totalRecords: totalRecords,
              message: 'Sucesso',
              status: RestStatus.SUCCESS,
              dataTypedList: list,
              statusCode: resp.statusCode);
        }
        //exibe mensagem se de erro de não autorizado
        if (resp.statusCode == 401) {
          var jsonDecoded = jsonDecode(resp.body);
          if (jsonDecoded is Map) {
            if (jsonDecoded.containsKey('message')) {
              message = jsonDecoded['message'];
            }
            if (jsonDecoded.containsKey('exception')) {
              exception = jsonDecoded['exception'];
            }
          }

          return RestResponseGeneric<T>(
              message: message, exception: exception, status: RestStatus.UNAUTHORIZED, statusCode: resp.statusCode);
        }
        //um item ja cadastrado
        if (resp.statusCode == 409) {
          var jsonDecoded = jsonDecode(resp.body);
          if (jsonDecoded is Map) {
            if (jsonDecoded.containsKey('message')) {
              message = jsonDecoded['message'];
            }
            if (jsonDecoded.containsKey('exception')) {
              exception = jsonDecoded['exception'];
            }
          }
          return RestResponseGeneric<T>(
              message: message, exception: exception, status: RestStatus.CONFLICT, statusCode: resp.statusCode);
        }
        //204 no content tabela vazia ou nenhum item correspondente
        else if (resp.statusCode == 204) {
          return RestResponseGeneric<T>(
              message: 'no content found',
              exception: exception,
              status: RestStatus.NOCONTENT,
              statusCode: resp.statusCode);
        }

        //
        else {
          return RestResponseGeneric<T>(
              message: message, exception: exception, status: RestStatus.DANGER, statusCode: resp.statusCode);
        }
      }

      //print("from Cache");

      Map result = _getAllFromCache(url.toString());
      RList list = result['data'];
      var totalRecords;
      if (result['headers'].containsKey('total-records')) {
        totalRecords = int.tryParse(result['headers']['total-records']);
        list.totalRecords = totalRecords;
      }

      return RestResponseGeneric<T>(
          headers: result['headers'],
          totalRecords: totalRecords,
          message: 'Sucesso',
          status: RestStatus.SUCCESS,
          dataTypedList: list,
          statusCode: 200);
    } catch (e) {
      print('RestClientGeneric@getAll ${e}');
      return RestResponseGeneric(message: 'Erro ${e}', status: RestStatus.DANGER, statusCode: 400);
    }
  }

  Future<RestResponseGeneric<T>> get(
    String apiEndPoint, {
    bool forceRefresh = false,
    String topNode,
    RestClientMethod method,
    Map<String, dynamic> body,
    Map<String, String> headers,
    Map<String, String> queryParameters,
    String basePath,
    String protocol,
    String hosting,
    int hostPort,
    String encoding,
  }) async {
    try {
      var url = uri(
        apiEndPoint,
        queryParameters: queryParameters,
        protocol: protocol,
        host: hosting,
        port: hostPort,
        basePath: basePath,
      );

      headers ??= headersDefault;

      //Obtem da REST API se o cache estivar vazio ou vencido
      if (_isShouldRefresh(url.toString()) || forceRefresh || disableAllCache) {
        //var resp = await client.get(url, headers: headers);
        http.Response resp;
        if (method == null) {
          resp = await client.get(url, headers: headers);
        } else if (method == RestClientMethod.POST) {
          resp = await client.post(url, headers: headers, body: jsonEncode(body));
        } else {
          resp = await client.get(url, headers: headers);
        }

        var message = '${resp.body}';
        var exception = '${resp.body}';
        var totalReH = resp.headers.containsKey('total-records') ? resp.headers['total-records'] : null;
        var totalRecords = totalReH != null ? int.tryParse(totalReH) : 0;
        //se ouver sucesso
        if (resp.statusCode == 200) {
          //coloca no cache
          if (disableAllCache) {
            _setToLocalStorage(url.toString(), resp.body, headers: resp.headers);
          }

          var result;
          var respBody = resp.body;

          if (encoding == 'utf8') {
            respBody = utf8.decode(resp.bodyBytes);
          }

          var parsedJson = jsonDecode(respBody);
          if (topNode != null) {
            result = factory[T](parsedJson[topNode]);
          } else {
            result = factory[T](parsedJson); // Empenho.fromJson(json);
          }

          return RestResponseGeneric<T>(
              totalRecords: totalRecords,
              message: 'Sucesso',
              status: RestStatus.SUCCESS,
              dataTyped: result,
              statusCode: resp.statusCode);
        }
        //exibe mensagem se de erro não autorizado
        else if (resp.statusCode == 401) {
          var jsonDecoded = jsonDecode(resp.body);
          if (jsonDecoded is Map) {
            if (jsonDecoded.containsKey('message')) {
              message = jsonDecoded['message'];
            }
            if (jsonDecoded.containsKey('exception')) {
              exception = jsonDecoded['exception'];
            }
          }

          return RestResponseGeneric<T>(
              message: message, exception: exception, status: RestStatus.UNAUTHORIZED, statusCode: resp.statusCode);
        }
        //um item ja cadastrado
        if (resp.statusCode == 409) {
          var jsonDecoded = jsonDecode(resp.body);
          if (jsonDecoded is Map) {
            if (jsonDecoded.containsKey('message')) {
              message = jsonDecoded['message'];
            }
            if (jsonDecoded.containsKey('exception')) {
              exception = jsonDecoded['exception'];
            }
          }
          return RestResponseGeneric<T>(
              message: message, exception: exception, status: RestStatus.CONFLICT, statusCode: resp.statusCode);
        }
        //no content
        else if (resp.statusCode == 204) {
          return RestResponseGeneric<T>(
              message: 'no content found',
              exception: exception,
              status: RestStatus.NOCONTENT,
              statusCode: resp.statusCode);
        } else {
          return RestResponseGeneric<T>(
              message: message, exception: exception, status: RestStatus.DANGER, statusCode: resp.statusCode);
        }
      }

      Map data = _getFromCache(url.toString());
      var result = data['data'];

      return RestResponseGeneric<T>(
          totalRecords: 10, message: 'Sucesso', status: RestStatus.SUCCESS, dataTyped: result, statusCode: 200);
    } catch (e) {
      print('RestClientGeneric@get ${e}');
      return RestResponseGeneric(
          message: 'Erro ${e}', exception: 'Exception ${e}', status: RestStatus.DANGER, statusCode: 400);
    }
  }

  Map<String, dynamic> _getAllFromCache(String key) {
    var obj = _getFromLocalStorage(key);
    if (obj != null) {
      List json = jsonDecode(obj['data']);
      var list = RList<T>();
      json.forEach((item) {
        list.add(factory[T](item));
      });
      //return list;
      return {'data': list, 'headers': obj['headers']};
    } else {
      return null;
    }
  }

  Map<String, dynamic> _getFromCache(String key) {
    var obj = _getFromLocalStorage(key);
    if (obj != null) {
      Map map = jsonDecode(obj['data']);
      //return factories[T](map);
      return {'data': factory[T](map), 'headers': obj['headers']};
    } else {
      return null;
    }
  }

  Map<String, dynamic> _getFromLocalStorage(String key) {
    if (window.localStorage.containsKey(key)) {
      var headers;
      if (window.localStorage.containsKey('headers' + key)) {
        headers = window.localStorage['headers' + key];
      }
      return {'data': window.localStorage[key], 'headers': jsonDecode(headers)};
    } else {
      return null;
    }
  }

  bool isInLocalStorage(String key) {
    if (window.localStorage.containsKey(key)) {
      return true;
    } else {
      return false;
    }
  }

  void _setToLocalStorage(String key, String value, {Map<String, String> headers}) {
    _setLastFetchTime(key, DateTime.now());
    window.localStorage[key] = value;
    if (headers != null) {
      window.localStorage['headers' + key] = jsonEncode(headers);
    }
  }

  DateTime _getLastFetchTime(String key) {
    if (window.localStorage.containsKey('fetchTime' + key)) {
      return DateTime.parse(window.localStorage['fetchTime' + key]);
    } else {
      return null;
    }
  }

  void _setLastFetchTime(String key, DateTime date) {
    window.localStorage['fetchTime' + key] = date.toString();
  }

  Future<RestResponseGeneric> put(
    String apiEndPoint, {
    Map<String, String> headers,
    body,
    Map<String, String> queryParameters,
    Encoding encoding,
    String basePath,
    String protocol,
    String hosting,
    int hostPort,
  }) async {
    try {
      var url = uri(
        apiEndPoint,
        queryParameters: queryParameters,
        protocol: protocol,
        host: hosting,
        port: hostPort,
        basePath: basePath,
      );

      encoding ??= Utf8Codec();
      headers ??= headersDefault;

      var resp = await client.put(url, body: jsonEncode(body), encoding: encoding, headers: headers);
      var message = '${resp.body}';
      var exception = '${resp.body}';

      if (resp.statusCode == 200) {
        return RestResponseGeneric(
            message: 'Sucesso', status: RestStatus.SUCCESS, data: jsonDecode(resp.body), statusCode: resp.statusCode);
      }
      if (resp.statusCode == 401) {
        var jsonDecoded = jsonDecode(resp.body);
        if (jsonDecoded is Map) {
          if (jsonDecoded.containsKey('message')) {
            message = jsonDecoded['message'];
          }
          if (jsonDecoded.containsKey('exception')) {
            exception = jsonDecoded['exception'];
          }
        }

        return RestResponseGeneric<T>(
            message: message, exception: exception, status: RestStatus.UNAUTHORIZED, statusCode: resp.statusCode);
      }
      if (resp.statusCode == 400) {
        var jsonDecoded = jsonDecode(resp.body);
        if (jsonDecoded is Map) {
          if (jsonDecoded.containsKey('message')) {
            message = jsonDecoded['message'];
          }
          if (jsonDecoded.containsKey('exception')) {
            exception = jsonDecoded['exception'];
          }
        }
        return RestResponseGeneric<T>(
            message: message, exception: exception, status: RestStatus.DANGER, statusCode: resp.statusCode);
      }
      //um item ja cadastrado
      if (resp.statusCode == 409) {
        var jsonDecoded = jsonDecode(resp.body);
        if (jsonDecoded is Map) {
          if (jsonDecoded.containsKey('message')) {
            message = jsonDecoded['message'];
          }
          if (jsonDecoded.containsKey('exception')) {
            exception = jsonDecoded['exception'];
          }
        }
        return RestResponseGeneric<T>(
            message: message, exception: exception, status: RestStatus.CONFLICT, statusCode: resp.statusCode);
      }

      return RestResponseGeneric(message: message, status: RestStatus.DANGER, statusCode: resp.statusCode);
    } catch (e) {
      print('RestClientGeneric@put ${e}');
      return RestResponseGeneric(
          message: '${e}', exception: 'Exception ${e}', status: RestStatus.DANGER, statusCode: 400);
    }
  }

  RestStatus _intToStatus(int statusCode) {
    var status = RestStatus.DANGER;
    switch (statusCode) {
      case 200: //SUCCESS
        {
          status = RestStatus.SUCCESS;
        }
        break;
      case 201: //Created
        {
          status = RestStatus.SUCCESS;
        }
        break;
      case 401: //Unauthorized
        {
          status = RestStatus.UNAUTHORIZED;
        }
        break;
      case 400: //Bad Request
        {
          status = RestStatus.DANGER;
        }
        break;
      case 409: //Conflict
        {
          status = RestStatus.CONFLICT;
        }
        break;
      default:
        {
          status = RestStatus.DANGER;
        }
        break;
    }
    return status;
  }

  Future<RestResponseGeneric> post(
    String apiEndPoint, {
    Map<String, String> headers,
    body,
    Map<String, String> queryParameters,
    Encoding encoding,
    String basePath,
    String protocol,
    String hosting,
    int hostPort,
    ReturnType returnType,
  }) async {
    try {
      var url = uri(
        apiEndPoint,
        queryParameters: queryParameters,
        protocol: protocol,
        host: hosting,
        port: hostPort,
        basePath: basePath,
      );

      headers ??= headersDefault;
      encoding ??= Utf8Codec();

      var resp = await client.post(url, body: jsonEncode(body), encoding: encoding, headers: headers);
      var message = '${resp.body}';
      var exception = '${resp.body}';

      var jsonDecoded = jsonDecode(resp.body);
      if (jsonDecoded is Map) {
        if (jsonDecoded.containsKey('message')) {
          message = jsonDecoded['message'];
        }
        if (jsonDecoded.containsKey('exception')) {
          exception = jsonDecoded['exception'];
        }
      }

      return RestResponseGeneric(
        message: message,
        exception: exception,
        status: _intToStatus(resp.statusCode),
        data: jsonDecoded,
        statusCode: resp.statusCode,
      );
    } catch (e) {
      print('RestClientGeneric@post ${e}');
      return RestResponseGeneric(
        message: '${e}',
        exception: 'Exception ${e}',
        status: RestStatus.DANGER,
        statusCode: 400,
      );
    }
  }

  Future<RestResponseGeneric> deleteAll(
    String apiEndPoint, {
    Map<String, String> headers,
    List<Map<String, dynamic>> body,
    Map<String, String> queryParameters,
    Encoding encoding,
    String basePath,
    String protocol,
    String hosting,
    int hostPort,
  }) async {
    try {
      var url = uri(
        apiEndPoint,
        queryParameters: queryParameters,
        protocol: protocol,
        host: hosting,
        port: hostPort,
        basePath: basePath,
      );

      headers ??= headersDefault;

      var request = HttpRequest();
      request.open('delete', url.toString());
      if (headers != null) {
        headers.forEach((key, value) {
          request.setRequestHeader(key, value);
        });
      } else {
        request.setRequestHeader('Content-Type', 'application/json');
      }

      request.send(json.encode(body));

      await request.onLoadEnd.first;
      //await request.onReadyStateChange.first;

      var message = '${request.responseText}';
      var exception = '${request.responseText}';
      if (request.status == 200) {
        return RestResponseGeneric(
            message: 'Sucesso',
            status: RestStatus.SUCCESS,
            data: jsonDecode(request.responseText),
            statusCode: request.status);
      }

      if (request.status == 401) {
        var jsonDecoded = jsonDecode(request.responseText);
        if (jsonDecoded is Map) {
          if (jsonDecoded.containsKey('message')) {
            message = jsonDecoded['message'];
          }
          if (jsonDecoded.containsKey('exception')) {
            exception = jsonDecoded['exception'];
          }
        }

        return RestResponseGeneric<T>(
            message: message, exception: exception, status: RestStatus.UNAUTHORIZED, statusCode: request.status);
      }
      if (request.status == 400) {
        var jsonDecoded = jsonDecode(request.responseText);
        if (jsonDecoded is Map) {
          if (jsonDecoded.containsKey('message')) {
            message = jsonDecoded['message'];
          }
          if (jsonDecoded.containsKey('exception')) {
            exception = jsonDecoded['exception'];
          }
        }
        return RestResponseGeneric<T>(
            message: message, exception: exception, status: RestStatus.DANGER, statusCode: request.status);
      }
      //um item ja cadastrado
      if (request.status == 409) {
        var jsonDecoded = jsonDecode(request.responseText);
        if (jsonDecoded is Map) {
          if (jsonDecoded.containsKey('message')) {
            message = jsonDecoded['message'];
          }
          if (jsonDecoded.containsKey('exception')) {
            exception = jsonDecoded['exception'];
          }
        }
        return RestResponseGeneric<T>(
            message: message, exception: exception, status: RestStatus.CONFLICT, statusCode: request.status);
      }

      return RestResponseGeneric(
          message: message, exception: exception, status: RestStatus.DANGER, statusCode: request.status);
    } catch (e) {
      print('RestClientGeneric@deleteAll ${e}');
      return RestResponseGeneric(
          message: '${e}', exception: 'Exception ${e}', status: RestStatus.DANGER, statusCode: 400);
    }
  }

  Future<RestResponseGeneric> raw(String url, String method,
      {Map<String, String> headers, String body, Encoding encoding}) async {
    try {
      headers ??= headersDefault;

      var request = HttpRequest();
      request.open(method, url);

      if (headers != null) {
        headers.forEach((key, value) {
          request.setRequestHeader(key, value);
        });
      }

      request.send(body);

      await request.onLoadEnd.first;
      //await request.onReadyStateChange.first;

      if (request.status == 200) {
        return RestResponseGeneric(
            message: 'Sucesso', status: RestStatus.SUCCESS, data: request.responseText, statusCode: request.status);
      }
      return RestResponseGeneric(
          data: request.responseText, message: 'Erro', status: RestStatus.DANGER, statusCode: request.status);
    } catch (e) {
      print('RestClientGeneric@raw ${e}');
      return RestResponseGeneric(
          message: '${e}', exception: 'Exception ${e}', status: RestStatus.DANGER, statusCode: 400);
    }
  }
}
