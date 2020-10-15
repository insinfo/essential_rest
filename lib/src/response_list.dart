import 'dart:collection';

class RList<E> extends ListBase<E> {
  final List<E> l = [];

  RList() {
    //isto é para o ngTemplateOutlet <ng-container *ngTemplateOutlet="recursiveList; context: item.contextForRender ">
    templateOutletContext = {'\$implicit': this};
  }

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

  ///isto é para o ngTemplateOutlet <ng-container *ngTemplateOutlet="recursiveList; context: item.contextForRender ">
  Map<String, dynamic> templateOutletContext;
}
/*
extension TotalRecords on List {
  int _totalRecords = 0;

  int get totalRecords => _totalRecords;

  set totalRecords(int totalRecords) {
    _totalRecords = totalRecords;
  }
}*/
/*extension TemplateOutletContextForRender on RList {
  //isto é para o ngTemplateOutlet <ng-container *ngTemplateOutlet="recursiveList; context: item.contextForRender ">
  /* static final _totalRecords = Expando<int>();
  int get totalRecords => _totalRecords[this];
  set totalRecords(int value) {
    _totalRecords[this] = value;
  }*/
  Map<String, dynamic> get templateOutletContext {
    return {'\$implicit': this};
  }
}*/
