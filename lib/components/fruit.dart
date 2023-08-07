import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String fruit;
  Fruit({this.fruit = 'Bananas', position, size})
      : super(position: position, size: size);

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);
  }

  bool _collected = false;
  final double stepTime = 0.05;
  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 12);

  @override
  FutureOr<void> onLoad() {
    priority = -1; // put behind layer of player

    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive));

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/$fruit.png'),
        SpriteAnimationData.sequenced(
            amount: 17, // amount of sprites
            stepTime: stepTime, // fps 20fps is 0.05, given by assets owner
            textureSize: Vector2.all(32) // size of png
            ));
    return super.onLoad();
  }

  void collidedWithPlayer() {
    if (!_collected) {
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache('Items/Fruits/Collected.png'),
          SpriteAnimationData.sequenced(
            amount: 6, // amount of sprites
            stepTime: stepTime, // fps 20fps is 0.05, given by assets owner
            textureSize: Vector2.all(32), // size of png,
            loop: false,
          ));
      _collected = true;
    }
    
    Future.delayed(const Duration(milliseconds: 400),(){
removeFromParent();
    });
    
  }
}
