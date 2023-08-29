import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum ChickenState { idle, run, hit }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  Chicken(
      {this.offNeg = 0,
      this.offPos = 0,
      super.position,
      super.size}); //use super. INSTEAD OF: super(position: position, size: size);

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;

  late final Player player;

  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1; // right
  double targetDirection = -1;

  static const tileSize = 16;
  static const runSpeed = 80;
  final Vector2 _velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    player = game.player;
    _loadAllAnimation();
    _calculateRange();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateState();
    _movement(dt);
    super.update(dt);
  }

  void _loadAllAnimation() {
    _idleAnimation = _spriteAnimation('Idle', 13);
    _runAnimation = _spriteAnimation('Run', 14);
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;

    animations = {
      ChickenState.idle: _idleAnimation,
      ChickenState.run: _runAnimation,
      ChickenState.hit: _hitAnimation,
    };
    current = ChickenState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Chicken/$state (32x34).png'),
        SpriteAnimationData.sequenced(
            amount: amount, // amount of sprites
            stepTime: 0.05, // fps 20fps is 0.05, given by assets owner
            textureSize: Vector2(32, 34) // size of png
            ));
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _movement(dt) {
    _velocity.x = 0;

    double playerOffeset = (player.scale.x > 0) ? 0 : -player.width;
    double chickenOffset = (scale.x > 0) ? 0 : -width;

    if (playerInRange()) {
      //  player in range
      targetDirection =
          (player.x + playerOffeset < position.x + chickenOffset) ? -1 : 1;
      _velocity.x = targetDirection * runSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += _velocity.x * dt;
  }

  bool playerInRange() {
    double playerOffeset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffeset >= rangeNeg &&
        player.x + playerOffeset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void _updateState() {
    current = (_velocity.x != 0) ? ChickenState.run : ChickenState.idle;

    if ((moveDirection > 0 && scale.x > 0) ||
        moveDirection < 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
  }
}
