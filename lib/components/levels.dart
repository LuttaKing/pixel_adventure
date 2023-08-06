import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  final String levelName;
  final Player player;

  Level({required this.player, required this.levelName});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackGround();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackGround() {
    final backGroundLayer = level.tileMap.getLayer('Background');

    const tileSize = 64;
    final numTilesY = (game.size.y / tileSize).floor();
    final numTilesX = (game.size.x / tileSize).floor();

    if (backGroundLayer != null) {
      final backGroundColor =
          backGroundLayer.properties.getValue('BackgroundColor');

      for (double y = 0; y < game.size.y / numTilesY; y++) {
        for (double x = 0; x < numTilesX; x++) {
          final backGroundTile = BackgroundTile(
            color: backGroundColor ?? 'Gray',
            position: Vector2(x * tileSize,
                y * tileSize - tileSize), // Vector2(0,0) means top left
          );
          add(backGroundTile);
        }
      }
    }
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap
        .getLayer<ObjectGroup>('Spawnpoints'); //layer you named in tiles

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player': //class name from tile map

            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);

            break;
          case 'Fruit': //class name from tile map

            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          case 'Saw':
          final isVertical = spawnPoint.properties.getValue('isVertical');
          final offNeg = spawnPoint.properties.getValue('offNeg');
          final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
              isVertical: isVertical,offNeg: offNeg,offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),size:  Vector2(spawnPoint.width, spawnPoint.height),);
            add(saw);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      // make sure layer exists

      // find all objects in collision layer and add to list
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform': // class name from tile map

            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);

            add(platform);

            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
