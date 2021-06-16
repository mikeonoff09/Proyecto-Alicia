<?php
use \Psr\Http\Message\ResponseInterface as Response;
use \Psr\Http\Message\ServerRequestInterface as Request;

function resize_image($src, $w, $h, $crop=false) {
    $width = imagesx($src);
	$height= imagesy($src);
    $r = $width / $height;
    if ($crop) {
        if ($width > $height) {
            $width = ceil($width-($width*abs($r-$w/$h)));
        } else {
            $height = ceil($height-($height*abs($r-$w/$h)));
        }
        $newwidth = $w;
        $newheight = $h;
    } else {
        if ($w/$h > $r) {
            $newwidth = $h*$r;
            $newheight = $h;
        } else {
            $newheight = $w/$r;
            $newwidth = $w;
        }
    }
    $dst = imagecreatetruecolor($newwidth, $newheight);
    imagecopyresampled($dst, $src, 0, 0, 0, 0, $newwidth, $newheight, $width, $height);
    return $dst;
}
function resize_image2($imagen) {
	$source_width = imagesx($imagen);
	$source_height = imagesy($imagen);
	$Tamano=800;
	if ($source_height>$source_width){
		$ratio =  $source_height / $source_width;
		$new_width = round($Tamano / $ratio);
		$new_height = $Tamano ;
	}else{
		$ratio =  $source_width / $source_height;
		$new_width = $Tamano;
		$new_height =  round($Tamano / $ratio);
	}

	$thumb = imagecreatetruecolor($new_width, $new_height);
	imagecopyresized($thumb, $imagen, 0, 0, 0, 0, $new_width, $new_height, $source_width, $source_height);
	imagejpeg($thumb, "resultado.jpg", 100);
	imagedestroy($imagen);
	echo "Ancho original: $source_width .. Alto original: $source_height .. Nuevo ancho: $new_width .. Nueva altura:  $new_height .. Ratio: $ratio";
}

$app->post('/imagenes/add', function (Request $request, Response $response) {
    $id_product = $request->getParam("id_product");
	if(!is_numeric($id_product)){   //debe ser un número
		return sendResponse(404, null, '{"error":"No has enviado una idproducto correcto"}', $response);
	}
	try {
		$dbInstance = new Db();
		$db = $dbInstance->connectDB();
		$sql = 'select id_product from a_tabla_product where id_product = :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();
		if ($statement->rowCount()==0){
			return sendResponse(404,'{"error":"No existe el producto con id_product= '.$id_product .'"}',null, $response);			
		}

		$position = $request->getParam("position");
		if(!is_numeric($position)){   //debe ser un número
			return sendResponse(404, null, '{"error":"No has enviado una position correcta"}', $response);
		}
		$cover = $request->getParam("cover");
		if(!is_numeric($cover)){   //debe ser un número
			return sendResponse(404, null, '{"error":"No has enviado una cover correcta"}', $response);
		}
		$legend = $request->getParam("legend");

		$descartada = $request->getParam("descartada");
		if(!is_numeric($descartada)){   //debe ser un número
			return sendResponse(404, null, '{"error":"No has enviado una descartada correcta"}', $response);
		}
		$padding = $request->getParam("padding");
		if(!is_numeric($padding)){   //debe ser un número
			return sendResponse(404, null, '{"error":"No has enviado una padding correcta"}', $response);
		}

		$data_original = base64_decode($request->getParam("imgbase64"),true);
		if(!$data_original){
			return sendResponse(404, null, '{"error":"No has enviado una imgbase64 correcta"}', $response);
		}
		$imagen = imagecreatefromstring($data_original);
		if(!$imagen){
			return sendResponse(404, null, '{"error":"No has enviado una imagen original correcta"}', $response);
		}
		$width =imagesx($imagen);
		$height=imagesy($imagen);
		$md5= hash("md5",$data_original);


		$crop64 = base64_decode($request->getParam("crop64"),true);
		if(!$crop64){
			return sendResponse(404, null, '{"error":"No has enviado un base64_decode recorte correcto"}', $response);
		}
		$imagen_crop = imagecreatefromstring($crop64);
		if(!$imagen_crop){
			return sendResponse(404, null, '{"error":"No has enviado una imagen original correcta"}', $response);
		}
		$width_crop =imagesx($imagen_crop);
		$height_crop=imagesy($imagen_crop);

		$sql = "insert into a_tabla_image (id_product,position,cover,legend,padding,resolucionorigen,descartada,fechaanadida,md5,resolucionrecorte) values (:id_product,:position,:cover,:legend, :padding,'". $width . "x". $height."', :descartada,'".date('Y-m-d H:i:s')."','".$md5."','". $width_crop . "x". $height_crop."')";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->bindParam(":cover", $cover, PDO::PARAM_INT);
		$statement->bindParam(":legend", $legend, PDO::PARAM_STR);
		$statement->bindParam(":padding", $padding, PDO::PARAM_INT);
		$statement->bindParam(":descartada", $descartada, PDO::PARAM_INT);
		$statement->execute();
		$id_image = $db->lastInsertId();

		file_put_contents($id_product.'_'.$id_image."_".$position.'_original.jpg', $data_original);
		$mini= resize_image($crop64,98,128,false);
		imagejpeg($mini,$id_product.'_'.$id_image."_".$position.'-small_default.jpg',12);
		$mini= resize_image($crop64,125,125,false);
		imagejpeg($mini,$id_product.'_'.$id_image."_".$position.'-cart_default.jpg.jpg',12);
		$mini= resize_image($crop64,128,128,false);
		imagejpeg($mini,$id_product.'_'.$id_image."_".$position.'-small_default.jpg',12);
		$mini= resize_image($crop64,750,750,false);
		imagejpeg($mini,$id_product.'_'.$id_image."_".$position.'-home_default.jpg',12);
		$mini= resize_image($crop64,1000,1000,false);
		imagejpeg($mini,$id_product.'_'.$id_image."_".$position.'-large_default.jpg',12);

		imagedestroy($mini);
		imagedestroy($crop64);
		

		/*$sql = 'select id_image from a_tabla_image where id_product = :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();
		$position =$statement->rowCount();*/

		return sendResponse(201, '{"id_image": '.$id_image.',"id_product": "'.$id_product.'", "position": '.$position.'}',"Alta nueva imagen", $response);
	} catch (PDOException $e) {
		return sendResponse(500, "al dar de alta imagen nueva", $e->getMessage(), $response);
	}
});

