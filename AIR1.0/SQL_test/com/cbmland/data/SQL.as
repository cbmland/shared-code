package com.cbmland.data
{
	import flash.display.*;
	import flash.net.*;
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.*;

	
	public class SQL extends Sprite
	{

		public static const CANCEL:String = "cancel" 
		public static const CLOSE:String = "close" 
		public static const OPEN:String = "open" 
		public static const RESULT:String = "result" 
		public static const ERROR:String = "error" 
		
		
		private var _sqlStatement:SQLStatement = new SQLStatement();
		private var _sqlConnection:SQLConnection = new SQLConnection();
		public function get connected():Boolean {
			return _sqlConnection.connected
		}
		public function get pageSize():uint {
			return _sqlConnection.pageSize
		}
		public function get totalChanges():Number {
			return _sqlConnection.totalChanges
		}
		private var _dbFile:File
		public function set dbFile(dbFile:File):void{
			_dbFile=dbFile;
		}
		public function get dbFile():File{
			return _dbFile;
		}
		private var _text:String=''
		public function set text(sql:String):void{
			_text=sql;
			_sqlStatement.text=sql;
		}
		public function get text():String{
			return _text;
		}
		public function SQL()
		{
			_sqlConnection.addEventListener(SQLEvent.OPEN, _sqlConnection_OPEN);
			_sqlConnection.addEventListener(SQLErrorEvent.ERROR, _sqlConnection_ERROR);
			_sqlStatement.addEventListener(SQLEvent.RESULT, _sqlStatement_RESULT);
			_sqlStatement.addEventListener(SQLErrorEvent.ERROR, _sqlStatement_ERROR);
			_sqlStatement.sqlConnection=_sqlConnection
		}
		public function open(dbFile:File=null):void{
			if(dbFile is File){_dbFile=dbFile;}
				_sqlConnection.open(_dbFile);

		}
		public function execute(prefetch:int = -1, responder:Responder = null):void{
			
			_sqlStatement.execute(prefetch,responder);
		}
		public function next(prefetch:int = -1, responder:Responder = null):void{
			_sqlStatement.next(prefetch,responder);
		}
		public function cancel():void {
			_sqlStatement.cancel()
		}
		public function clearParameters():void {
			_sqlStatement.clearParameters()
		}
		public function getResult(){
			return _sqlStatement.getResult();
		}
		public function close(responder:Responder = null):void {
			_sqlConnection.close()
		}
		private function _sqlStatement_ERROR(event:SQLErrorEvent):void
				{
				    this.dispatchEvent(new SQLErrorEvent(event.type,event.bubbles,event.cancelable,event.error));
				}
		private function _sqlStatement_RESULT(event:SQLEvent):void
				{
				    this.dispatchEvent(new SQLEvent(event.type,event.bubbles,event.cancelable));
				}
		private function _sqlConnection_OPEN(event:SQLEvent):void
				{
				    this.dispatchEvent(new SQLEvent(event.type,event.bubbles,event.cancelable));
				}
				
		private function _sqlConnection_ERROR(event:SQLErrorEvent):void
				{
					this.dispatchEvent(new SQLErrorEvent(event.type,event.bubbles,event.cancelable,event.error));
				}

	}
}