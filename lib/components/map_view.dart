import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MapView extends StatefulWidget {
  MapView({@required this.image, this.callback});

  /// Image used as the map
  final AssetImage image;

  /// Callback function of type Offset
  final Function(Offset) callback;

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  /// Size of icon used to show the location of the user
  static const _iconSize = 40.0;

  /// Position of marker on the device
  Offset _positionOnScreen;

  /// Offset on the image which corresponds to the given position on the screen
  Offset _getOffsetOnImage(
    Offset positionOnScreen,
    PhotoViewControllerValue controllerValue,
  ) {
    final paintSize = context.findRenderObject().paintBounds.size;
    final offsetOnScreen =
        positionOnScreen.translate(-paintSize.width / 2, -paintSize.height / 2);
    return (offsetOnScreen - controllerValue.position) / controllerValue.scale;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PhotoView(
          imageProvider: widget.image,
          backgroundDecoration: BoxDecoration(color: Colors.white),
          minScale: PhotoViewComputedScale.covered,
          onTapUp: (context, details, controllerValue) {
            /// Update the marker offset on the image
            final offsetOnImage =
                _getOffsetOnImage(details.localPosition, controllerValue);
            widget.callback(offsetOnImage);

            /// Update the marker position on the screen
            setState(() => _positionOnScreen = details.localPosition);
          },
        ),
        _positionOnScreen != null
            ? Positioned(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: _iconSize,
                ),
                left: _positionOnScreen.dx - _iconSize / 2,
                top: _positionOnScreen.dy - _iconSize,
              )
            : Container(),
      ],
    );
  }
}
