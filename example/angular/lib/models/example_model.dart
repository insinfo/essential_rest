//entity model definition
class ExampleModel {
  int id;
  int userId;
  String title;
  bool completed;

  ExampleModel({this.userId, this.id, this.title, this.completed});

  ExampleModel.fromMap(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    title = json['title'];
    completed = json['completed'];
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['userId'] = userId;
    data['id'] = id;
    data['title'] = title;
    data['completed'] = completed;
    return data;
  }
}
