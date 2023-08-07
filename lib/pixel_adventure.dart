import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/levels.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211f30);

  late final CameraComponent cam;
  Player player = Player(character: 'Ninja Frog');
  late JoystickComponent joystick;
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
    joystick = JoystickComponent(
        //knobRadius: 10, // how far knob goes
        knob: SpriteComponent(
          sprite: Sprite(
            images.fromCache('HUD/Knob.png'),
          ),
        ),
        background: SpriteComponent(
            sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
        margin: const EdgeInsets.only(left: 32, bottom: 32));
    add(joystick);
  }

  void updateJoystick() {
    if (Platform.isAndroid) {
        switch (joystick.direction) {
      case JoystickDirection.left:
        player.horizontalMovement=-1;
        break;
      
      case JoystickDirection.right:
        player.horizontalMovement=1;
        break;
      case JoystickDirection.up:
        player.hasJumped=true;
        break;
      default:
        player.horizontalMovement=0;
        player.hasJumped=false;
        
        
        break;
    }
    }
  
  }
}
