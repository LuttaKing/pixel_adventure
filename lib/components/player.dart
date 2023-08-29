// ignore_for_file: implementation_imports, unnecessary_import

import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:pixel_adventure/components/bullet_component.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/rockHead.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  jump,
  fall,
  hit,
  appearing,
  disappearing,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({
    position,
    this.character = 'Ninja Frog',
  }) : super(position: position); // pass position to be put
  late TimerComponent bulletCreator;
  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  final double _gravity = 9.8;
  final double _jumpForce = 300;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckPoint = false;
  List<CollisionBlock> collisionBlocks = [];

  double fixedDeltaTime = 1 / 60; //target 60 fps
  double accumulatedTime = 0;

  CustomHitbox hitbox =
      CustomHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);
  late AudioPool pool;

  @override
  FutureOr<void> onLoad() async {
    _loadAllAnimations(); //my custom
    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));

    // pool = await FlameAudio.createPool(
    //   'sfx/fire_2.mp3',
    //   minPlayers: 3,
    //   maxPlayers: 4,
    // );

    add(
      bulletCreator = TimerComponent(
        period: 0.05,
        repeat: false,
        autoStart: false,
        onTick: _createBullet,
      ),
    );
    return super.onLoad();
  }

  // void fireOne() {
  //   FlameAudio.play('sfx/fire_1.mp3');
  // }

  // void fireTwo() {
  //   pool.start();
  // }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckPoint) {
      if (other is Fruit) {
        other.collidedWithPlayer();
      }
      if (other is Saw || other is Rockhead) {
        _respawn();
      }
      if (other is Chicken) {
        other.collidedWPlayer();
      }
      if (other is Checkpoint) {
        _reachedCheckPoint();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckPoint) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }

      accumulatedTime -= fixedDeltaTime;
    }

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
    hitAnimation = _spriteAnimation('Hit', 7)..loop = false;
    fallAnimation = _spriteAnimation('Fall', 1);
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);

//list all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };
// set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
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
    // fireOne(); // sound
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
            position.x = block.x +
                block.width +
                hitbox.width +
                hitbox.offsetX; //stop here
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
            position.y = block.y - hitbox.height - hitbox.offsetY; //stop here
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            // going up

            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY; //stop here
          }
        }
      }
    }
  }

  void _respawn() async {
    const canMoveDuration = Duration(milliseconds: 400);

    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed; //until animation is done
    animationTicker?.reset(); //reset animation if we will use it again

    scale.x = 1; // face right
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    // fireTwo();//sound
    _updatePlayerState();
    Future.delayed(canMoveDuration, () => gotHit = false);
  }

  void _reachedCheckPoint() {
    reachedCheckPoint = true;
    if (scale.x > 0) {
      //if facing right
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }
    current = PlayerState.disappearing;
    const reachedCheckpointDuration = Duration(milliseconds: 350);
    Future.delayed(reachedCheckpointDuration, () {
      reachedCheckPoint = false;
      position = Vector2.all(-640);

      const waitToChangeDuration = Duration(seconds: 3);
      Future.delayed(waitToChangeDuration, () {
        game.loadNextLevel();
      });
    });
  }

  void _createBullet() {
    final bullet = BulletComponent(
      position: Vector2.zero(),
      angle: 0.0,
    );
    add(bullet);
  }

  void beginFire() {
    bulletCreator.timer.start();
  }

  void stopFire() {
    bulletCreator.timer.pause();
  }

  void collidedWithEnemy() {
    _respawn();
  }
}
