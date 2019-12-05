import 'package:flutter/material.dart';
import 'package:mysqlitesample/data.dart';
import 'package:mysqlitesample/dbutil.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Data>> datas;
  TextEditingController titleController = TextEditingController();
  TextEditingController activityController = TextEditingController();
  TextEditingController datetimeController = TextEditingController();
  String title;String activity;String datetime;
  int curUserId;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;
 
  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }
 
  refreshList() {
    setState(() {
      datas = dbHelper.getDatas();
    });
  }
 
  clearName() {
    titleController.text = '';
    activityController.text = '';
    datetimeController.text = '';
  }
  
  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Data e = Data(curUserId, title, activity, datetime);
        dbHelper.update(e);
        setState(() {
          isUpdating = false;
        });
      } else {
        Data e = Data(null, title, activity, datetime);
        dbHelper.insert(e);
      }
      clearName();
      refreshList();
    }
  }

  txtonSaved(String attrib,String value){
    if(attrib=='title'){title = value;}
    else if(attrib=='activity'){activity = value;}
    else if(attrib=='datetime'){datetime = value;}
  }
  form() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Row(
              children: <Widget>[
                textForm(titleController, 'title', 'Title'),
                textForm(activityController, 'activity', 'Activity'),
              ],
            ),
            Row(
              children: <Widget>[
                textForm(datetimeController, 'datetime', 'DateTime'),
                Expanded(
                  child: calendar(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: FlatButton(
                      color: Colors.blue,
                      onPressed: validate,
                      child: Text(isUpdating ? 'UPDATE' : 'ADD'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: FlatButton(
                      color: Colors.green,
                      onPressed: () {
                        setState(() {
                          isUpdating = false;
                        });
                        clearName();
                      },
                      child: Text('CANCEL'),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<Data> datas) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('Event Planer'),
          ),
          DataColumn(
            label: Text('           Action'),
          )
        ],
        rows: datas
            .map(
              (data) => DataRow(cells: [
                    DataCell(
                      Text('Title: '+data.title
                          +'\nActivity: '+data.activity
                          +'\nDateTime: '+data.datetime
                      )
                    ),
                    DataCell(
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.select_all),
                            onPressed: () {
                              setState(() {
                                isUpdating = true;
                                curUserId = data.id;
                              });
                              titleController.text = data.title;
                              activityController.text = data.activity;
                              datetimeController.text = data.datetime;
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              dbHelper.delete(data.id);
                              refreshList();
                            },
                          ),
                        ],
                      )
                    ),
                  ]),
            ).toList(),
      ),
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: datas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }
          if (null == snapshot.data || snapshot.data.length == 0) {
            return Text("No Data Found");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
  Widget textForm(TextEditingController controller,String text,String txtlabel){
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(5),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(labelText: '$txtlabel'),
          validator: (val) => val.length == 0 ? '$txtlabel' : null,
          onSaved: (val) => txtonSaved(text, val),
          ),
      ),
    );
  }

  Widget calendar(){
    return Container(
      padding: EdgeInsets.only(right: 130),
      child: IconButton(
        icon: Icon(Icons.calendar_today),
        onPressed: (){setState(() {
          String yr;String m;String d;
          DatePicker.showDatePicker(context,showTitleActions: true,minTime: DateTime(2017, 1, 1),maxTime: DateTime(2023, 12, 1), 
          onConfirm: (cdate) {
            yr = cdate.year.toString();m = cdate.month.toString();d = cdate.day.toString();
            datetimeController.text="$yr-$m-$d";
            datetime = "$m-$d-$yr";
          },
          currentTime: DateTime.now(), 
          locale: LocaleType.en);
        });},
      ),
    );
  }


  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Sqlite Demo CRUD")),
      body: new Container(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            form(),
            list(),
          ],
        ),
      ),
    );
  }
}
