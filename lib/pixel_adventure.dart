// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/levels.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211f30);

  late CameraComponent cam;
  Player player = Player(character: 'Ninja Frog');
  late JoystickComponent directionJoystick;

  bool showControls = false;
  List<String> levelNames = ['Level-02', 'Level-01'];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    // load all images to cache
    await images.loadAllImages(); // dont do thiss with lots of images, time
    _loadLevel();

    addControls();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // updateJoystick();
    super.update(dt);
  }

  void addControls() {
    directionJoystick = JoystickComponent(
        priority: 1,
        //knobRadius: 10, // how far knob goes
        knob: SpriteComponent(
          sprite: Sprite(
            images.fromCache('HUD/Knob.png'),
          ),
        ),
        background: SpriteComponent(
            sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
        margin: const EdgeInsets.only(left: 32, bottom: 32));

    final jumpButton = ButtonComponent(
      priority: 1,
      button: SpriteComponent(
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
      position: Vector2(size.x - 100, size.y - 100),
      onPressed: () {
        player.hasJumped = true;
      },
      onReleased: () {
        player.hasJumped = false;
      },
    );

    final shootButton = JumpButton();

    addAll([directionJoystick, jumpButton,shootButton]);
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

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      // no more levels
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level world = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );

      cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, world]);
    });
  }
}