$app->post('/imagenes/update', function (Request $request, Response $response) {
    $id_image = $request->getParam("id_image");
	if(!is_numeric($id_image)){   //debe ser un número
		return sendResponse(404, null, '{"error":"No has enviado una idproducto correcto"}', $response);
	}
	try {
		$dbInstance = new Db();
		$db = $dbInstance->connectDB();
		$sql = 'select id_product,position,cover from a_tabla_product where id_image = :id_image';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_image", $id_product, PDO::PARAM_INT);
		$statement->execute();
		if ($statement->rowCount()==0){
			return sendResponse(404,'{"error":"No existe el producto con id_product= '.$id_product .'"}',null, $response);			
		}
		$position = $request->getParam("position");
		if(!is_numeric($position)){   //debe ser un número
			return sendResponse(404, null, '{"error":"No has enviado una position correcta"}', $response);
		}
		$cover = $request->getParam("cover");
		if(!is_numeric($cover)){   //debe ser un número
			return sendResponse(404, null, '{"error":"No has enviado una cover correcta"}', $response);
		}
		$legend = $request->getParam("legend");

		$descartada = $request->getParam("descartada");
		if(!is_numeric($descartada)){   //debe ser un número
			return sendResponse(404, null, '{"error":"No has enviado una descartada correcta"}', $response);
		}
		$padding = $request->getParam("padding");
		if(!is_numeric($padding)){   //debe ser un número
			return sendResponse(404, null, '{"error":"No has enviado una padding correcta"}', $response);
		}

		$data_crop = base64_decode($request->getParam("imgbase64"),true);
		if(!$data_crop){
			return sendResponse(404, null, '{"error":"No has enviado una imgbase64 correcta"}', $response);
		}
		$imagen = imagecreatefromstring($data_crop);
		if(!$imagen){
			return sendResponse(404, null, '{"error":"No has enviado una imagen original correcta"}', $response);
		}
		$width =imagesx($imagen);
		$height=imagesy($imagen);
		imagedestroy($imagen);

		$crop64 = base64_decode($request->getParam("crop64"),true);
		if(!$crop64){
			return sendResponse(404, null, '{"error":"No has enviado un base64_decode recorte correcto"}', $response);
		}
		$imagen_crop = imagecreatefromstring($crop64);
		if(!$imagen_crop){
			return sendResponse(404, null, '{"error":"No has enviado una imagen original correcta"}', $response);
		}
		$width_crop =imagesx($imagen_crop);
		$height_crop=imagesy($imagen_crop);

		$sql = "update a_tabla_image set position = :position,cover=:cover,legend=:legend,padding=:padding,resolucionrecorte ='". $width . "x". $height."',descartada=:descartada, fechamodificacion='".date('Y-m-d H:i:s')."' where id_image = :id_image";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_image", $id_image, PDO::PARAM_INT);
		$statement->bindParam(":cover", $cover, PDO::PARAM_INT);
		$statement->bindParam(":legend", $legend, PDO::PARAM_STR);
		$statement->bindParam(":padding", $padding, PDO::PARAM_INT);
		$statement->bindParam(":descartada", $descartada, PDO::PARAM_INT);
		$statement->execute();
		file_put_contents($id_product.'_'.$id_image."_".$position.'_original.jpg', $data_original);
		$mini= resize_image($imagen_crop,800,800,false);
		imagejpeg($mini,$id_product.'_'.$id_image."_".$position.'-cart_original.jpg',12);
		imagedestroy($mini);
		imagedestroy($imagen_crop);

		/*$sql = 'select id_image from a_tabla_image where id_product = :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();
		$position =$statement->rowCount();*/

		return sendResponse(201, '{"id_image": '.$id_image.',"id_product": "'.$id_product.'", "position": '.$position.'}',"Alta nueva imagen", $response);
	} catch (PDOException $e) {
		return sendResponse(500, "al dar de alta imagen nueva", $e->getMessage(), $response);
	}
});


