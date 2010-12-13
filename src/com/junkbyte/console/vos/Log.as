/*
* 
* Copyright (c) 2008-2010 Lu Aye Oo
* 
* @author 		Lu Aye Oo
* 
* http://code.google.com/p/flash-console/
* 
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
* 
*/
package com.junkbyte.console.vos {
	
	public class Log{
		public var t:String;
		public var c:String;
		public var p:int;
		public var r:Boolean;
		public var s:Boolean;
		//
		public var next:Log;
		public var prev:Log;
		//
		public function Log(txt:String, ch:String, pr:int, repeating:Boolean = false, skipSafe:Boolean = false){
			t = txt;
			c = ch;
			p = pr;
			r = repeating;
			s = skipSafe;
		}
		public function toObject():Object{
			return {t:t, c:c, p:p, r:r};
		}
		public function toString():String{
			return "["+c+"] " + t;
		}
		public function clone():Log{
			return new Log(t, c, p, r, s);
		}
	}
}
