import avmplus.getQualifiedClassName;

import de.polygonal.ds.IntHashTable;

import flash.system.Capabilities;
import flash.system.System;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import weave.flascc.stringHash;

private var t:int;
private var i:int;
private var n:int = 0x10000;
private var numDigits:int = 4;
private var d:*;
private var h:IntHashTable;
private var hSize:int = 1024;
private var keyLength:int = 0;
private var a:Array;
private var a2:Array;
private var v:*;
private var columns:Array;

public function init():void
{
	trace(Capabilities.version, Capabilities.playerType, Capabilities.isDebugger ? 'debugger' : '');
	var len:int = new Vector.<int>(0x1FFFFFF).length;
	System.gc();
	trace('ready', len);
	//testTimer();
	test();
}

public function initArray(keyLength:int):void
{
	var padding:String = '_________________________';
	//var padding:String = 'FFFFFFFFFFFFFFFFFFFFFFFFF';
	a = new Array(n).map(function(o:*, i:int, a:*):*{
		var hex:String = ('00000000000' + i.toString(16)).substr(-numDigits);
		//return (padding.substr(0, keyLength) + hex.split('').join('') + padding).substr(0, 8);
		
		if (keyLength < 0)
			return (padding + hex).substr(keyLength);
		return (hex + padding).substr(0, keyLength);
	});
	a2 = a.map(function(v:*, k:*, a:*):* { return {v: v}; });
}

public function test():void
{
	var records:Array = [];
	var record:Object;
	
	//for each (var keyLength:int in [4,3,2,1,0,0,1,2,3,4,4,3,2,1,0,0,1,2,3,4,4,3,2,1,0,0,1,2,3,4,4,3,2,1,0,0,1,2,3,4,4,3,2,1,0,0,1,2,3,4])
	//for each (var keyLength:int in [0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4])
	//for each (var keyLength:int in [4,3,2,1,0])
	//for each (var keyLength:int in [3,3,2,4,1,0])
	for each (var keyLength:int in [12,11,10,9,8,7,6,5,4,-4,-5,-6,-7,-8,-9,-10,-11,-12])
	//for each (var keyLength:int in [0,1,2,3,4,5,6,7,8,9,10,11,12,13])
	{
		initArray(keyLength);
		
		printRecord(testStringHash(Object));
//		printRecord(testStringHash(Dictionary));
//		printRecord(testStringHash(Array));
//		printRecord(testStringHash(Vector.<Object>));
		
		printRecord(testDictionary());
		
		//printRecord(testHashTable());
		
		a = a2;
		printRecord(testDictionary(true));
	}
}

private function printRecord(record:Object):void
{
	record['pattern'] = a[a.length - 1];
	if (!columns)
	{
		columns = [];
		for (var column:String in record)
			columns.push(column);
		columns.sort();
		trace(columns.map(function(column:String, ..._):String { return column.split(':').pop(); }).join('\t'));
	}
	//var stats:String = '\t' + Math.round(100*System.freeMemory/System.totalMemory)+'%';
	trace(columns.map(function(column:String, ..._):* { return record[column]; }).join('\t'));
}

private function testStringHash(Type:Object):Object
{
	System.gc();
	var result:Object = {};
	result['0:class'] = (getQualifiedClassName(Type).split("::").pop() as String).substr(0, 3) + '[h]';
	
	d = new Type();
	d.length = 0xFFFFFF; // note: insufficient for production code
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		d[weave.flascc.stringHash(a[i])];
	}
	t = getTimer() - t;
	result['1:miss1'] = t;
	
	d = new Type();
	d.length = 0xFFFFFF; // note: insufficient for production code
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		d[weave.flascc.stringHash(a[i])];
	}
	t = getTimer() - t;
	result['2:miss2'] = t;
	
	d = new Type();
	d.length = 0xFFFFFF; // note: insufficient for production code
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		d[weave.flascc.stringHash(a[i])] = Type;
	}
	t = getTimer() - t;
	result['3:set'] = t;
	
	//d = new Type();
	//d.length = 0xFFFFFF; // note: insufficient for production code
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		v = d[weave.flascc.stringHash(a[i])];
	}
	t = getTimer() - t;
	result['4:get'] = t;
	
	return result;
}