function resize_image3($data, $w, $h) {
	$id_product = $_POST["id_product"];
	$data_original = base64_decode($_POST['imgbase64']);


	file_put_contents($id_product.'_original.jpg', $data_original);
	file_put_contents($id_product.'_recorte_flutter.jpg', base64_decode($_POST['original_crop']));

	$imagen = imagecreatefromstring($data_original);
	list($width, $height) = getimagesizefromstring ($data_original);

	$lienzo = imagecreatetruecolor($width, $height);
	$rojo = ImageColorAllocate($imagen, 255, 0, 0);


	ImageRectangle($imagen, $_POST["izquierda"],$_POST["arriba"],$_POST["derecha"],$_POST["abajo"],$rojo);
	imagejpeg($imagen,$id_product . '_original_con_recorte' . " Original_". $_POST["originalSize_width"] . "x" . $_POST["originalSize_height"] . " derecha_" . $_POST["derecha"] . " izquierda_" . $_POST["izquierda"] . " arriba_" . $_POST["arriba"] . " abajo_" . $_POST["abajo"] . " escala_" . $_POST["scala"].'.jpg',10);

	$thumb = new Imagick($id_product.'_original.jpg');
	$thumb->cropImage(intval(($_POST["derecha"]-$_POST["izquierda"])), intval(($_POST["abajo"]-$_POST["arriba"])) ,intval($_POST["izquierda"]),intval($_POST["arriba"]));
	$thumb->writeImage("ancho_".intval(($_POST["derecha"]-$_POST["izquierda"])). " alto_".intval(($_POST["abajo"]-$_POST["arriba"])). " X_".intval($_POST["izquierda"])." Y_".intval($_POST["arriba"]). " Producto_". $id_product.'_recortada_php.jpg');

	echo  date('h:i:s, j/m/Y');

	imagedestroy($lienzo);
	imagedestroy($imagen);
}





function reducir_varios_tamanos(){
	//esto reduce con mala calidad, es raro porque debería ser aceptable o muy bueno
	for ($i=1;$i<=4;$i++){
		$im = new imagick("resultado.jpg");
		$imageprops = $im->getImageGeometry();
		$width = $imageprops['width'];
		$height = $imageprops['height'];
		$tamano = 300;
		if($width > $height){
			$newHeight = $tamano;
			$newWidth = ($tamano / $height) * $width;
		}else{
			$newWidth = $tamano;
			$newHeight = ($tamano / $width) * $height;
		}
		$im->resizeImage($newWidth,$newHeight, imagick::FILTER_GAUSSIAN , $i/10, true);   //FILTER_POINT
		//$im->cropImage ($tamano,$tamano,0,0);
		$im->writeImage( "resultado_cambio_".$i.".jpg" );
		echo '<img src="resultado_cambio_'.$i.'.jpg">';
	}
}

?>