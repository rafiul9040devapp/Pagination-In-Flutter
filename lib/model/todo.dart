import 'dart:convert';
/// id : 31
/// todo : "Find a charity and donate to it"
/// completed : true
/// userId : 35
class Todo {
  Todo({
      this.id, 
      this.todo, 
      this.completed, 
      this.userId,});

  Todo.fromJson(dynamic json) {
    id = json['id'];
    todo = json['todo'];
    completed = json['completed'];
    userId = json['userId'];
  }
  num? id;
  String? todo;
  bool? completed;
  num? userId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['todo'] = todo;
    map['completed'] = completed;
    map['userId'] = userId;
    return map;
  }

}