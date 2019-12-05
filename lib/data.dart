
class Data{
  int id;
  String title;
  String activity;
  String datetime;

  Data(this.id,this.title,this.activity,this.datetime);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'title': title,
      'activity': activity,
      'datetime': datetime,
    };
    return map;
  }

  Data.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    activity = map['activity'];
    datetime = map['datetime'];
  }
}