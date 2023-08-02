import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/levels/levels.dart';

class PixelAdventure extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF211f30);

  late final CameraComponent cam;
  final world = Level(levelName: 'Level-02');

  @override
  FutureOr<void> onLoad() async {
    // load all images to cache
    await images.loadAllImages(); // dont do thiss with lots of images, time
    cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640, // defined in Tiled
        height: 360);

    cam.viewfinder.anchor = Anchor.topLeft; //camera position
    addAll([cam, world]);

    return super.onLoad();
  }
}
