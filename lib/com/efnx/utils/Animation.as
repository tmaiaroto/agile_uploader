package com.efnx.utils
{
	/**
	 * Copyright(C) 2007 Schell Scivally
	 *
	 * Animation is an Actionscript 3 class made to address the limitations of the builtin
	 * MovieClip class.
	 * 
	 * This file is one part of efnxAS3classes.
	 * 
	 * efnxAS3classes are free software; you can redistribute it and/or modify
	 * it under the terms of the GNU General Public License as published by
	 * the Free Software Foundation; either version 3 of the License, or
	 * (at your option) any later version.
	 * 
	 * efnxAS3classes are distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 * GNU General Public License for more details.
	 * 
	 * You should get a copy of the GNU General Public License
	 * at <http://www.gnu.org/licenses/>
	 */
	 
	/////////////////////////////////////////////////////////////////////////////////////////////
	//	The Animation class mimics the MovieClip class, but with better AS3 support           //
	/////////////////////////////////////////////////////////////////////////////////////////////////
	//      Use: var animation:Animation = new Animation([numFrames:int = 1, width=0, height=0]); //
	///////////////////////////////////////////////////////////////////////////////////////////////
	/**TODO
	*
	*	Finish implementation of acceleration functions. I had intended the acceleration functions 
	*	to be used in a way to mimic an animation like Sonic the Hedgehog, where the movement
	*	animation played through at a faster FPS depending on how fast the character is moving.
	*	It only kinda works. If you don't know what I'm talking about play more video games.
	*
	**/
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	public class Animation extends Sprite												// Create variables needed to mimic
	{																					// MovieClip.
		private var frame:int = 1;
		private var numFrames:int = 1;
		private var customFpsEnabled:Boolean = false;
		private var desiredFps:int = 0;
		private var timer:Timer;
		private var accelerometer:Timer;
		private var test:Boolean;
		
		protected var stopped:Boolean = false;
		protected var scriptArray:Array = new Array();
		protected var acceleration:Number = 0;
		protected var accelerating:Boolean = false;
		
		public var bm:Bitmap = new Bitmap();
		public var bmd:BitmapData;
		public var bmdArray:Array = new Array();
		public var currentFrame:int = 1;												// Create public readable versions 
		public var totalFrames:int = 1;													// of current and total frames.
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		public function Animation(frames:int = 1, width:int = 0, height:int = 0):void	// Can take the number of frames
		{																				// requested as a parameter, default is 1.
			numFrames = frames;
			totalFrames = frames;
			for(var j:int = 0; j<numFrames; j++)
			{
				scriptArray.push(0);														// Push 0 into the script array
			}
			
			if(width != 0 && height != 0)
			{
				bmd = new BitmapData(width, height, true, 0x00000000);
			}
			
			addEventListener(Event.ENTER_FRAME, everyFrame, false, 0, true);				// Run function everyFrame every frame
																							// to mimic a timeline.
			bm.bitmapData = bmd;
			addChild(bm);
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		protected function everyFrame(event:Event):void						// This gets ran every frame.
		{
			if(stopped || parent == null)
			{
				////trace("Animation:everyFrame(): stopped at:" + currentFrame + " scriptArray:" + scriptArray[currentFrame]);
			}else
			{
				////trace("Animation:everyFrame(): currentFrame:" + currentFrame + " scriptArray:" + scriptArray[currentFrame]);
				playScripts();
				
				if(frame == numFrames)
				{
					frame = 1;
				}else
				{
					frame++;
				}
				
			}
			
			currentFrame = frame;											// Set public currentFrame to frame.
			totalFrames = numFrames;										// Set totalFrames to numFrames in case someone chaged it.
		}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		private function playScripts():void										// Used by the class to play the current frames scripts
		{
			if(scriptArray[frame-1] is Function)
				{
					scriptArray[frame-1]();
				}else
				if(scriptArray[frame-1] is Array)
				{
					for(var i:int = 0; i< scriptArray[frame-1].length; i++)
					{
						scriptArray[frame-1][i]();
					}
				}else
				if(scriptArray[frame-1] is int)
				{
				}
		}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function addFrameScript(theFrame:int, theFunction:Function, ...rest):void			// Adds a script to the requested
		{																							// frame and fills other frames with null ones.
			if(theFrame > numFrames)
			{
				for(var i:int = numFrames; i<theFrame - 1; i++)
				{
					scriptArray.push(0)
				}
				scriptArray.push(theFunction);
			}else
			{
				scriptArray[theFrame-1] = theFunction;												// THIS WILL OVERWRITE THE CURRENT SCRIPT
			}
			
			update();
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function appendFrameScript(theFrame:int, theFunction:Function, testing:Boolean = false):void	// Appends another script to be
		{																									// run behind another in the SAME frame.
			if(theFrame > numFrames)
			{
				addFrameScript(theFrame, theFunction);												// Call addFrameScript if appending is
				//if(testing) //trace("Animation()::appendFrameScript(): frame not occupied, adding."); // is not needed.
			}else																					
			if(scriptArray[theFrame-1] is Function)
			{
				var array:Array = new Array();
				array[0] = scriptArray[theFrame-1];
				array[1] = theFunction;
				scriptArray[theFrame-1] = array;
				//if(testing) //trace("Animation()::appendFrameScript(): frame contains function, appending script in array.");
			}else
			if(scriptArray[theFrame-1] is Array)
			{
				scriptArray[theFrame-1].push(theFunction);
				//if(testing) //trace("Animation()::appendFrameScript(): frame contains functions, appending in array.");
			}else
			if(scriptArray[theFrame-1] is int)
			{
				addFrameScript(theFrame, theFunction);
				//if(testing) //trace("Animation()::appendFrameScript(): frame is empty, adding script.");
			}
			
			update();
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function gotoAndPlay(theFrame:int):void					// Skips to and plays the given frame
		{
			go();
			
			if(theFrame > numFrames)
			{
				theFrame -= numFrames;
			}
			
			frame = theFrame;
			currentFrame = frame;
			////trace("Animation::gotoAndPlay(): now in frame:" + frame);
			
			//playScripts();
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function gotoAndStop(theFrame:int):int	// Skips to and stops at the given frame after playing that frame
		{
			if(theFrame > numFrames)
			{
				theFrame -= numFrames;
			}
			frame = theFrame;
			currentFrame = frame;
			stopped = true;
			playScripts();
			
			return theFrame;
			////trace("Animation::gotoAndStop(): the script in the frame is: ", currentFrame);
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function stop():void					// Skips to and stops at the given frame
		{
			stopped = true;
			if(frame == 0)
			{
				frame++;
			}else
			{
				frame = frame - 1;
			}
			currentFrame = frame;
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function go():void					// plays the animation
		{
			stopped = false;
			////trace("Animation::go(): going.");
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function customFps(fps:int):void					// Enables a custom frame rate independent of ENTER_FRAME
		{
			var ms:int = Math.round(1000/fps);
			////trace("Animation::customFps(): customFpsEnabled:"+customFpsEnabled);
			if(!customFpsEnabled)
			{
				customFpsEnabled = true;
				removeEventListener(Event.ENTER_FRAME, everyFrame);
				timer = new Timer(ms);
				timer.addEventListener(TimerEvent.TIMER, everyFrame, false, 0, true);
				timer.start();
			}else
			{
				timer.stop();
				timer = new Timer(ms);
			}
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function accelerateFps(_desiredFps:Number, numberFrames:int):void		// accelerates the customFps (and overall animation)
		{																				// to desiredFps in numberFrames frames
			if(!accelerating && customFpsEnabled)
			{// must first be in customFps
				accelerating = true;
				desiredFps = _desiredFps;
				acceleration = (desiredFps - timer.delay)/numberFrames;
				accelerometer = new Timer(timer.delay, numberFrames);
				accelerometer.addEventListener(TimerEvent.TIMER, accelerate);
				accelerometer.addEventListener(TimerEvent.TIMER_COMPLETE, accelerometerComplete);
				accelerometer.start();
			}else
			{
				//trace("Animation::accelerateFps(): Animation MUST first have a custom FPS initiated using customFps(ms:int); before acceleration can occur");
			}
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function accelerate(event:TimerEvent):void		// accelerates the customFps (overall animation)
		{	
			////trace("Animation::accelerate(1): delay is: " + timer.delay + " acceleration=" + acceleration);
			if(timer.delay != desiredFps)
			{
				timer.delay += acceleration;
			}
			////trace("Animation::accelerate(2): delay is now: " + timer.delay);
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function accelerometerComplete(event:TimerEvent):void					// removes listeners and sets FPS
		{
			accelerometer.removeEventListener(TimerEvent.TIMER, accelerate);
			accelerometer.removeEventListener(TimerEvent.TIMER_COMPLETE, accelerometerComplete);
			timer.delay = desiredFps;
			////trace("Animation::accelerometerComplete(): desiredFps reached: " + timer.delay);
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function changeFps(newFPS:int):void					// Changes the FPS right away
		{
			timer.delay = newFPS;
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function appendBitmapData(theFrame:int, bitmapData:BitmapData):void			// Changes the bmd to next frame bmd
		{
			bmdArray[theFrame-1] = bitmapData;
			appendFrameScript(theFrame, animate);
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		protected function animate():void		//used by appendBitmapData to change the picture [bmd] during animation
		{
			bmd = bmdArray[frame-1];
			bm.bitmapData = bmd;
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		private function update():void					//updates the totalFrames
		{
			numFrames = scriptArray.length;
			totalFrames = numFrames;
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function appendToEachFrame(theFunction:Function):void	//appends a function to every frame
		{
			for(var i:int = 0; i<totalFrames; i++)
			{
				appendFrameScript(i-1, theFunction);
			}
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function centerBitmap(theFrame:int = 0):void	//centers the main bitmap
		{
			bm.x = 0 - bm.width/2;
			bm.y = 0 - bm.height/2;
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function checkBitmapDataSizes():Boolean	//checks to see if all the bmd's in bmdArray are the same size
		{
			var array:Array = new Array();
			for(var i:int = 0; i<bmdArray.length; i++)
			{
				array.push(bmdArray[i]);
			}
			return(bmdArray == array.sortOn(["width","height"], Array.NUMERIC));
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function get kill():Boolean
		{
			var i: int = 0;
			for(i = 0; i<bmdArray.length; i++)
			{
				delete bmdArray[i];
			}
			for(i = 0; i<scriptArray.length; i++)
			{
				delete scriptArray[i];
			}
			
			removeEventListener(Event.ENTER_FRAME, everyFrame);
			
			delete this;
			
			return true;
		}
	}//end class			
}//end package
