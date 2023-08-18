import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum RockState {
  idle,
  bottomHit,
}

class Rockhead extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  final double downNeg;
  final double downPos;
  Rockhead(
      {this.offNeg = 0,
      this.offPos = 0,
      this.downNeg = 0,
      this.downPos = 0,
      position,
      size})
      : super(position: position, size: size);

  final double stepTime = 0.06;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation bottomHitAnimation;
  static const moveSpeed = 50;
  static const tileSize = 16;

  double moveDirection = 1;

  double rangeNeg = 0;
  double rangePos = 0;

  double rangeNeg2 = 0;
  double rangePos2 = 0;

  bool movingHorizontally = true;
  bool bottomHit = false;

  final hitbox = CustomHitbox(offsetX: 4, offsetY: 4, width: 25, height: 25);

  @override
  FutureOr<void> onLoad() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;

    rangeNeg2 = position.y - downNeg * tileSize;
    rangePos2 = position.y + downPos * tileSize;

    //add hitbox
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive));

    // sprite = Sprite(
    //   game.images.fromCache('Traps/Rock Head/Idle.png'),
    // );

    idleAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Rock Head/Idle.png'),
        SpriteAnimationData.sequenced(
            amount: 1, // amount of sprites
            stepTime: 0.5, // fps 20fps is 0.05, given by assets owner
            textureSize: Vector2.all(42), // size of png
            loop: false));

    bottomHitAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Rock Head/Bottom Hit (42x42).png'),
        SpriteAnimationData.sequenced(
            amount: 4, // amount of sprites
            stepTime: stepTime, // fps 20fps is 0.05, given by assets owner
            textureSize: Vector2.all(42),
            loop: false // size of png
            ));

    animations = {
      RockState.idle: idleAnimation,
      RockState.bottomHit: bottomHitAnimation,
    };
    current = RockState.idle;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // _moveHorizontaly(dt);
    // _moveVerticaly(dt);
    _moveBlock(dt);
    super.update(dt);
  }

  void _moveHorizontaly(double dt) {
    current = RockState.idle;
    if (position.x >= rangePos) {
      moveDirection = -1; //move right
    } else if (position.x <= rangeNeg) {
      moveDirection = 1; // move left

      movingHorizontally = false;
    }
  }

  void _moveVerticaly(double dt) async {
    if (position.y >= rangePos2) {
         moveDirection = -1;// go up
      bottomHit = true;
      current = RockState.bottomHit;
      await animationTicker?.completed;
      animationTicker?.reset(); //reset animation if we will use it agoin

   

      current = RockState.idle;
    } else if (position.y <= rangeNeg2) {
      moveDirection = 1;

      current = RockState.idle;

      if (bottomHit) {
        movingHorizontally = true;
      }
    }
  }

  void _moveBlock(double dt) {
    if (movingHorizontally) {
      _moveHorizontaly(dt);

      position.x += moveDirection * moveSpeed * dt;
    } else {
      _moveVerticaly(dt);
      position.y += moveDirection * moveSpeed * dt;
    }
  }
}
