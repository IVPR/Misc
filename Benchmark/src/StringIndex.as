/*
    Weave (Web-based Analysis and Visualization Environment)
    Copyright (C) 2008-2011 University of Massachusetts Lowell

    This file is a part of Weave.

    Weave is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License, Version 3,
    as published by the Free Software Foundation.

    Weave is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Weave.  If not, see <http://www.gnu.org/licenses/>.
*/

package weave.utils
{
	import flash.utils.Dictionary;

	public class StringIndex
	{
		public function StringIndex(chunkSize:int = 6)
		{
			this.n = chunkSize;
			this.root = new Dictionary();
		}
		
		private var n:int;
		private var root:Dictionary;
		
		public function get(key:String):*
		{
			var o:* = root;
			while (key.length >= n)
			{
				var prefix:String = key.substring(0, n);
				var next:* = o[prefix];
				if (next === undefined)
					o[prefix] = next = new Dictionary();
				o = next;
				key = key.substr(n);
			}
			return o[key];
		}
		
		public function set(key:String, value:*):void
		{
			var o:* = root;
			while (key.length >= n)
			{
				var prefix:String = key.substring(0, n);
				var next:* = o[prefix];
				if (next === undefined)
					o[prefix] = next = new Dictionary();
				o = next;
				key = key.substr(n);
			}
			o[key] = value;
		}
	}
}
