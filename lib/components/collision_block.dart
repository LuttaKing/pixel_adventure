import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  CollisionBlock({position, size,this.isPlatform=false})
      : super(
            position: position,
            size: size){
              // debugMode=true;
            } // super calls whatever is extending which is PosiComp
}
