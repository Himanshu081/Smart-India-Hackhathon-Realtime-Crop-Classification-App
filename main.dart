import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'location.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: MyApp(),
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  void _showLocationDetails(){
    showModalBottomSheet(context: context, builder: (context){
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 60.0),
        child: LocationDetail(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,

       resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Crop Classification',),
        centerTitle: true,
      ),
      body: _loading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(

        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints.expand(
          height: 750.0,
        ),

        child:SingleChildScrollView(
          child:   Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              _image == null ? Container() : Image.file(_image,fit: BoxFit.cover,),

              SizedBox(
                height: 20,

              ),
              _outputs != null
                  ? Text(
                "${_outputs[0]["label"]}  :  ${(_outputs[0]["confidence"]*100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  background: Paint()..color = Colors.white,
                ),



              )



                  : Container(),
              Container(
                child: _image==null ? Container():
                RaisedButton(
                  child:  Text("Get Location"),
                  onPressed: (){
                    _showLocationDetails();
                  },
                )
                ,
              )

            ],//children
          ),
        )


      ),

      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: "Pick a Image",
        child: Icon(Icons.image),
      ),





    );

  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
