import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Rockhead extends SpriteAnimationComponent with HasGameRef<PixelAdventure>{
   final double offNeg;
  final double offPos;
  Rockhead({this.offNeg = 0,
      this.offPos = 0,position, size}) : super(position: position, size: size);

  final double stepTime = 0.5;
  static const moveSpeed = 20;
  static const tileSize = 16;

  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Rock Head/Idle.png'),
        SpriteAnimationData.sequenced(
            amount: 1, // amount of sprites
            stepTime: stepTime, // fps 20fps is 0.05, given by assets owner
            textureSize: Vector2.all(40) // size of png
            ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
     _moveHorizontaly(dt);
         super.update(dt);
  }

   void _moveHorizontaly(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }


}
