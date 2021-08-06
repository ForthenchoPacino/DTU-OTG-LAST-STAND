import 'package:nilay_dtuotg_2/models/screenArguments.dart';
import 'package:nilay_dtuotg_2/providers/info_provider.dart';
import 'package:nilay_dtuotg_2/providers/server_connection_functions.dart';
import 'package:nilay_dtuotg_2/widgets/eventDurationPicker.dart';
import 'package:nilay_dtuotg_2/widgets/eventOwnerPicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class AddEventScreen extends StatefulWidget {
  static const routeName = 'AddEventScreen';
  AddEventScreen({Key key}) : super(key: key);

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final name = TextEditingController();
  final description = TextEditingController();
  final whatsInItForYou = TextEditingController();
  final link = TextEditingController();
  String Somerandomtext;
  bool imagePicked = false;
  bool imageCroped = false;
  @override
  void initState() {
    name.text = "";
    description.text = "";
    whatsInItForYou.text = "";
    link.text = "";
    Somerandomtext="-";
    // TODO: implement initState
    super.initState();
  }

  DateTime dateTime;
  TimeOfDay timeOfDay;


  File _image;
  final picker = ImagePicker();
  var _imageDataList = <Uint8List>[];

  void _showPicker(BuildContext context, num ratio) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        elevation: 0,
        barrierColor: Colors.black12,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(11),
              ),
              padding: EdgeInsets.symmetric(
                  vertical: 10 * ratio, horizontal: 22 * ratio),
