package
{
import flash.desktop.*;
import flash.display.Sprite;
import flash.events.*;
import flash.filesystem.File;
import flash.text.TextField;

public class DragOut_test extends Sprite {

	private var dragTarget:Sprite = new Sprite();
	private var backgroundColor:Number = 0x0097CA;
	private var consoleText:TextField= new TextField()
	public function DragOut_test(){
		 
		
		
		this.addChild(consoleText)
		this.addChild(dragTarget)
		dragTarget.focusRect = false;
		stage.stageFocusRect = false;
		drawBackground()//注意stage上必须要有可见元素，组成检测区域。
		configConsoleText()//创建输出文本框
		dragTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,onDragIn);//通常做拖入文件的类型检查
        dragTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDrop);//拖拽完成事件
        dragTarget.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT,onDragExit);//拖拽取消
	}
	 private function drawBackground():void{
	 	
    		dragTarget.graphics.clear();
			dragTarget.graphics.beginFill(backgroundColor,0);
			dragTarget.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			dragTarget.graphics.endFill();
    		dragTarget.hitArea=null
	 }
	 private function configConsoleText(){
	 	consoleText.width=stage.stageWidth
    	consoleText.height=stage.stageHeight
    	consoleText.selectable=false
    	consoleText.multiline=true
    	consoleText.appendText('请拖拽一个或者多个文件到此！\n')
	 }
        private function onDragIn(event:NativeDragEvent):void{

            var transferable:Clipboard = event.clipboard;
            if(transferable.hasFormat(ClipboardFormats.BITMAP_FORMAT) ||
               transferable.hasFormat(ClipboardFormats.FILE_LIST_FORMAT) ||
               transferable.hasFormat(ClipboardFormats.TEXT_FORMAT) ||
               transferable.hasFormat(ClipboardFormats.URL_FORMAT)){
               	
					consoleText.appendText("接受的格式。\n")
					NativeDragManager.acceptDragDrop(dragTarget);
               } else {
               		consoleText.appendText("不接受的格式。\n")

               }     
        }

        private function onDrop(event:NativeDragEvent):void{
        	
			var dropfiles:Array= event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				for each (var file:File in dropfiles)
				{
					consoleText.appendText("拖入文件："+file.nativePath+'\n')
					
				}
        }  
        private function onDragExit(event:NativeDragEvent):void{
            consoleText.appendText("拖拽退出。\n")
        }


}

}