/*import 'dart:collection';

class Window {
  Storage get sessionStorage {
    return Storage();
  }

  Storage get localStorage {
    return Storage();
  }

  Location get location => Location();
}

Window get window {
  return Window();
}

class Location {
  String host = 'localhost'; 
  String protocol = 'http';
}

class Storage with MapMixin<String, String> {
  final _map = {'YWNjZXNzX3Rva2Vu': 'test'};

  @override
  String operator [](Object key) {
    return _map[key];
  }

  @override
  void operator []=(String key, String value) {
    _map[key] = value;
  }

  @override
  void clear() {
    _map.clear();
  }

  @override
  Iterable<String> get keys => _map.keys;

  @override
  String remove(Object key) {
    return _map.remove(key);
  }
}

class Blob {}

class File extends Blob {
  // To suppress missing implicit constructor warnings.
  factory File._() {
    throw UnsupportedError('Not supported');
  }
  String name;
}

class ProgressEvent {}

class FileReader {
  void readAsArrayBuffer(blob) {}
  Stream<ProgressEvent> get onLoadEnd {
    return null;
  }

  List<int> get result {
    return [1];
  }
}

class HttpRequest {
  open(method, url) {}
  setRequestHeader(key, value) {}

  send(body) {}

  Stream<ProgressEvent> get onLoadEnd {
    return null;
  }

  int status = 0;

  String responseText = 's';
}
*/