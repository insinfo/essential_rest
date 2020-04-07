import 'dart:collection';

class RList<E> extends ListBase<E> {
  final List<E> l = [];

  RList();

  @override
  set length(int newLength) {
    l.length = newLength;
  }

  @override
  int get length => l.length;

  @override
  E operator [](int index) => l[index];

  @override
  void operator []=(int index, E value) {
    l[index] = value;
  }

  int _totalRecords = 0;

  int get totalRecords => _totalRecords;

  set totalRecords(int totalRecords) {
    _totalRecords = totalRecords;
  }
}
/*
extension TotalRecords on List {
  int _totalRecords = 0;

  int get totalRecords => _totalRecords;

  set totalRecords(int totalRecords) {
    _totalRecords = totalRecords;
  }
}*/