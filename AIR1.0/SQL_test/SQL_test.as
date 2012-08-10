package
{
	import com.cbmland.data.SQL;
	
	import flash.display.Sprite;
	import flash.events.ErrorEvent;   
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.text.TextField;
	public class SQL_test extends Sprite 
	{
		var sql:SQL= new SQL()
		var _textField:TextField=new TextField()
		public function SQL_test()
		{
			sql.addEventListener(SQL.RESULT,sql_RESULT)
			sql.addEventListener(SQL.ERROR,sql_ERROR)
			sql.open(File.applicationStorageDirectory.resolvePath("DBSample.db"))		
			
			//尝试创建数据库以及一个表
			var sqlText=
			    "CREATE TABLE IF NOT EXISTS employees (" + 
			    "    empId INTEGER PRIMARY KEY AUTOINCREMENT, " + 
			    "    firstName TEXT, " + 
			    "    lastName TEXT, " + 
			    "    salary NUMERIC CHECK (salary > 0)" + 
			    ")";
			    
			query(sqlText)
			
			//插入一个记录
			sqlText="INSERT INTO employees (firstName, lastName, salary) " + 
			    "VALUES ('Bob', 'Smith', 8000)";
			query(sqlText)
			
			//查询
			sqlText='SELECT * FROM employees '
			query(sqlText) 
			
			_textField.multiline=true
			_textField.width= stage.stageWidth
			_textField.height= stage.stageHeight
			this.addChild(_textField)
			
		}
		
		private function query(text:String){
			sql.text=text
			sql.execute()
		}
		private function view_RESULT(result):void
				{
					
					if(result.data!=null){
					    var numRows:int = result.data.length;
					    for (var i:int = 0; i < numRows; i++)
					    {
					        var output:String = "";
					        for (var columnName:String in result.data[i])
					        {
					            output += columnName + ": " + result.data[i][columnName] + "; ";
					        }
					        trace("row[" + i.toString() + "]\t", output);
					        _textField.appendText("row[" + i.toString() + "] "+output+'\n')
					    }
					   // if(!result.complete){sql.next()}
				    }else if(result.rowsAffected>0){
				    		trace(result.lastInsertRowID)
				    }
				} 

		private function sql_RESULT(event:Event){
			var result=(event.target.getResult())
			view_RESULT(result)
			
		}
		private function sql_ERROR(event:ErrorEvent){
			trace("Error message:", event['error'].message);
			trace("Details:", event['error'].details);
		}	
	}
}