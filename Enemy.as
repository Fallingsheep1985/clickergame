package  {
	import flash.display.Stage;
    import flash.display.MovieClip;
    import flash.events.Event;
	import flash.media.Sound;
	
	public class Enemy extends MovieClip {
		
		public var stageRef:Stage;
		public static var EnemyX:int;
		public static var EnemyY:int;
		public var Enemyhitpoints:int;

			
        public function Enemy(stageRef:Stage, EnemyX:int, EnemyY:int){
            this.stageRef = stageRef;
			EnemyX=225;
			EnemyY=120;
            this.x = EnemyX;
            this.y = EnemyY;
			addEventListener(Event.ENTER_FRAME,onFrame);
        }

///////////////////////////////////////////////////////
//							Kill Enemy
///////////////////////////////////////////////////////
		public function killEnemy():void{
			Main.enemycontainer.removeChild(this);
			removeEventListener(Event.ENTER_FRAME,onFrame);
			var deadmurloc:Sound = new murloc();
			if (Main.soundeffects >= 1){
				deadmurloc.play();
			}
		}
///////////////////////////////////////////////////////
//							Main Loop
///////////////////////////////////////////////////////
		public function onFrame(e:Event):void {
			enemyhptxt.text = Enemyhitpoints.toString();
				if (Enemyhitpoints <= 0){
					killEnemy();
				}
		}	
		
	}//end class
}//end package
	
