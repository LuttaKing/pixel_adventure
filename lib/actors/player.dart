import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;
  
  String character;
  


  Player({position,required this.character,  }) : super(position: position); // pass position to be put



  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations(); //my custom
    return super.onLoad();
  }

  void _loadAllAnimations() {

    idleAnimation = _spriteAnimation('Idle',11);

      runningAnimation = _spriteAnimation('Run',12);

//list all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
    };

// set current animation
    current = PlayerState.running;
  }

  SpriteAnimation _spriteAnimation(String state,int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
          amount: amount, // amount of sprites
          stepTime: stepTime, // fps 20fps is 0.05, given by assets owner
          textureSize: Vector2.all(32) // size of png
          ));
  }
}
