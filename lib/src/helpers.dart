/*import 'dart:convert';
import 'dart:html';
import '../essential_rest.dart';


  bool _isQuotaExceeded() {
    try {
      window.localStorage['QUOTA_EXCEEDED_ERR'] = 'QUOTA_EXCEEDED_ERR';
      return false;
    } catch (e) {
      print('isQuotaExceeded ${e}');
      /*if (e.code == 22) {
        //code: 1014,
        //name: 'NS_ERROR_DOM_QUOTA_REACHED',
        //message: 'Persistent storage maximum size reached',
        // Storage full, maybe notify user or do some clean-up
      }*/
      return true;
    }
  }

  void _fillLocalStorage({int sizeMB = 5}) {
    var i = 0;
    try {
      // Test up to 5 MB
      for (var i = 0; i <= (sizeMB * 1000); i += 250) {
        window.localStorage['test'] = List((i * 1024) + 1).join('a');
      }
    } catch (e) {
      print('fillLocalStorage ${e}');
      // localStorage.removeItem('test');
      print('size ${i != null ? i - 250 : 0}');
    }
  }


void _putAllObjectsOnCache(String key, List<T> objects) {
   // _setLastFetchTime(key, DateTime.now());
    if (objects != null) {
      var maps = <Map>[];
      for (var obj in objects) {
        var item = obj as MapSerialization;
        maps.add(item.toMap());
      }
      window.localStorage.addAll({key: jsonEncode(maps)});
    }
  }

  void _putObjectOnCache(String key, T object) {
    //_setLastFetchTime(key, DateTime.now());
    if (object != null) {
      var item = object as MapSerialization;
      window.localStorage.addAll({key: jsonEncode(item.toMap())});
    }
  }
*/