// added length checking is much slower
private function testStringHashLengthChecking(Type:Object):Object
{
	System.gc();
	var result:Object = {};
	result['0:class'] = 'L-' + (getQualifiedClassName(Type).split("::").pop() as String).substr(0, 3);
	
	var hash:int;
	
	d = new Type();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		hash = weave.flascc.stringHash(a[i]);
		if (d.length <= hash)
			d.length = hash + 1;
		d[hash];
	}
	t = getTimer() - t;
	result['1:miss1'] = t;
	
	d = new Type();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		hash = weave.flascc.stringHash(a[i]);
		if (d.length <= hash)
			d.length = hash + 1;
		d[hash];
	}
	t = getTimer() - t;
	result['2:miss2'] = t;
	
	d = new Type();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		hash = weave.flascc.stringHash(a[i]);
		if (d.length <= hash)
			d.length = hash + 1;
		d[hash] = Type;
	}
	t = getTimer() - t;
	result['3:set'] = t;
	
	//d = new Type();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		hash = weave.flascc.stringHash(a[i]);
		if (d.length <= hash)
			d.length = hash + 1;
		v = d[hash];
	}
	t = getTimer() - t;
	result['4:get'] = t;
	
	return result;
}

private function testDictionary(objectKeys:Boolean = false):Object
{
	System.gc();
	var result:Object = {};
	result['0:class'] = (getQualifiedClassName(Dictionary).split("::").pop() as String).substr(0, 3) + (objectKeys ? '[o]' : '');
	
	d = new Dictionary();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		d[a[i]];
	}
	result['1:miss1'] = getTimer() - t;
	
	d = new Dictionary();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		d[a[i]];
	}
	result['2:miss2'] = getTimer() - t;
	
	d = new Dictionary();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		d[a[i]] = 1234;
	}
	result['3:set'] = getTimer() - t;
	
	//d = new Dictionary();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		v = d[a[i]];
	}
	result['4:get'] = getTimer() - t;
	
	return result;
}

private function newHashTable():void
{
	if (h)
	{
		h.clear(true);
		h.free();
		h = null;
		System.gc();
	}
	h = new IntHashTable(hSize);
}

// too slow
private function testHashTable():Object
{
	System.gc();
	var result:Object = {};
	result['0:class'] = (getQualifiedClassName(IntHashTable).split("::").pop() as String).substr(0, 6);
	
	newHashTable();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		h.get(i);
	}
	result['1:miss1'] = getTimer() - t;
	
	newHashTable();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		h.get(i);
	}
	result['2:miss2'] = getTimer() - t;
	
	newHashTable();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		h.setIfAbsent(i, result);
	}
	result['3:set'] = getTimer() - t;
	
	//newHashTable();
	t = getTimer();
	for (i = 0; i < n; ++i)
	{
		v = h.get(i);
	}
	result['4:get'] = getTimer() - t;
	
	return result;
}

// getTimer() gives better performance than new Date().time. There is no way to test which gives better accuracy.
private function testTimer():void
{
	var I:int;
	var N:Number;
	
	t = getTimer();
	for (i = 0; i < n; ++i)
		I = new Date().time;
	t = getTimer() - t;
	trace(t,'ms','var I:int = new Date().time;');
	
	t = getTimer();
	for (i = 0; i < n; ++i)
		N = new Date().time;
	t = getTimer() - t;
	trace(t,'ms','var N:Number = new Date().time;');
	
	t = getTimer();
	for (i = 0; i < n; ++i)
		I = getTimer();
	t = getTimer() - t;
	trace(t,'ms','var I:int = getTimer();');
	
	t = getTimer();
	for (i = 0; i < n; ++i)
		N = getTimer();
	t = getTimer() - t;
	trace(t,'ms','var N:Number = getTimer();');
}
