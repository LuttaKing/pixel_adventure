// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/levels.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211f30);

  late final CameraComponent cam;
  Player player = Player(character: 'Ninja Frog');
  late JoystickComponent directionJoystick;

  bool showJoystick = false;

  @override
  FutureOr<void> onLoad() async {
    // load all images to cache
    await images.loadAllImages(); // dont do thiss with lots of images, time
    final world = Level(levelName: 'Level-02', player: player);
    cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640, // defined in Tiled
        height: 360);

    cam.viewfinder.anchor = Anchor.topLeft; //camera position
    addAll([cam, world]);
    addJoystick();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // updateJoystick();
    super.update(dt);
  }

  void addJoystick() {
    directionJoystick = JoystickComponent(
        //knobRadius: 10, // how far knob goes
        knob: SpriteComponent(
          
          sprite: Sprite(
            images.fromCache('HUD/Knob.png'),
          ),
        ),
        background: SpriteComponent(
            sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
        margin: const EdgeInsets.only(left: 32, bottom: 32));

    final buttonComponent = ButtonComponent(

      button:  SpriteComponent(
        size: Vector2.all(64),
        
          sprite: Sprite(
            images.fromCache('HUD/JumpButton.png'),
          ),
        ),
      
      buttonDown: SpriteComponent(
        size: Vector2.all(96),
        
          sprite: Sprite(
            images.fromCache('HUD/JumpButton.png'),
          ),
        ),
        position: Vector2(size.x-80, size.y - 80),
      onPressed: () {
        player.hasJumped=true;
      },
    );

    addAll([directionJoystick, buttonComponent]);
  }

  void updateJoystick() {
    switch (directionJoystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.downLeft:
      case JoystickDirection.upLeft:
        player.horizontalMovement = -1;
        break;

      case JoystickDirection.right:
      case JoystickDirection.downRight:
      case JoystickDirection.upRight:
        player.horizontalMovement = 1;
        break;

      default:
        player.horizontalMovement = 0;

        break;
    }
  }
}
