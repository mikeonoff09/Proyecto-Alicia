<?php
require 'ficha_producto.php';

require 'imagenes.php';

require 'listado_productos.php';

require 'ps_atributos.php';

require 'ps_caracteristicas.php';

function registroLOG($base_datos,$quien,$tipo_objeto, $id_objeto, $SQL,$numero_registros,$mensaje){
	$SQL= "nsert into a_tabla_log(cuando,id_usuario,tipo_objeto,sentencia_sql,registros_afectados,id,mensaje) values('".
			date('Y-m-d H:i:s') ."', $quien,'$tipo_objeto',':sentencia_sql',$numero_registros,'$mensaje')";

	$statement = $base_datos->prepare($sql);
	$statement->bindParam(":sentencia_sql", $sentencia_sql);
	$statement->execute();	
}

?>