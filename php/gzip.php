<?php

define('ABSPATH', dirname(__FILE__).'/');

$cache = true;//Gzip压缩开关
$cachedir = 'wp-cache/';//存放gz文件的目录，确保可写

$gzip = strstr($_SERVER['HTTP_ACCEPT_ENCODING'], 'gzip');
$deflate = strstr($_SERVER['HTTP_ACCEPT_ENCODING'], 'deflate');
$encoding = $gzip ? 'gzip' : ($deflate ? 'deflate' : 'none');

if(!isset($_SERVER['QUERY_STRING'])) exit();

$key=array_shift(explode('?', $_SERVER['QUERY_STRING']));
$key=str_replace('../','',$key);

$filename=ABSPATH.$key;

$symbol='^';

$rel_path=str_replace(ABSPATH,'',dirname($filename));
$namespace=str_replace('/',$symbol,$rel_path);

$cache_filename=ABSPATH.$cachedir.$namespace.$symbol.basename($filename).'.gz';//生成gz文件路径

$type="Content-type: text/html"; //默认的类型信息

$ext = array_pop(explode('.', $filename));//根据后缀判断文件类型信息
	switch ($ext){
		case 'css':
		 $type="Content-type: text/css";
		 break;
		case 'js':
		 $type="Content-type: text/javascript";
		 break;
		default:
		 exit();
	}

if($cache){
	if(file_exists($cache_filename)){//假如存在gz文件
		
		
		$mtime = filemtime($cache_filename);
		$gmt_mtime = gmdate('D, d M Y H:i:s', $mtime) . ' GMT';
		
		if( (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) && 
      		array_shift(explode(';', $_SERVER['HTTP_IF_MODIFIED_SINCE'])) ==  $gmt_mtime)
			){
			
			// 浏览器cache中的文件修改日期是否一致，将返回304
			header ("HTTP/1.1 304 Not Modified");
			header("Expires: ");
			header("Cache-Control: ");
			header("Pragma: ");
			header($type);
			header("Tips: Cache Not Modified (Gzip)");
			header ('Content-Length: 0');
			
			
		}else{
		
			//读取gz文件输出
			$content = file_get_contents($cache_filename);
			header("Last-Modified:" . $gmt_mtime);
			header("Expires: ");
			header("Cache-Control: ");
			header("Pragma: ");
			header($type);
			header("Tips: Normal Respond (Gzip)");
			header("Content-Encoding: gzip");
			echo $content;
		}
		
		
	}else if(file_exists($filename)){ //没有对应的gz文件
		
		$mtime = mktime();
		$gmt_mtime = gmdate('D, d M Y H:i:s', $mtime) . ' GMT';
		
		$content = file_get_contents($filename);//读取文件
		$content = gzencode($content, 9, $gzip ? FORCE_GZIP : FORCE_DEFLATE);//压缩文件内容
		
		header("Last-Modified:" . $gmt_mtime);
		header("Expires: ");
		header("Cache-Control: ");
		header("Pragma: ");
		header($type);
		header("Tips: Build Gzip File (Gzip)");
		header ("Content-Encoding: " . $encoding);
        header ('Content-Length: ' . strlen($content));
		echo $content;
		
		if ($fp = fopen($cache_filename, 'w')) {//写入gz文件，供下次使用
                fwrite($fp, $content);
                fclose($fp);
            }
		
	}else{
		header("HTTP/1.0 404 Not Found");
	}
}else{ //处理不使用Gzip模式下的输出。原理基本同上
	if(file_exists($filename)){
		$mtime = filemtime($filename);
		$gmt_mtime = gmdate('D, d M Y H:i:s', $mtime) . ' GMT';
		
		if( (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) && 
		array_shift(explode(';', $_SERVER['HTTP_IF_MODIFIED_SINCE'])) ==  $gmt_mtime)
		){
		
		header ("HTTP/1.1 304 Not Modified");
		header("Expires: ");
		header("Cache-Control: ");
		header("Pragma: ");
		header($type);
		header("Tips: Cache Not Modified");
		header ('Content-Length: 0');

	}else{
	
		header("Last-Modified:" . $gmt_mtime);
		header("Expires: ");
		header("Cache-Control: ");
		header("Pragma: ");
		header($type);
		header("Tips: Normal Respond");
		$content = file_get_contents($filename);
		echo $content;
		
		}
	}else{
		header("HTTP/1.0 404 Not Found");
	}
}

?>
