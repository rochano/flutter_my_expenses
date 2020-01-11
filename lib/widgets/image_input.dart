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
    Navigator.pop(context);
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
    Navigator.pop(context);
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

  void _showImageMethod(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (context) {
          return SingleChildScrollView(
            child: Card(
              elevation: 5,
              child: Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.camera_enhance),
                      title: Text('Take Picture'),
                      onTap: _takePicture,
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Select Image'),
                      onTap: _selectPicture,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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
                  child: InkWell(
                    onTap: () {
                      if (_image != null) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) {
                          return DetailScreen(
                            imageFile: _image,
                          );
                        }));
                      } else if (widget._imageUrl != null &&
                          widget._imageUrl.isNotEmpty) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) {
                          return DetailScreen(
                            imageUrl: widget._imageUrl,
                          );
                        }));
                      }
                    },
                    child: Container(
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
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 60.0),
                child: IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      size: 30.0,
                    ),
                    onPressed: () => _showImageMethod(context)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final File imageFile;
  final String imageUrl;

  const DetailScreen({Key key, this.imageFile, this.imageUrl})
      : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: widget.imageFile != null
                ? Image.file(
                    widget.imageFile,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
