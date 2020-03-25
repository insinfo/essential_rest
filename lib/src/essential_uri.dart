//import 'html_fake.dart' if (condition) 'dart:html';
import 'package:universal_html/prefer_universal/html.dart';

///The protocol of the URL. Possible values:
///file: ftp: http: https: mailto: etc..
enum ProtocolType { http, https, notDefine }

/*class EssentialUri {
  String host;
  int port;
  String basePath = '';
  ProtocolType protoType;
  String defaultHost = 'local.riodasostras.rj.gov.br';

  static EssentialUri _instance;
  EssentialUri getInstance() {
    _instance ??= EssentialUri();
    return _instance;
  }

  Uri uri(
    String apiEndPoint, {
    Map<String, String> queryParameters,
    String basePathParam,
    String protocol,
    String hosting,
    int hostPort,
  }) {
    if (apiEndPoint == null) {
      throw Exception('UriMuProto: api Endpoint cannot be null or empty');
    }

    basePath = basePathParam != null ? basePathParam : basePath;

    basePath ??= '';

    apiEndPoint = '$basePath$apiEndPoint';

    var proLen = window.location.protocol.length;

    print(window.location.protocol);

    var prot = '';
    if (protocol != null) {
      prot = protocol;
    } else if (protoType == ProtocolType.notDefine || protoType == null) {
      prot = window.location.protocol.substring(0, proLen - 1);
    } else if (protoType == ProtocolType.https) {
      prot = 'https';
    } else if (protoType == ProtocolType.http) {
      prot = 'http';
    }
    var h = host;

    h ??= window.location.host.contains(':') ? defaultHost : window.location.host;

    queryParameters ??= {};

    if (hosting != null) {
      h = hosting;
    }

    var prt = port;
    if (hostPort != null) {
      prt = hostPort;
    }

    return Uri(
        scheme: prot,
        userInfo: '',
        host: h,
        port: prt,
        pathSegments: apiEndPoint.split('/'),
        queryParameters: queryParameters);
  }
}
*/