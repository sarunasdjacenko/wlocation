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

  /// Controller for [PhotoView].
  PhotoViewController _viewController;

  /// Controller Offset from center of the image.
  Offset _viewOffset;

  /// Controller Scale of the image relative to the size of the screen.
  double _viewScale;

  /// Set the offset on the image which corresponds to the screen tap position.
  void _setMarkerOffsetOnImage(Offset screenPosition) {
    var imageOffset;
    if (screenPosition != null && _viewScale != null && _viewOffset != null) {
      final viewSize = context.findRenderObject().paintBounds.size;
      final screenOffset =
          screenPosition.translate(-viewSize.width / 2, -viewSize.height / 2);
      imageOffset = (screenOffset - _viewOffset) / _viewScale;
    }
    MapScreen.of(context).setMarkerOffset(imageOffset);
  }

  /// Calculate the screen tap position from an offset on the image.
  Offset _imageOffsetToScreenPos(Offset imageOffset) {
    var screenPosition;
    if (imageOffset != null && _viewScale != null && _viewOffset != null) {
      final viewSize = context.findRenderObject().paintBounds.size;
      final screenOffset = (imageOffset * _viewScale) + _viewOffset;
      screenPosition =
          screenOffset.translate(viewSize.width / 2, viewSize.height / 2);
    }
    return screenPosition;
  }

  /// Listener for image panning and scaling.
  void _viewControllerListener(PhotoViewControllerValue value) {
    setState(() {
      _viewOffset = value.position;
      _viewScale = value.scale;
    });
  }

  /// Initialises the state, and subscribes to the [PhotoViewController] stream.
  @override
  void initState() {
    super.initState();
    _viewController = PhotoViewController()
      ..outputStateStream.listen(_viewControllerListener);
  }

  /// Disposes the state when it is no longer needed.
  @override
  void dispose() {
    _viewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chosenMarkerPosition =
        _imageOffsetToScreenPos(MapScreen.of(context).chosenMarkerOffset);
    final predictedMarkerPosition =
        _imageOffsetToScreenPos(MapScreen.of(context).predictedMarkerOffset);
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
        if (chosenMarkerPosition != null)
          Positioned(
            child: const Icon(
              Icons.location_on,
              color: Colors.blueAccent,
              size: _iconSize,
            ),
            left: chosenMarkerPosition.dx - _iconSize / 2,
            top: chosenMarkerPosition.dy - _iconSize,
          ),
        if (predictedMarkerPosition != null)
          Positioned(
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: _iconSize,
            ),
            left: predictedMarkerPosition.dx - _iconSize / 2,
            top: predictedMarkerPosition.dy - _iconSize,
          ),
      ],
    );
  }
}
