package com.cbmland.utils
{
	import air.update.ApplicationUpdater;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	
	public class UpdateUtil
	{
		private var au:ApplicationUpdater;
		/**
		 * 
		 * @param updateURL 版本描述文件URL
		 * @param eventHandle 事件挂钩
		 * 
		 */		
		public function UpdateUtil(updateURL:String,eventHandle:Function = null){
				
				au = new ApplicationUpdater();
				
				//设置版本描述文件URL
				this.au.updateURL = updateURL;
				
				//如果有事件挂钩便进行事件监听
				if(eventHandle){
					this.au.addEventListener(ErrorEvent.ERROR,eventHandle)
					this.au.addEventListener(UpdateEvent.CHECK_FOR_UPDATE,eventHandle)
					this.au.addEventListener(UpdateEvent.INITIALIZED,eventHandle)
					this.au.addEventListener(UpdateEvent.DOWNLOAD_START,eventHandle)
					this.au.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE,eventHandle)
					this.au.addEventListener(UpdateEvent.BEFORE_INSTALL,eventHandle)
					this.au.addEventListener(StatusUpdateEvent.UPDATE_STATUS,eventHandle)
					this.au.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR,eventHandle)
				}
				//初始化
				this.au.initialize()
				//开始检查
				this.au.checkNow()
	
		}

	}
}