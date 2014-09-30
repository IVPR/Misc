import flash.system.Capabilities;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;

private var t:Number;
private var i:int;
private var n:int = 0x10000;
private var d:Dictionary;
private var keyLength:int = 0;
private var a:Array;
private var v:*;
private var columns:Array;

public function init():void
{
	trace(Capabilities.version, Capabilities.playerType, Capabilities.isDebugger ? 'debugger' : '');
	var len:int = new Vector.<int>(0x1FFFFFF).length;
	getDefinitionByName('flash.system.System')['gc']();
	trace('ready', len);
	test();
}

public function initArray(keyLength:int):void
{
	var padding:String = '_________________________';
	//var padding:String = 'FFFFFFFFFFFFFFFFFFFFFFFFF';
	a = new Array(n).map(function(o:*, i:int, a:*):*{
		var hex:String = ('000' + i.toString(16)).substr(-4);
		//return (padding.substr(0, keyLength) + hex.split('').join('') + padding).substr(0, 17);
		
		if (keyLength < 0)
			return (padding + hex).substr(keyLength);
		return (hex + padding).substr(0, keyLength);
	});
}

public function test():void
{
	var records:Array = [];
	for each (var keyLength:int in [12,11,10,9,8,7,6,5,4,-4,-5,-6,-7,-8,-9,-10,-11,-12])
	//for each (var keyLength:int in [0,1,2,3,4,5,6,7,8,9,10,11,12,13])
	{
		initArray(keyLength);
		var record:Object = go();
		record['pattern'] = a[a.length-1];
		record['0:length'] = keyLength;
		printRecord(record);
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
	trace(columns.map(function(column:String, ..._):* { return record[column]; }).join('\t'));
}

private function go():Object
{
	getDefinitionByName('flash.system.System')['gc']();
	var result:Object = {};
	
	d = new Dictionary();
	t = new Date().time;
	for (i = 0; i < n; ++i)
	{
		d[a[i]];
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