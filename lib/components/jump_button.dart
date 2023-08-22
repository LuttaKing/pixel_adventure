import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  JumpButton();

  final margin = 32;
  final buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/jump.png'));
    position = Vector2(
      game.size.x - margin - buttonSize-100,
      game.size.y - margin - buttonSize,
    );
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // game.player.hasJumped = true;
    game.player.beginFire();
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // game.player.hasJumped = false;
    game.player.stopFire();
    super.onTapUp(event);
  }
}
