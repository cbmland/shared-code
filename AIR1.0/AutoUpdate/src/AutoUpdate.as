package {
	
	import com.cbmland.utils.UpdateUtil;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.text.TextField;

	public class AutoUpdate extends Sprite{
		
		private var console:TextField;
		
		public function AutoUpdate()
		{
			initConsole()
			
			new UpdateUtil('http://www.cbmland.com/air/AutoUpdate/update.xml',eventHandle)
		}
		private function initConsole(){
			
			console = new TextField()
			
			console.width = this.stage.stageWidth;
			console.height = this.stage.stageHeight;
			console.border = false;
			console.multiline = true;
			console.wordWrap = true;
			this.addChild(console)
		
		}
		private function eventHandle(event:Event){
			
			console.appendText(event+'\n');

			if(event is StatusEvent){
				
				doUpdate(event)
			}
		}
		private function doUpdate(event:Event):void{
			
			if(event.available==true){
				
				event.preventDefault()
				au.downloadUpdate()
			}
		}
	}
}
