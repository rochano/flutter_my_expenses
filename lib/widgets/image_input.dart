import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  var _initValues = {};
  final String _imageUrl;
  final Function onSelectImage;

  ImageInput(this._initValues, this._imageUrl, this.onSelectImage);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _image;



  Future<void> _takePicture() async {
    final imageFile =
        await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (imageFile == null) {
      return null;
    }
    setState(() {
      _image = imageFile;
    });
    widget.onSelectImage(_image);
  }

    Future<void> _selectPicture() async {
    final imageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (imageFile == null) {
      return null;
    }
    setState(() {
      _image = imageFile;
    });
    widget.onSelectImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: ClipOval(
                    child: SizedBox(
                      width: 190.0,
                      height: 190.0,
                      child: _image != null
                          ? Image.file(
                              _image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : widget._initValues['image'] != null &&
                                  widget._initValues['image'].isNotEmpty
                              ? (widget._imageUrl != null &&
                                      widget._imageUrl.isNotEmpty
                                  ? Image.network(
                                      widget._imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                    ))
                              : Padding(
                                  padding: EdgeInsets.only(top: 85),
                                  child: Text(
                                    'No Image Taken',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 60.0),
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    size: 30.0,
                  ),
                  onPressed: _takePicture,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
