import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MapView extends StatefulWidget {
  MapView({this.image});

  final Image image;

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // Size of icon used to show the location of the user
  static const _iconSize = 40.0;
  // Location marked on an admin device
  Offset _screenPosition;

  // Position on the image which corresponds to the given position on the screen
  Offset _getImagePosition(
    Offset screenPosition,
    PhotoViewControllerValue controllerValue,
  ) {
    final renderSize = context.findRenderObject().paintBounds.size;
    final localPosition =
        screenPosition.translate(-renderSize.width / 2, -renderSize.height / 2);
    return (localPosition - controllerValue.position) / controllerValue.scale;
  }

  // Position on the screen which corresponds to the given position on the image
  Offset _getScreenPosition(
    Offset imagePosition,
    PhotoViewControllerValue controllerValue,
  ) {
    final renderSize = context.findRenderObject().paintBounds.size;
    final localPosition =
        (imagePosition * controllerValue.scale) + controllerValue.position;
    return localPosition.translate(renderSize.width / 2, renderSize.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PhotoView(
          imageProvider: AssetImage('assets/BH7.jpg'),
          minScale: PhotoViewComputedScale.covered,
          onTapUp: (context, details, controllerValue) {
            print(details.localPosition);
            final imagePosition =
                _getImagePosition(details.localPosition, controllerValue);
            final screenPosition =
                _getScreenPosition(imagePosition, controllerValue);
            setState(() => _screenPosition = screenPosition);
            print('$imagePosition, $screenPosition');
          },
        ),
        _screenPosition != null
            ? Positioned(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: _iconSize,
                ),
                left: _screenPosition.dx - _iconSize / 2,
                top: _screenPosition.dy - _iconSize,
              )
            : Container(),
      ],
    );
  }
}
