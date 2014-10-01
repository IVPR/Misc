import de.polygonal.ds.HashKey;
import de.polygonal.ds.IntHashTable;

import flash.system.Capabilities;
import flash.system.System;
import flash.utils.Dictionary;

import weave.flascc.stringHash;

private var t:Number;
private var i:int;
private var n:int = 0x10000;
private var numDigits:int = 4;
private var d:Dictionary;
private var h:IntHashTable;
private var hSize:int = 1024;
private var keyLength:int = 0;
private var a:Array;
private var v:*;
private var columns:Array;

public function init():void
{
	trace(Capabilities.version, Capabilities.playerType, Capabilities.isDebugger ? 'debugger' : '');
	var len:int = new Vector.<int>(0x1FFFFFF).length;
	System.gc();
	trace('ready', len);
	test();
}

public function initArray(keyLength:int):void
{
	var padding:String = '_________________________';
	//var padding:String = 'FFFFFFFFFFFFFFFFFFFFFFFFF';
	a = new Array(n).map(function(o:*, i:int, a:*):*{
		var hex:String = ('00000000000' + i.toString(16)).substr(-numDigits);
		return (padding.substr(0, keyLength) + hex.split('').join('') + padding).substr(0, 8);
		
		if (keyLength < 0)
			return (padding + hex).substr(keyLength);
		return (hex + padding).substr(0, keyLength);
	});
}

public function test():void
{
	var records:Array = [];
	var record:Object;
	
	for each (var keyLength:int in [4,3,2,1,0,0,1,2,3,4,4,3,2,1,0,0,1,2,3,4,4,3,2,1,0,0,1,2,3,4,4,3,2,1,0,0,1,2,3,4,4,3,2,1,0,0,1,2,3,4])
	//for each (var keyLength:int in [0,1,2,3,4,0,1,2,3,4,0,1,2,3,4])
	//for each (var keyLength:int in [4,3,2,1,0])
	//for each (var keyLength:int in [3,3,2,4,1,0])
	//for each (var keyLength:int in [12,11,10,9,8,7,6,5,4,-4,-5,-6,-7,-8,-9,-10,-11,-12])
	//for each (var keyLength:int in [0,1,2,3,4,5,6,7,8,9,10,11,12,13])
	{
		initArray(keyLength);
		var pattern:String = a[a.length-1];
		
		record = testDictionary();
		//record['Class'] = 'Dict';
		record['pattern'] = pattern;
		//record['0:length'] = keyLength;
		printRecord(record);
		
//		record = testHashTable();
//		record['Class'] = 'IntHM';
//		record['pattern'] = pattern;
//		record['0:length'] = keyLength;
//		printRecord(record);
	}
}

private function printRecord(record:Object):void
{
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

private function testDictionary():Object
{
	System.gc();
	var result:Object = {};
	
	/*
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		weave.flascc.stringHash(a[i]);
	}
	result['h0:hash'] = new Date().time - t;
	*/
	
	d = new Dictionary();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		d[weave.flascc.stringHash(a[i])];
	}
	result['h1:hmiss1'] = new Date().time - t;
	
	d = new Dictionary();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		d[weave.flascc.stringHash(a[i])];
	}
	result['h2:hmiss2'] = new Date().time - t;
	
	d = new Dictionary();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		d[weave.flascc.stringHash(a[i])] = 1234;
	}
	result['h3:hset'] = new Date().time - t;
	
	//d = new Dictionary();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		v = d[weave.flascc.stringHash(a[i])];
	}
	result['h4:hget'] = new Date().time - t;
	
	d = new Dictionary();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		d[weave.flascc.stringHash(a[i])];
	}
	result['1:miss1'] = new Date().time - t;
	
	d = new Dictionary();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		d[a[i]];
	}
	result['2:miss2'] = new Date().time - t;
	
	d = new Dictionary();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		d[a[i]] = 1234;
	}
	result['3:set'] = new Date().time - t;
	
	//d = new Dictionary();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		v = d[a[i]];
	}
	result['4:get'] = new Date().time - t;
	
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

private function testHashTable():Object
{
	System.gc();
	var result:Object = {};
	
	newHashTable();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		h.get(i);
	}
	result['1:miss1'] = new Date().time - t;
	
	newHashTable();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		h.get(i);
	}
	result['2:miss2'] = new Date().time - t;
	
	newHashTable();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		h.setIfAbsent(i, result);
	}
	result['3:set'] = new Date().time - t;
	
	//newHashTable();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		v = h.get(i);
	}
	result['4:get'] = new Date().time - t;
	
	return result;
}
