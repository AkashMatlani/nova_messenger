import 'dart:async';
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';

class ProgressiveImage extends StatefulWidget {
  ProgressiveImage({
    Key key,
    @required this.placeholder,
    @required this.thumbnail,
    //@required this.image,
    @required this.width,
    @required this.height,
    this.fit = BoxFit.fill,
    this.blur = 20,
    this.fadeDuration = const Duration(milliseconds: 500),
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.excludeFromSemantics = false,
    this.imageSemanticLabel,
  })  : assert(placeholder != null),
        assert(thumbnail != null),
       // assert(image != null),
        assert(width != null),
        assert(height != null),
        assert(fadeDuration != null),
        assert(alignment != null),
        assert(repeat != null),
        assert(matchTextDirection != null),
        super(key: key);

  ProgressiveImage.memoryNetwork({
    Key key,
    @required Uint8List placeholder,
    @required String thumbnail,
    @required String image,
    @required this.width,
    @required this.height,
    double placeholderScale = 1.0,
    double thumbnailScale = 1.0,
    double imageScale = 1.0,
    this.fit = BoxFit.fill,
    this.blur = 20,
    this.fadeDuration = const Duration(milliseconds: 500),
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.excludeFromSemantics = false,
    this.imageSemanticLabel,
  })  : assert(placeholder != null),
        assert(thumbnail != null),
        assert(image != null),
        assert(height != null),
        assert(width != null),
        placeholder = MemoryImage(placeholder, scale: placeholderScale),
        thumbnail = NetworkImage(thumbnail, scale: thumbnailScale),
        //image = NetworkImage(image, scale: imageScale),
        super(key: key);

  ProgressiveImage.assetNetwork({
    Key key,
    @required String placeholder,
    @required String thumbnail,
    @required String image,
    @required this.width,
    @required this.height,
    AssetBundle bundle,
    double placeholderScale,
    double thumbnailScale = 1.0,
    double imageScale = 1.0,
    this.fit = BoxFit.fill,
    this.blur = 20,
    this.fadeDuration = const Duration(milliseconds: 500),
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.excludeFromSemantics = false,
    this.imageSemanticLabel,
  })  : assert(placeholder != null),
        assert(thumbnail != null),
        assert(image != null),
        assert(height != null),
        assert(width != null),
        placeholder = placeholderScale != null
            ? ExactAssetImage(placeholder,
                bundle: bundle, scale: placeholderScale)
            : AssetImage(placeholder, bundle: bundle),
        thumbnail = NetworkImage(thumbnail),
        //image = NetworkImage(image),
        super(key: key);

  /// Image displayed initially while the `thumbnail` is loading.
  final ImageProvider placeholder;

  /// The blurred thumbnail that is displayed while the target `image` is loading.
  final ImageProvider thumbnail;

  /// The target image that
  //final ImageProvider image;

  /// The `placeholder`, `thumbnail` and target `image` will acquire this width
  /// based on the `fit` property.
  final double width;

  /// The `placeholder`, `thumbnail` and target `image` will acquire this height
  /// based on the `fit` property.
  final double height;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default is [BoxFit.fill]
  final BoxFit fit;

  /// The intensity of the blur applied on the `thumbnail`.
  ///
  /// The Default is `20.0`,
  /// use `0` for no blur effect.
  final double blur;

  /// The duration of the fade animation for the `placeholder`, `thumbnail`
  ///  and target `image`.
  final Duration fadeDuration;

  final AlignmentGeometry alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  final bool matchTextDirection;

  final bool excludeFromSemantics;

  final String imageSemanticLabel;
  @override
  _ProgressiveImageState createState() => _ProgressiveImageState();
}

class _ProgressiveImageState extends State<ProgressiveImage> {
  Progress _status = Progress.Loading;

  bool _placeholderDelay = true;

  bool _thumbnailDelay = true;

  @override
  void setState(void Function() fn) {
    if (mounted) super.setState(fn);
  }

  void _updateProgress(Progress progress) {
    setState(() {
      _status = progress;
    });
  }

  @override
  void initState() {
    super.initState();

    // ignore: unused_local_variable
    ImageStreamListener _targetListener =
        ImageStreamListener((ImageInfo info, bool _) {
      Timer(widget.fadeDuration, () {
        setState(() {
          _thumbnailDelay = false;
        });
      });
      _updateProgress(Progress.TargetLoaded);
    });

    ImageStreamListener _thumbnailListener =
        ImageStreamListener((ImageInfo info, bool _) {
      Timer(widget.fadeDuration, () {
        setState(() {
          _placeholderDelay = false;
        });
      });

      // Start fetching the target image only after the thumbnail is resolved
      if (_status != Progress.TargetLoaded) {
        _updateProgress(Progress.ThumbnailLoaded);
        //widget.image.resolve(ImageConfiguration()).addListener(_targetListener);
      }
    });

    widget.thumbnail
        .resolve(ImageConfiguration())
        .addListener(_thumbnailListener);
  }

  Image _image(
      {@required ImageProvider image, ImageFrameBuilder frameBuilder}) {
    assert(image != null);
    return Image(
      image: image,
      frameBuilder: frameBuilder,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      repeat: widget.repeat,
      alignment: widget.alignment,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Stack(
      fit: StackFit.loose,
      alignment: AlignmentDirectional.center,
      textDirection: TextDirection.ltr,
      children: <Widget>[
        AnimatedOpacity(
            duration: widget.fadeDuration,
            // Fade out placeholder only after the thumbnail fades in completely
            opacity: _status == Progress.Loading ||
                    (_status == Progress.ThumbnailLoaded && _placeholderDelay)
                ? 1.0
                : 0.0,
            child: _image(image: widget.placeholder)),
        AnimatedOpacity(
          // Fade out thumbnail only after the target image fades in completely
          opacity: _status == Progress.ThumbnailLoaded ||
                  (_status == Progress.TargetLoaded && _thumbnailDelay)
              ? 1.0
              : 0.0,
          duration: widget.fadeDuration,
          child: _image(image: widget.thumbnail),
        ),
        Opacity(
          // Fade out blur effect only after the target image fades in completely
          opacity: _status == Progress.ThumbnailLoaded ||
                  (_status == Progress.TargetLoaded && _thumbnailDelay)
              ? 1.0
              : 0.0,
          child: ClipRect(
            child: BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
              child: Container(
                // height: apparentHeight(),
                // width: apparentWidth(),
                child: Opacity(
                  opacity: 0.0,
                  child: _image(image: widget.thumbnail),
                ),
                color: Colors.black.withOpacity(0),
              ),
            ),
          ),
        ),
        // AnimatedOpacity(
        //   opacity: _status == Progress.TargetLoaded ? 1.0 : 0.0,
        //   duration: widget.fadeDuration,
        //   child: _status == Progress.Loading
        //       ? SizedBox(height: 0, width: 0)
        //       : _image(image: widget.image),
        // )
      ],
    );

    if (!widget.excludeFromSemantics) {
      result = Semantics(
        container: widget.imageSemanticLabel != null,
        image: true,
        label: widget.imageSemanticLabel ?? '',
        child: result,
      );
    }

    return result;
  }
}

enum Progress {
  Loading,
  ThumbnailLoaded,
  TargetLoaded,
}
