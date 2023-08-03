bool checkCollision(player, block) {
  final hitbox = player.hitbox;


  final playerX = player.position.x + hitbox.offsetX; // left of our player
  final playerY = player.position.y + hitbox.offsetY; //top of our player
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y; // top of block
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0 ? playerX - (hitbox.offsetX*2) - playerWidth : playerX; //if going left
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

// blockY + blockHeight gives bottom of the block
  return (fixedY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX);
}
