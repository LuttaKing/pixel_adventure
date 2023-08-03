// ignore_for_file: implementation_imports, unnecessary_import

import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  jump,
  fall,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  String character;
  Player({
    position,
    this.character = 'Ninja Frog',
  }) : super(position: position); // pass position to be put

  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;

  final double _gravity = 9.8;
  final double _jumpForce = 350;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  List<CollisionBlock> collisionBlocks = [];

  PlayerHitbox hitbox =
      PlayerHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations(); //my custom
    // debugMode = true; //
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height)
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);

    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0; //move left
    horizontalMovement += isRightKeyPressed ? 1 : 0; //move right

    hasJumped = keysPressed.contains(LogicalKeyboardKey.arrowUp);

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);

    runningAnimation = _spriteAnimation('Run', 12);
    jumpAnimation = _spriteAnimation('Jump', 1);

    fallAnimation = _spriteAnimation('Fall', 1);
//list all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
    };

// set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$character/$state (32x32).png'),
        SpriteAnimationData.sequenced(
            amount: amount, // amount of sprites
            stepTime: stepTime, // fps 20fps is 0.05, given by assets owner
            textureSize: Vector2.all(32) // size of png
            ));
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
//flip
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
//check if moving, set running animation
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;
//check if falling
    if (velocity.y > 0) playerState = PlayerState.fall;
//check if jumping
    if (velocity.y < 0) playerState = PlayerState.jump;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    //if (velocity.y > _gravity) isOnGround =false; //not to jump while falling

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        // no collision for platform
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            // if going right
            velocity.x = 0; //stop moving
            position.x = block.x - hitbox.offsetX - hitbox.width; //stop here
            break;
          }
          if (velocity.x < 0) {
            // if going left
            velocity.x = 0; //stop moving
            position.x = block.x + block.width +hitbox.width+hitbox.offsetX; //stop here
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        //handle platform
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            // if falling
            velocity.y = 0; //stop moving
            position.y = block.y - hitbox.height - hitbox.offsetY; //stop here
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            // if falling
            velocity.y = 0; //stop moving
            position.y =block.y - hitbox.height - hitbox.offsetY; //stop here
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            // going up

            velocity.y = 0;
            position.y = block.y + block.height-hitbox.offsetY; //stop here
          }
        }
      }
    }
  }
}
