abstract class MapSerialization<T> {
  Map<String, dynamic> toMap();
  T fromMap(Map<String, dynamic> json);
}

/*
abstract class ISerialization <T>{
  T fromMap(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
*/
