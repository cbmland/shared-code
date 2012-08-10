package {
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;


	public class pureASProject extends Sprite
	{
		private var scence:Sprite= new Sprite()
		private var scence_loader:Loader= new Loader()
		private var _win:NativeWindow
		
		private var _content:MovieClip = new MovieClip()
		private var sprite:Sprite = new Sprite();

		public function pureASProject()
		{	
			sprite.graphics.beginFill(0xffffff,1)
			sprite.graphics.drawRect(0,0,100,100)
			
			_win=this.stage.nativeWindow
			this.addChild(this.scence)
			this.scence.addEventListener(MouseEvent.MOUSE_DOWN,windowMove)
			this.scence.addChild(this.scence_loader)
			this.scence_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoad)
			this.scence_loader.load(new URLRequest('swf/1111104101.swf'))
			
			this.contextMenu=buildNativeMenu()
			
		}
		private function onLoad(event:Event):void{
			trace(scence_loader.content)
			trace("content has loaded!")
			_content = scence_loader.content as MovieClip;
		}
		private function buildNativeMenu():NativeMenu{
			var menu:NativeMenu=new NativeMenu()
			
			var sub:NativeMenu=new NativeMenu()
			sub.addItem(new NativeMenuItem('&Play'))
			sub.addItem(new NativeMenuItem('&Stop'))
			menu.addSubmenu(sub,'&Control')
			menu.addItem(new NativeMenuItem('&Exit'))
			menu.addEventListener(Event.SELECT,menu_select)
			return menu;
		}
		private function menu_select(event:Event):void{
		if(event.target.label=='&Exit'){
			this._win.close()
		}
		else if(event.target.label=='&Play'){
			_content.play()
		}
		else if(event.target.label=='&Stop'){
			_content.stop()
		}
		}
		private function windowMove(event:Event):void{
			
		_win.startMove()
		}

	} 
}
