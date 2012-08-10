<?php

define('ABSPATH', dirname(__FILE__).'/');

$cache = true;//Gzipѹ������
$cachedir = 'wp-cache/';//���gz�ļ���Ŀ¼��ȷ����д

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

$cache_filename=ABSPATH.$cachedir.$namespace.$symbol.basename($filename).'.gz';//����gz�ļ�·��

$type="Content-type: text/html"; //Ĭ�ϵ�������Ϣ

$ext = array_pop(explode('.', $filename));//���ݺ�׺�ж��ļ�������Ϣ
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
	if(file_exists($cache_filename)){//�������gz�ļ�
		
		
		$mtime = filemtime($cache_filename);
		$gmt_mtime = gmdate('D, d M Y H:i:s', $mtime) . ' GMT';
		
		if( (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) && 
      		array_shift(explode(';', $_SERVER['HTTP_IF_MODIFIED_SINCE'])) ==  $gmt_mtime)
			){
			
			// �����cache�е��ļ��޸������Ƿ�һ�£�������304
			header ("HTTP/1.1 304 Not Modified");
			header("Expires: ");
			header("Cache-Control: ");
			header("Pragma: ");
			header($type);
			header("Tips: Cache Not Modified (Gzip)");
			header ('Content-Length: 0');
			
			
		}else{
		
			//��ȡgz�ļ����
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
		
		
	}else if(file_exists($filename)){ //û�ж�Ӧ��gz�ļ�
		
		$mtime = mktime();
		$gmt_mtime = gmdate('D, d M Y H:i:s', $mtime) . ' GMT';
		
		$content = file_get_contents($filename);//��ȡ�ļ�
		$content = gzencode($content, 9, $gzip ? FORCE_GZIP : FORCE_DEFLATE);//ѹ���ļ�����
		
		header("Last-Modified:" . $gmt_mtime);
		header("Expires: ");
		header("Cache-Control: ");
		header("Pragma: ");
		header($type);
		header("Tips: Build Gzip File (Gzip)");
		header ("Content-Encoding: " . $encoding);
        header ('Content-Length: ' . strlen($content));
		echo $content;
		
		if ($fp = fopen($cache_filename, 'w')) {//д��gz�ļ������´�ʹ��
                fwrite($fp, $content);
                fclose($fp);
            }
		
	}else{
		header("HTTP/1.0 404 Not Found");
	}
}else{ //����ʹ��Gzipģʽ�µ������ԭ�����ͬ��
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
