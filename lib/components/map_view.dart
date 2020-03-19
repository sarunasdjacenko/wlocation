import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../screens/screens.dart';
import '../services/services.dart';

class MapView extends StatefulWidget {
  /// Image Provider used as the map.
  final NetworkImage image;

  MapView({@required this.image});

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  /// Size of icon used to show the location of the user
  static const _iconSize = 40.0;

  /// Position of location marker on the device.
  Offset _positionOnScreen;

  /// Controller for [PhotoView].
  PhotoViewController _viewController;

  /// Controller Offset from center of the image.
  Offset _viewOffset;

  /// Controller Scale of the image relative to the size of the screen.
  double _viewScale;

  /// Set the offset on the image which corresponds to the screen tap position.
  void _setMarkerOffsetOnImage(Offset positionOnScreen) {
    var offsetOnImage;
    if (positionOnScreen != null) {
      final viewSize = context.findRenderObject().paintBounds.size;
      final offsetOnScreen =
          positionOnScreen.translate(-viewSize.width / 2, -viewSize.height / 2);
      offsetOnImage = (offsetOnScreen - _viewOffset) / _viewScale;
    }
    MapScreen.of(context).setMarkerOffsetOnImage(offsetOnImage);
  }

  /// Set the position marker on the screen, when the image is scaled/panned.
  void _setMarkerPositionOnScreen() {
    var positionOnScreen;
    final offsetOnImage = MapScreen.of(context).markerOffsetOnImage;
    if (offsetOnImage != null && _viewScale != null && _viewOffset != null) {
      final viewSize = context.findRenderObject().paintBounds.size;
      final offsetOnScreen = (offsetOnImage * _viewScale) + _viewOffset;
      positionOnScreen =
          offsetOnScreen.translate(viewSize.width / 2, viewSize.height / 2);
    }
    _positionOnScreen = positionOnScreen;
  }

  /// Listener for image panning and scaling.
  void _viewControllerListener(PhotoViewControllerValue value) {
    setState(() {
      _viewOffset = value.position;
      _viewScale = value.scale;
    });
  }

  @override
  void initState() {
    super.initState();
    _viewController = PhotoViewController()
      ..outputStateStream.listen(_viewControllerListener);
  }

  @override
  void dispose() {
    _viewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setMarkerPositionOnScreen();
    final user = Provider.of<User>(context);
    return Stack(
      children: <Widget>[
        PhotoView(
          controller: _viewController,
          minScale: PhotoViewComputedScale.covered,
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          imageProvider: widget.image,
          onTapUp: (context, details, value) => user.isAdmin
              ? _setMarkerOffsetOnImage(details.localPosition)
              : null,
        ),
        if (_positionOnScreen != null)
          Positioned(
            child: const Icon(
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
