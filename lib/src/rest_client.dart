import 'dart:async';
import 'dart:convert';
//import 'html_fake.dart' if (condition) 'dart:html';
//import 'package:universal_html/prefer_universal/html.dart';

//import 'package:universal_html/prefer_universal/html.dart' if (dart.library.io) 'package:universal_html/html.dart';
//export '../src/html.dart' if (dart.library.html) '../src/_sdk/html.dart';

import 'package:universal_html/prefer_universal/html.dart' if (dart.library.js) 'package:universal_html/html.dart';

import 'package:http/http.dart' as http;
import 'essential_uri.dart';
import 'rest_response.dart';

class RestClient {
  http.Client client;
  ProtocolType protocol;

  bool setHostFromBrowser = false;
  String defaultHost = 'local.riodasostras.rj.gov.br';
  String host;
  int port;
  String basePath = '';

  static RestClient _instance;
  RestClient getInstance() {
    _instance ??= RestClient();
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

  RestClient({this.basePath}) {
    client = http.Client();
  }

  Future<RestResponse> get(
    String apiEndPoint, {
    RestClientMethod method,
    Map<String, dynamic> body,
    Map<String, String> headers,
    Map<String, String> queryParameters,
    String basePath,
    String protocol,
    String hosting,
    int hostPort,
  }) async {
    var url = uri(
      apiEndPoint,
      queryParameters: queryParameters,
      host: hosting,
      basePath: basePath,
      protocol: protocol,
      port: hostPort,
    );

    headers ??= headersDefault;

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
    var jsonDecoded = jsonDecode(resp.body);

    if (resp.statusCode == 200) {
      return RestResponse(
          totalRecords: totalRecords,
          message: 'Sucesso',
          status: RestStatus.SUCCESS,
          data: jsonDecoded,
          statusCode: resp.statusCode);
    }
    var message = '${resp.body}';
    var exception = '${resp.body}';

    //exibe mensagem se der erro não autorizado
    if (resp.statusCode == 401) {
      if (jsonDecoded is Map) {
        if (jsonDecoded.containsKey('message')) {
          message = jsonDecoded['message'];
        }
        if (jsonDecoded.containsKey('exception')) {
          exception = jsonDecoded['exception'];
        }
      }

      return RestResponse(message: message, status: RestStatus.UNAUTHORIZED, statusCode: resp.statusCode);
    }

    if (jsonDecoded is Map) {
      if (jsonDecoded.containsKey('message')) {
        message = jsonDecoded['message'];
      }
      if (jsonDecoded.containsKey('exception')) {
        exception = jsonDecoded['exception'];
      }
    }

    return RestResponse(message: message, exception: exception, status: RestStatus.DANGER, statusCode: resp.statusCode);
  }

  Future<RestResponse> put(
    String apiEndPoint, {
    Map<String, String> headers,
    Map<String, dynamic> body,
    Map<String, String> queryParameters,
    Encoding encoding,
    String basePath,
    String protocol,
    String hosting,
    int hostPort,
  }) async {
    var url = uri(
      apiEndPoint,
      queryParameters: queryParameters,
      host: hosting,
      basePath: basePath,
      protocol: protocol,
      port: hostPort,
    );
    //este operador "??=" é a mesmo que if(x != null)
    encoding ??= Utf8Codec();

    headers ??= headersDefault;

    var resp = await client.put(url, body: jsonEncode(body), encoding: encoding, headers: headers);

    if (resp.statusCode == 200) {
      return RestResponse(
          message: 'Sucesso', status: RestStatus.SUCCESS, data: jsonDecode(resp.body), statusCode: resp.statusCode);
    }
    var jsonDecoded = jsonDecode(resp.body);
    var message = '${resp.body}';
    var exception = '${resp.body}';
    //exibe mensagem se der erro não autorizado
    if (resp.statusCode == 401) {
      if (jsonDecoded is Map) {
        if (jsonDecoded.containsKey('message')) {
          message = jsonDecoded['message'];
        }
        if (jsonDecoded.containsKey('exception')) {
          exception = jsonDecoded['exception'];
        }
      }

      return RestResponse(message: message, status: RestStatus.UNAUTHORIZED, statusCode: resp.statusCode);
    }

    if (jsonDecoded is Map) {
      if (jsonDecoded.containsKey('message')) {
        message = jsonDecoded['message'];
      }
      if (jsonDecoded.containsKey('exception')) {
        exception = jsonDecoded['exception'];
      }
    }

    return RestResponse(message: message, exception: exception, status: RestStatus.DANGER, statusCode: resp.statusCode);
  }

  Future<RestResponse> post(
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
    var url = uri(
      apiEndPoint,
      queryParameters: queryParameters,
      host: hosting,
      basePath: basePath,
      protocol: protocol,
      port: hostPort,
    );

    headers ??= headersDefault;

    var resp = await client.post(url, body: jsonEncode(body), encoding: Utf8Codec(), headers: headers);

    if (resp.statusCode == 200) {
      return RestResponse(
          message: 'Sucesso', status: RestStatus.SUCCESS, data: jsonDecode(resp.body), statusCode: resp.statusCode);
    }

    var jsonDecoded = jsonDecode(resp.body);
    var message = '${resp.body}';
    var exception = '${resp.body}';
    //exibe mensagem se der erro não autorizado
    if (resp.statusCode == 401) {
      if (jsonDecoded is Map) {
        if (jsonDecoded.containsKey('message')) {
          message = jsonDecoded['message'];
        }
        if (jsonDecoded.containsKey('exception')) {
          exception = jsonDecoded['exception'];
        }
      }

      return RestResponse(message: message, status: RestStatus.UNAUTHORIZED, statusCode: resp.statusCode);
    }

    if (jsonDecoded is Map) {
      if (jsonDecoded.containsKey('message')) {
        message = jsonDecoded['message'];
      }
      if (jsonDecoded.containsKey('exception')) {
        exception = jsonDecoded['exception'];
      }
    }

    return RestResponse(message: message, exception: exception, status: RestStatus.DANGER, statusCode: resp.statusCode);
  }

  Future<RestResponse> deleteAll(
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
    var url = uri(
      apiEndPoint,
      queryParameters: queryParameters,
      host: hosting,
      basePath: basePath,
      protocol: protocol,
      port: hostPort,
    );

    headers ??= headersDefault;

    var request = HttpRequest();
    request.open('delete', url.toString());
    request.setRequestHeader('Content-Type', 'application/json');
    request.send(json.encode(body));

    await request.onLoadEnd.first;
    //await request.onReadyStateChange.first;

    var jsonDecoded = jsonDecode(request.responseText);
    if (request.status == 200) {
      return RestResponse(
          message: 'Sucesso',
          status: RestStatus.SUCCESS,
          data: jsonDecode(request.responseText),
          statusCode: request.status);
    }
    var message = '${request.responseText}';
    var exception = '${request.responseText}';
    //exibe mensagem se der erro não autorizado
    if (request.status == 401) {
      if (jsonDecoded is Map) {
        if (jsonDecoded.containsKey('message')) {
          message = jsonDecoded['message'];
        }
        if (jsonDecoded.containsKey('exception')) {
          exception = jsonDecoded['exception'];
        }
      }

      return RestResponse(message: message, status: RestStatus.UNAUTHORIZED, statusCode: request.status);
    }
    //

    if (jsonDecoded is Map) {
      if (jsonDecoded.containsKey('message')) {
        message = jsonDecoded['message'];
      }
      if (jsonDecoded.containsKey('exception')) {
        exception = jsonDecoded['exception'];
      }
    }

    return RestResponse(message: message, exception: exception, status: RestStatus.DANGER, statusCode: request.status);
  }
}
