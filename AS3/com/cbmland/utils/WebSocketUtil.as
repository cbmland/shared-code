package com.cbmland.utils
{
	import com.adobe.crypto.MD5;
	import com.adobe.crypto.SHA1;
	
	import flash.utils.ByteArray;
	
	/**
	 * WebSocket 连接握手协议工具类，支持Safari和Chrome。
	 * @author CBM
	 * 
	 */
	public class WebSocketUtil
	{
		public static const SEC_WEBSOCKET_KEY:String = 'Sec-WebSocket-Key';
		public static const SEC_WEBSOCKET_KEY1:String = 'Sec-WebSocket-Key1';
		public static const SEC_WEBSOCKET_KEY2:String = 'Sec-WebSocket-Key2';
		public static const SEC_WEBSOCKET_VERSION:String = "Sec-WebSocket-Version";
		public static const NEWLINE:String = '\r\n';
		public static const key:String = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
		
		public static const HTTP_HEADER_ORIGIN:String = "Origin";
		public static const HTTP_HEADER_HOST:String = "Host";
		
		public static var charset:String = 'utf-8';
		
		private var dataString:String;
		private var dataBuffer:ByteArray;

		private var secWebSocketVersion:int;
		
		public function WebSocketUtil()
		{
			
		}
		public function handshake(requestByte:ByteArray):ByteArray
		{
			dataBuffer = requestByte;
			
			dataString = dataBuffer.readMultiByte(dataBuffer.length,charset);
			
			var secWebSocketKey:String = getHeaderValue(SEC_WEBSOCKET_KEY);
			var secWebSocketKey1:String = getHeaderValue(SEC_WEBSOCKET_KEY1);
			var secWebSocketKey2:String = getHeaderValue(SEC_WEBSOCKET_KEY2);
			secWebSocketVersion = parseInt(getHeaderValue(SEC_WEBSOCKET_VERSION));
			
			var httpHeader:String;
			
			if(secWebSocketKey1 && secWebSocketKey2)
			{
				//handshack safari
				
				var key3:String = StringHelper.buf2hexstr(getContentBytes(),0,0,false);
				
				var numkey1:uint = parseInt(secWebSocketKey1.replace(/[^\d]/g, ""), 10);
				var numkey2:uint = parseInt(secWebSocketKey2.replace(/[^\d]/g, ""), 10);
				
				var spaces1:uint = secWebSocketKey1.replace(/[^\ ]/g, "").length;
				var spaces2:uint = secWebSocketKey2.replace(/[^\ ]/g, "").length;
				
				var key1:String = StringHelper.int2hexstr(int(numkey1/spaces1),true);
				var key2:String = StringHelper.int2hexstr(int(numkey2/spaces2),true);
				
				var byte:ByteArray = StringHelper.hexstr2buf(key1+key2+key3);
				
				var result:String = MD5.hashBytes(byte);
				
				var content:ByteArray = StringHelper.hexstr2buf(result);
				
				var origin:String = getHeaderValue(HTTP_HEADER_ORIGIN);
				var host:String = getHeaderValue(HTTP_HEADER_HOST);
				
				httpHeader =
					
				"HTTP/1.1 101 WebSocket Protocol Handshake"+NEWLINE+
				"Upgrade: WebSocket"+NEWLINE+
				"Sec-WebSocket-Origin: "+origin+NEWLINE+
				"Sec-WebSocket-Location: ws://"+host+"/"+NEWLINE+
				"Connection: Upgrade"+NEWLINE+NEWLINE;


			}else if(secWebSocketVersion>7 && secWebSocketKey)
			{
				//handshack chomre
				
				var value:String = secWebSocketKey+key;
				
				value = SHA1.hash(value);

				var hash:ByteArray;
				
				hash = StringHelper.hexstr2buf(value);
				
				var chan:String = Base64.encodeByteArray(hash);
				
				httpHeader = 
				"HTTP/1.1 101 Switching Protocols"+NEWLINE+
				"Upgrade: websocket"+NEWLINE+
				"Connection: Upgrade"+NEWLINE+
				"Sec-WebSocket-Accept: "+ chan +NEWLINE+NEWLINE;
			}
			
			var responseByte:ByteArray = new ByteArray();
			responseByte.writeMultiByte(httpHeader,charset);
			
			if(content)
			{
				responseByte.writeBytes(content,0,content.length);
			}
			
			return responseByte;
			
		}
		protected function getHeaderValue(key:String):String
		{
			var reg:RegExp = new RegExp(key+": (.*)"+NEWLINE,"");
			var keys:Array = dataString.match(reg);
			var value:String;
			if(keys)
			{
				value = keys[1];
			}
			return value;
		}
		protected function getContentBytes():ByteArray
		{
			var index:int = dataString.indexOf(NEWLINE+NEWLINE);
			
			var content:ByteArray = new ByteArray();
			
			dataBuffer.position = index+4;
			
			content.writeBytes(dataBuffer,index+4,dataBuffer.bytesAvailable)
			
			return content;
		}

		/**
		 * 封装数据 
		 * @param msg
		 * @return 
		 * 
		 */		
		public function wrapData(msg:*):ByteArray
		{
			
			if(secWebSocketVersion>7)
			{
				return wrapChrome(msg);
				
			}else
			{
				return wrapSafari(msg);
			}
			
		}
		protected static function wrapChrome(msg:*):ByteArray
		{
			var back_str:ByteArray = new ByteArray();
			
			var raw:ByteArray = new ByteArray();
			raw.writeMultiByte(msg,charset);
			
			back_str.writeByte(0x81);
			
			var data_length:int = raw.length;
			
			if (data_length < 126)
			{
				back_str.writeByte(data_length);
				
			}else if (data_length < 0xFFFF){
				
				back_str.writeByte(126);
				back_str.writeByte(data_length >> 8);
				back_str.writeByte(data_length & 0xFF);
				
			}else
			{
				//todo 不知道怎么写
				back_str.writeByte(127);
				back_str.writeUnsignedInt(data_length >> 8);
				back_str.writeInt(data_length & 0xFF);
			}
			
			back_str.writeBytes(raw,0,raw.length);
			
			return back_str;
		}
		protected static function wrapSafari(msg:*):ByteArray
		{
			var wrapByte:ByteArray = new ByteArray();
			
			wrapByte.writeByte(0x00);
			
			if(msg is ByteArray)
			{
				wrapByte.writeBytes(msg,0,msg.length);
				
			}else
			{
				wrapByte.writeMultiByte(msg,charset);
			}
			
			wrapByte.writeByte(0xFF);
			
			return wrapByte;
		}
		/**
		 * 解开封装数据 
		 * @param msg
		 * @return 
		 * 
		 */		
		public function unwrapData(msg:ByteArray):ByteArray
		{
			if(secWebSocketVersion>7)
			{
				return unwrapChrome(msg);
				
			}else
			{
				return unwrapSafari(msg);
			}
			
		}
		protected static function unwrapSafari(msg:ByteArray):ByteArray
		{
			var msgbuff:ByteArray = new ByteArray();
			
			msgbuff.writeBytes(msg,1,msg.length-2);
			msgbuff.position = 0;
			
			return msgbuff;
			
		}
		protected static function unwrapChrome(msg:ByteArray):ByteArray
		{
			var wrapByte:ByteArray = new ByteArray();
			
			msg.position = 1;
			var code_length:int = msg.readByte() & 127;
			var masks:ByteArray  = new ByteArray();
			var data:ByteArray = new ByteArray();
			
			if (code_length == 126)
			{
				masks.writeBytes(msg,4,4);
				data.writeBytes(msg,8,msg.length - 8);
				
			}else if(code_length == 127)
			{
				masks.writeBytes(msg,10,4);
				data.writeBytes(msg,14,msg.length - 14);
				
			}else{
				
				masks.writeBytes(msg,2,4);
				data.writeBytes(msg,6,msg.length - 6);
			}
			
			var raw:ByteArray = new ByteArray();
			
			data.position = 0;
			
			for (var i:int = 0; i < data.length; i++) 
			{
				masks.position = i%4;
				
				raw.writeByte(data.readByte()^masks.readByte());
			}
			
			raw.position = 0;
			
			return raw;
		}
		public function unwrapDataToString(msg:ByteArray):String
		{
			var msgbuff:ByteArray = unwrapData(msg);
			
			return msgbuff.readMultiByte(msgbuff.length,charset);
		}
	}
}