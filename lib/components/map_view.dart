import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wlocation/components/user_provider.dart';

class MapView extends StatefulWidget {
  MapView({
    @required this.image,
    this.markerOffsetOnImage,
    this.setMarkerOffsetOnImage,
  });

  /// Image used as the map/
  final AssetImage image;

  /// The marker offset on the image.
  final Offset markerOffsetOnImage;

  /// Callback function to set the marker offset on the image.
  final Function(Offset) setMarkerOffsetOnImage;

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  /// Size of icon used to show the location of the user
  static const _iconSize = 40.0;

  /// Position of location marker on the device.
  Offset _positionOnScreen;

  /// Controller for [PhotoView].
  PhotoViewController _controller;

  /// Controller Offset from center of the image.
  Offset _controllerOffset;

  /// Controller Scale of the image relative to the size of the screen.
  double _controllerScale;

  /// Set the offset on the image which corresponds to the screen tap position.
  void _setMarkerOffsetOnImage(Offset positionOnScreen) {
    if (positionOnScreen == null)
      widget.setMarkerOffsetOnImage?.call(null);
    else {
      final viewSize = context.findRenderObject().paintBounds.size;
      final offsetOnScreen =
          positionOnScreen.translate(-viewSize.width / 2, -viewSize.height / 2);
      final offsetOnImage =
          (offsetOnScreen - _controllerOffset) / _controllerScale;
      widget.setMarkerOffsetOnImage?.call(offsetOnImage);
    }
  }

  /// Set the position marker on the screen, when the image is scaled/panned.
  void _setMarkerPositionOnScreen() {
    var positionOnScreen;
    if (widget.markerOffsetOnImage != null) {
      final viewSize = context.findRenderObject().paintBounds.size;
      final offsetOnScreen =
          (widget.markerOffsetOnImage * _controllerScale) + _controllerOffset;
      positionOnScreen =
          offsetOnScreen.translate(viewSize.width / 2, viewSize.height / 2);
    }
    _positionOnScreen = positionOnScreen;
  }

  /// Listener for image panning and scaling.
  void _controllerListener(PhotoViewControllerValue value) {
    _controllerOffset = value.position;
    _controllerScale = value.scale;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = PhotoViewController()
      ..outputStateStream.listen(_controllerListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setMarkerPositionOnScreen();
    return Stack(
      children: <Widget>[
        PhotoView(
          imageProvider: widget.image,
          backgroundDecoration: BoxDecoration(color: Colors.white),
          minScale: PhotoViewComputedScale.covered,
          controller: _controller,
          onTapUp: (context, details, controllerValue) =>
              UserProvider.of(context).isSignedIn()
                  ? _setMarkerOffsetOnImage(details.localPosition)
                  : null,
        ),
        if (_positionOnScreen != null)
          Positioned(
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: _iconSize,
            ),
            left: _positionOnScreen.dx - _iconSize / 2,
            top: _positionOnScreen.dy - _iconSize,
          ),
      ],
    );
  }
}
