import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class BulletComponent extends SpriteComponent with HasGameRef, CollisionCallbacks {
  static const speed = 100.0;
  late final Vector2 velocity;
  final Vector2 deltaPosition = Vector2.zero();

  BulletComponent({required super.position, super.angle, size})
      : super(size: size);

  @override
  Future<void> onLoad() async {
    debugMode = true;
    priority = 10;
    // add(CircleHitbox());
    sprite = Sprite(
      game.images.fromCache('Traps/Sand Mud Ice/Sand Particle.png'),
    );

    velocity = Vector2(1, 0)
      ..rotate(angle)
      ..scale(speed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    deltaPosition
      ..setFrom(velocity)
      ..scale(dt);
    position += deltaPosition;
    // print(position.x);
    // print(game.size.x);

    if (position.x > game.size.x) {
      removeFromParent();
    }
  }
}