//color: Colors.cyan,
              margin: EdgeInsets.only(
                top: 20 * ratio,
                left: 15 * ratio,
                right: 15 * ratio,
              ),
              child: new Wrap(
                direction: Axis.horizontal,
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(
                        Icons.photo_library,
                        color: Colors.blueGrey[700],
                      ),
                      title: new Text(
                        'Photos',
                        style: TextStyle(
                            color: Colors.blueGrey[900],
                            fontStyle: FontStyle.normal,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                      onTap: () {
                        getImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      }),

                  new ListTile(
                    leading: new Icon(
                      Icons.photo_camera,
                      color: Colors.blueGrey[700],
                    ),
                    title: new Text('Camera',
                        style: TextStyle(
                            color: Colors.blueGrey[900],
                            fontStyle: FontStyle.normal,
                            fontSize: 15,
                            fontWeight: FontWeight.w400)),
                    onTap: () {
                      getImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future getImage(ImageSource imageSource) async {
    print('a');
    PickedFile pickedFile;
    // final pickedFile = await picker.getImage(source: ImageSource.gallery);
    try {
      print('b');
      pickedFile = await picker.getImage(
        source: imageSource,
      );
      print('${pickedFile.path}');
    } catch (e) {
      print('c');
      print(e.code);
    }
    setState(() {
      print('d');
      if (pickedFile != null) {
        print('e');
        _image = File(pickedFile.path);
        imagePicked = true;
      } else {
        print('f');
        print('No image selected.');
      }
    });
  }

  final formGlobalKey = GlobalKey<FormState>();
  bool waiting = false;
  var resp;
  DateTime now = DateTime.now();
  Duration _duration = Duration(hours: 0, minutes: 0);
  @override
  Widget build(BuildContext context) {
    int type = ModalRoute.of(context).settings.arguments;

    double ratio = MediaQuery.of(context).size.height / 896;

    // BuildContext bc =
    //     Provider.of<TabsScreenContext>(context, listen: false).get();
    var data = Provider.of<AddEventScreenData>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.brown,
      persistentFooterButtons: [

        ElevatedButton.icon(
            style:
                ElevatedButton.styleFrom(primary: Colors.white, elevation: 0),
            onPressed: () async {

              print('1');
              setState(() {
                waiting = true;

              });
              if (dateTime != null &&
                  timeOfDay != null &&
                  name != null &&
                  description != null &&
                  type != null) {
                print('2');
                var scf = Provider.of<SCF>(context, listen: false).get();
                int resp = await scf.createEvent(
                    context,
                    name.text,
                    description.text +
                        '~\$' +
                        whatsInItForYou.text +
                        '\$~' +
                        link.text,
                    type,
                    dateTime,
                    timeOfDay,
                    _image);
                scf.fetchListOfEvents(context);

                print('3');
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Padding(
                          padding: EdgeInsets.all(50),
                          child: Text(resp.toString()),
                        ),
                      );
                    });

                if (resp <= 205) {
                  Navigator.of(context).pop();
                }
              }
              setState(() {
                waiting = false;
              });
            },
            icon: Icon(
              Icons.save,
              color: Colors.brown,
            ),
            label: waiting
                ? CircularProgressIndicator()
                : Text(
                    'save',
                    style: TextStyle(color: Colors.brown),
                  ))
      ],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(type == 1
            ? 'add event 🙂'
            : type == 2
                ? 'projects +'
                : '+ jobs/internships'),
      ),
      body: Container(

        color: Color(0xfff2efe4),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(Somerandomtext),
          _image == null
              ? ListTile(
                  leading: Icon(Icons.add_a_photo),
                  title: Text('No image selected.'),
                  onTap: () => _showPicker(context, ratio),
                )
              : Container(
                  child: Image.file(_image),
                  height: 100,
                ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                elevation: 0,
                primary: Colors.white,
                side: BorderSide(color: Colors.brown, width: 2)),
            child: Text(
              'Pick A Date',
              style: TextStyle(color: Colors.brown),
            ),
            autofocus: true,
            clipBehavior: Clip.hardEdge,
            onPressed: () async {
              dateTime = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2021),
                  firstDate: DateTime(2021),
                  lastDate: DateTime(2022));
              print('$dateTime');
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                elevation: 0,
                primary: Colors.white,
                side: BorderSide(color: Colors.brown, width: 2)),
            onPressed: () async {
              timeOfDay = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: 1, minute: 0),
              );
              print('$timeOfDay');
            },
            child: Text(
              "startingTime?",
              style: TextStyle(color: Colors.brown),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("Assets/newframe.png"),
                  fit: BoxFit.cover),
            ),
            child: ListTile(
              leading: Icon(Icons.timelapse),
              tileColor: Colors.white,
              title: Text('Duration?'),
              trailing: Text('${data.getHours()}h ${data.getMinutes()}min'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(child: DurationPicker());
                    });
              },
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.people),
          //   tileColor: Colors.blue[200],
          //   title: Text('owners'),
          //   trailing: Text('${data.getOwners()}'),
          //   onTap: () {
          //     showDialog(
          //         context: context,
          //         builder: (context) {
          //           return Dialog(child: OwnerPicker());
          //         });
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: TextField(
                onChanged:(value){
                  Somerandomtext=value;
                },
                controller: name,
                  style: TextStyle(color: Colors.brown, fontSize: 30),
                  cursorColor: Colors.brown,
                  cursorHeight: 35,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.black26, width: 4),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.black26, width: 3),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      labelText: "Name of the event",
                      helperText: 'Keep it short, this is just a beta.',
                      hintStyle: TextStyle(color: Colors.black26),
                      labelStyle:
                      TextStyle(color: Colors.brown, fontSize: 30),
                      hoverColor: Colors.brown,
                      fillColor: Colors.white,

                      focusColor: Colors.white),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: TextField(
                controller: description,
                  style: TextStyle(color: Colors.brown, fontSize: 30),
                  cursorColor: Colors.brown,
                  cursorHeight: 35,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.black26, width: 4),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.black26, width: 3),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      labelText: "Description",
                      helperText: 'Whats it about?',
                      hintStyle: TextStyle(color: Colors.black26),
                      labelStyle:
                      TextStyle(color: Colors.brown, fontSize: 30),
                      hoverColor: Colors.brown,

                      focusColor: Colors.white),

              ),
            ),

          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: TextField(
                controller: whatsInItForYou,
                  style: TextStyle(color: Colors.brown, fontSize: 30),
                  cursorColor: Colors.brown,
                  cursorHeight: 35,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.black26, width: 4),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.black26, width: 3),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      labelText: "Incentives",
                      helperText: "What's in it for students",
                      hintStyle: TextStyle(color: Colors.black26),
                      labelStyle:
                      TextStyle(color: Colors.brown, fontSize: 30),
                      hoverColor: Colors.brown,

                      focusColor: Colors.white),

                  ),
            ),

          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: TextField(
                controller: link,
                  style: TextStyle(color: Colors.brown, fontSize: 30),
                  cursorColor: Colors.brown,
                  cursorHeight: 35,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.black26, width: 4),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.black26, width: 3),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      labelText: "link to more details/website/meeting",

                      hintStyle: TextStyle(color: Colors.black26),
                      labelStyle:
                      TextStyle(color: Colors.brown, fontSize: 20),
                      hoverColor: Colors.brown,

                      focusColor: Colors.white),
                  ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
