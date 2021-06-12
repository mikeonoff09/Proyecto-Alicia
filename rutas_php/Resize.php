<?php
if (!$_POST["id_product"]){
	echo "nop1";
	exit();
}
if (!$_POST["id_image"] ) {
	echo "nop2";
	exit();
}
if (!$_POST["equipo"] ) {
	echo "nop3";
	exit();
}
if (!$_POST["imgbase64"]) {
	echo "nop4";
	exit();
}
if (!$_POST["id_image"]) {
	echo "nop5";
	exit();
}
if (!$_POST["original_crop"]) {
	echo "nop6";
	exit();
}	

$id_product = $_POST["id_product"];
$data_original = base64_decode($_POST['imgbase64']);


file_put_contents($id_product.'_original.jpg', $data_original);
echo hash("md5",$data_original)."<br>";
echo hash_file("md5",$id_product.'_original.jpg');
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

exit();












if (1==2){
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
function resize_image($file, $w, $h, $crop=FALSE) {
    list($width, $height) = getimagesize($file);
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
    $src = imagecreatefromjpeg($file);
    $dst = imagecreatetruecolor($newwidth, $newheight);
    imagecopyresampled($dst, $src, 0, 0, 0, 0, $newwidth, $newheight, $width, $height);

    return $dst;
}
echo "aaa";
$img = resize_image("resultado.jpg", 617, 300);
imagejpeg($img, "resultado_aa.jpg", 100);
echo  '<img src="resultado_aa.jpg">';

exit();


if (1==2){
if (!$_POST["id_product"] || $_POST["id_image"] || $_POST["equipo"] || $_POST["imgbase64"]) {
	echo "nop4";
	exit();
}
$imgbase64 = $_POST['imgbase64'];
$base64 = $imgbase64;
$data = base64_decode($base64);
$imagen = imagecreatefromstring($data);

if (!$imagen){
	echo "Imagen no soportada";
	exit();
}
file_put_contents('resultado.jpg', $data);
exit();
}

$source_width = imagesx($imagen);
$source_height = imagesy($imagen);
$Tamano=800;

if ($source_height>$source_width){
	$ratio =  $source_height / $source_width;
	$new_width = round($Tamano / $ratio); // assign new width to new resized image
	$new_height = $Tamano ;
}else{
	$ratio =  $source_width / $source_height;
	$new_width = $Tamano; // assign new width to new resized image
	$new_height =  round($Tamano / $ratio);
}
echo "Ancho original: $source_width .. Alto original: $source_height .. Nuevo ancho: $new_width .. Nueva altura:  $new_height .. Ratio: $ratio";

$thumb = imagecreatetruecolor($new_width, $new_height);
imagecopyresized($thumb, $imagen, 0, 0, 0, 0, $new_width, $new_height, $source_width, $source_height);
imagejpeg($thumb, "resultado.jpg", 100);
imagedestroy($imagen);
echo "<br> fin4";
?>