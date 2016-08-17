package  {
	import flash.geom.*;
    import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.System;
	
	public class Main extends Sprite {
		var debugtext:int = 1; // debug and console output 1 is on
		//Misc
		var ispaused:Boolean = false;
		var clicks:int = 0;
		public static var coins:int;
		var level:int = 1;
		var dambonus:int = 0;
		public static var xp:int;
		var perclickxp:Number = 1; // bonus xp per click
		var clickamount:int = 0;
		var clicksneeded:int = 2; // amount of clicks needed for bonus xp to apply
		var enemycount:int = 0;
		var enemyskilled:int;
		var clickdamage = 1;
		var enemybasexp = 1;//base xp gained for defeating an enemy
		//Controls
		var mousePressed:Boolean = false;
		//Save data
		var saveDataObject:SharedObject;
		//timers
		public var timer:Timer = new Timer(60);
		public var timerCount:int = 0;
		public var globaltimerCount:int = 0;
		public var currentseconds:int = 0;
		public var currentminutes:int = 0;
		public var currenthours:int = 0;
		public var globalseconds:int = 0;
		public var globalminutes:int = 0;
		public var globalhours:int = 0;
		public var totalTimeplayed:int = 0;
		var worldtext:int = 1;
		
		public static var soundeffects:int = 0;
		
		public static var environment:environment_mc = new environment_mc();
		public var pausescreen:pausescreen_mc = new pausescreen_mc();
		public static var enemycontainer:enemycontainer_mc = new enemycontainer_mc();
		public static var enemydiffculty = 1;

		//XP
		var l1xp:int = 99;
		var l2xp:int = 399;
		var l3xp:int = 799;
		var l4xp:int = 1499;
		var l5xp:int = 3499;
		var l6xp:int = 4999;
		var l7xp:int = 7999;
		var l8xp:int = 9999;
		var l9xp:int = 14999;
		var l10xp:int = 19999;
		var l11xp:int = 24999;
		
		//WORLD LEVELS
		var killsworld2:int = 10;
		var killsworld3:int = 20;
		var killsworld4:int = 30;
		var killsworld5:int = 40;
		var killsworld6:int = 50;
		var killsworld7:int = 60;
		var killsworld8:int = 70;
		var killsworld9:int = 80;
		var killsworld10:int = 90;
		var killsworld11:int = 100;
		
		public function Main() {
			stage.addEventListener(Event.ENTER_FRAME,mainloop);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			if(debugtext == 1){
				trace ("Game Intialised");
			}
			//Pause
			pausegame_btn.addEventListener(MouseEvent.CLICK, openpausescreen);
			pausescreen.unpause_btn.addEventListener(MouseEvent.CLICK, closepausescreen);
			pausescreen.clearsavedata.addEventListener(MouseEvent.CLICK, clearSave, false, 0, true);
			pausescreen.buydam_btn.addEventListener(MouseEvent.CLICK, buyDam, false, 0, true);
			
			//environment
			addChild(environment);
			setChildIndex(environment,0);
			environment.x=0;
			environment.y=0;
			environment.gotoAndStop(1);//go to first stage
			
			//Add action enemycontainer
			addChild(enemycontainer);
			//setChildIndex(enemycontainer,0)
			enemycontainer.x=0;
			enemycontainer.y=0;
			
			
			pausescreen.soundeffectsbtn.addEventListener(MouseEvent.CLICK, togglesound, false, 0, true);
			//TImer
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, timerTickHandler);
			loadData(); // load saved data		
			
			flashhit.visible = false;
			//Set text stuff
			if(soundeffects == 0){
				pausescreen.soundeffects_txt.text = "OFF";
			} else {
				pausescreen.soundeffects_txt.text = "ON";
			}
			
		}
		public function togglesound(e:MouseEvent):void {
			if(soundeffects == 0){
				soundeffects = 1;
				pausescreen.soundeffects_txt.text = "ON";
			} else {
				soundeffects = 0;
				pausescreen.soundeffects_txt.text = "OFF";
			}
		}
		public function pauseloop(e:Event):void{
			ClearText(); // clears text
		}
		public function mainloop(e:Event):void{
			updateText(); //update text
			levelCheck(); // check level /xp
			createEnemy(); // create enemy
			debugstuff(); // FPS RAM
		}
		public function changeworld():void{
			if (enemyskilled >= killsworld2){
				worldtext = 2;
				enemydiffculty = 5;
				environment.gotoAndStop(2);//go to first stage
			}
			if (enemyskilled >= killsworld3){
				worldtext = 3;
				enemydiffculty = 25;
				environment.gotoAndStop(3);//go to first stage
			}
			if (enemyskilled >= killsworld4){
				worldtext = 4;
				enemydiffculty = 50;
				environment.gotoAndStop(4);//go to first stage
			}
			if (enemyskilled >= killsworld5){
				worldtext = 5;
				enemydiffculty = 100;
				environment.gotoAndStop(5);//go to first stage
			}
			if (enemyskilled >= killsworld6){
				worldtext = 6;
				enemydiffculty = 150;
				environment.gotoAndStop(6);//go to first stage
			}
			if (enemyskilled >= killsworld7){
				worldtext = 7;
				enemydiffculty = 300;
				environment.gotoAndStop(7);//go to first stage
			}
			if (enemyskilled >= killsworld8){
				worldtext = 8;
				enemydiffculty = 500;
				environment.gotoAndStop(8);//go to first stage
			}
			if (enemyskilled >= killsworld9){
				worldtext = 9;
				enemydiffculty = 750;
				environment.gotoAndStop(9);//go to first stage
			}
			if (enemyskilled >= killsworld10){
				worldtext = 10;
				enemydiffculty = 1000;
				environment.gotoAndStop(10);//go to first stage
			}
			if (enemyskilled >= killsworld11){
				worldtext = 11;
				enemydiffculty = 1250;
				environment.gotoAndStop(11);//go to first stage
			}
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//						enemy
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
		var enemyArray:Array = [];//holds enemys
		
		public function createEnemy():void {
			if (enemycount < 1){
			var enemy:Enemy = new Enemy(stage, Enemy.EnemyX, Enemy.EnemyY);
			//Add event to enemy to remove them from array when removed from stage
			enemy.addEventListener(Event.REMOVED_FROM_STAGE, enemyRemoved, false, 0, true);
			//add enemy to array
			enemyArray.push(enemy);
			//add enemy to stage
			enemycontainer.addChild(enemy);
			enemycount = 1;
			enemy.Enemyhitpoints = (1 + enemydiffculty);
			}
		}
		public function enemyHit():void{
			for (var idx:int = enemyArray.length - 1; idx >= 0; idx--){
				var enemy1:Enemy = enemyArray[idx];
				if (this.contains(enemy1)){
					enemy1.Enemyhitpoints -= clickdamage;
				}
			}
		}
				//removes enemy from array
		public function enemyRemoved(ee:Event):void{
			enemyArray.splice(enemyArray.indexOf(ee.currentTarget),1);
			//remove the event listner from current enemy
			ee.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, enemyRemoved);
			if(debugtext == 1){
				trace ("Enemy Killed!");
			}
			enemycount = 0;
			coins += level;
			xp += (enemybasexp + enemydiffculty);
			enemyskilled += 1;
			//check if world should change
			changeworld();
		}
		
		public function mouseDownHandler(e:MouseEvent):void {
			mousePressed = true; //set mousePressed to true
			if(ispaused == false){
				clicks += 1; // add 1 to click total
				clickamount += 1;
				//BONUS XP PER CLICK
				if (clickamount >= clicksneeded){
					xp += perclickxp; // add bonus xp
					clickamount = 0; // reset click amount
				}
				flashhit.visible = true;
				enemyHit();
				saveData(); // save game data
			}
			
		}
		public function mouseUpHandler(e:MouseEvent):void {
			mousePressed = false; //reset this to false
			flashhit.visible = false;
		}
		//Display text
		public function updateText():void{
			world_txt.text = worldtext.toString();
			clicks_txt.text = clicks.toString();
			coins_txt.text = coins.toString();
			level_txt.text = level.toString();
			xp_txt.text = xp.toFixed();
			damage_txt.text = clickdamage.toString();
			kills_txt.text = enemyskilled.toString();
		}
		public var textshown:Boolean = false;
		public var SecondsElapsed:Number = 0;
		//Rank up timer checker
		public function ClearText():void{
			//check if player has speedpack
			if (textshown = true){
				//increase timer
				SecondsElapsed += 1;
				//check if timer has "ticked" 2 times (2seconds)
				if (SecondsElapsed >= 50){
					SecondsElapsed = 0;
					pausescreen.buydamtext.text = "";
					if(debugtext == 1){
						trace ("Text Cleard");
					}
				}
			}
		}
		
		public function buyDam(e:MouseEvent):void{
				if (coins >= 100){
					clickdamage += 1;
					coins -= 100;
					pausescreen.buydamtext.text = "Bought!";
					textshown = true;
				}else{
					pausescreen.buydamtext.text = "Not Enough Coins!";
					textshown = true;
				}
		}
		public function levelCheck():void{
			if (xp <= l1xp){
				level = 1;
			}
			if (xp >= l2xp){
				level = 2;
			}
			if (xp >= l3xp){
				level = 3;
			}
			if (xp >= l4xp){
				level = 4;
			}
			if (xp >= l5xp){
				level = 5;
			}
			if (xp >= l6xp){
				level = 6;
			}
			if (xp >= l7xp){
				level = 7;
			}
			if (xp >= l8xp){
				level = 8;
			}
			if (xp >= l9xp){
				level = 9;
			}
			if (xp >= l10xp){
				level = 10;
			}
			if (xp >= l11xp){
				level = 11;
			}
		}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//							Time Played
//////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		
		public function timerTickHandler(Event:TimerEvent):void
		{
			timerCount += 60;
			timePlayed(timerCount);
		}
		public function timerReset():void{
			timer.stop();
			timerCount = 0;
			timeplayedtext.text = "00:00:00";
			timer.start();
		}
		
		public function timePlayed(milliseconds:int):void{
			var time:Date = new Date(milliseconds);
			
			var minutes:int = time.minutes;
			var seconds:int = time.seconds;
			var hours:int = time.hours;
			
			var displayhours:String = hours.toString();
			var displayminutes:String = minutes.toString();
			var displayseconds:String = seconds.toString();
			
			displayseconds = ((timerCount /1000).toFixed(0)).toString();
			displayminutes = (currentminutes).toString();
			displayhours = (currenthours).toString();
			
			displayhours = (displayhours.length != 2) ? '0'+displayhours : displayhours;
			displayminutes = (displayminutes.length != 2) ? '0'+displayminutes : displayminutes;
			displayseconds = (displayseconds.length != 2) ? '0'+displayseconds : displayseconds;

			timeplayedtext.text = displayhours + ":" +displayminutes + ":" + displayseconds; //toatal time played
			totalTimeplayed = minutes;
		}
		
		var frames:int=0;
		var FPS:int=0;
		var prevTimer:Number=0;
		var curTimer:Number=0;
		
		public function debugstuff():void{
			if(debugtext == 1){
				debugmemorytext.visible = true;
				ramtxt.visible = true;
				fpstxt.visible = true;
				debugfpstext.visible = true;
				frames+=1;
				curTimer=getTimer();
					if(curTimer-prevTimer>=1000){
						FPS = Math.round(frames*1000/(curTimer-prevTimer));
					
						prevTimer=curTimer;
						frames=0;
					}
				debugmemorytext.text = ((System.totalMemory / 1024 / 1024).toFixed(2)).toString() + "MB";
				debugfpstext.text = FPS.toString();
			}else{
				debugmemorytext.visible = false;
				ramtxt.visible = false;
				fpstxt.visible = false;
				debugfpstext.visible = false;
			}
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//							PAUSE GAME
//////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		public function openpausescreen(e:MouseEvent):void{
			if (ispaused == false){
				ispaused = true;
				stage.addEventListener(Event.ENTER_FRAME,pauseloop);
				stage.removeEventListener(Event.ENTER_FRAME,mainloop);
				if(debugtext == 1){
					trace("GAME PAUSED");
				}
				stage.addChild(pausescreen);
			}
		}
		public function closepausescreen(e:MouseEvent):void{
			if (ispaused == true){
				ispaused = false;
				stage.removeEventListener(Event.ENTER_FRAME,pauseloop);
				stage.addEventListener(Event.ENTER_FRAME,mainloop);
				if(debugtext == 1){
					trace("GAME RESUMED");
				}
				if(stage.contains(pausescreen)){
					stage.removeChild(pausescreen);
				}
			}
		}
		//Save game data
		public function saveData(){
			saveDataObject = SharedObject.getLocal("clicktest"); 
			saveDataObject.data.savedcoins = coins;
			saveDataObject.data.savedclicks = clicks;
			saveDataObject.data.savedxp = xp;
			saveDataObject.data.savedlevel = level;
			saveDataObject.data.savedtotalTimeplayed = totalTimeplayed;
			saveDataObject.data.savesoundeffects = soundeffects;
			saveDataObject.data.enemyskilled = enemyskilled;
			saveDataObject.flush(); // immediately save to the local drive
			if(debugtext == 1){
				trace("Data Saved");
			}
		}
		//load game data
		public function loadData():void{
			saveDataObject = SharedObject.getLocal("clicktest"); 
			coins = saveDataObject.data.savedcoins;
			clicks = saveDataObject.data.savedclicks;
			xp = saveDataObject.data.savedxp;
			level = saveDataObject.data.savedlevel;
			totalTimeplayed = saveDataObject.data.savedtotalTimeplayed;
			soundeffects = saveDataObject.data.savesoundeffects;
			enemyskilled = saveDataObject.data.enemyskilled;
			if(debugtext == 1){
				trace("Data Loaded");
			}
		}
		public function clearSave(e:MouseEvent):void{
			saveDataObject = SharedObject.getLocal("clicktest"); 
			saveDataObject.data.savedcoins = 0;
			saveDataObject.data.savedclicks = 0;
			saveDataObject.data.savedxp = 0;
			saveDataObject.data.savedlevel = 0;
			saveDataObject.data.savedtotalTimeplayed = 0;
			saveDataObject.data.savesoundeffects = 0;
			saveDataObject.data.enemyskilled = 0;
			saveDataObject.flush(); // immediately save to the local drive
			timerReset();
			loadData(); // load cleared data
			if(debugtext == 1){
				trace("Data Reset");
			}
			RESTARTGAME();
		}
		private function RESTARTGAME():void {
   			var url:String = stage.loaderInfo.url;
  	 		var request:URLRequest = new URLRequest(url);
   			navigateToURL(request,"_level0");
			if(debugtext == 1){
				trace ("Game Restarted");
			}
		}
		
	}//end class
}//end package
