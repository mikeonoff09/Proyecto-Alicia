<?php
use \Psr\Http\Message\ResponseInterface as Response;
use \Psr\Http\Message\ServerRequestInterface as Request;
		//$sql = 'SELECT * FROM Organization WHERE City = :City AND State= :State';
		//$stmt = $db->prepare($sql);
		//$params = array(':City' => 'string1', ':State' => 'string2');
		//foreach ($params as $key => &$val) {
		//	$stmt->bindParam($key, $val);
		//}

function borrar_attribute($id_attribute,$position,$db){
	try {
		//al eliminar un attribute hay que corregir la posicion del resto de attributes
		$sql = 'update a_tabla_attribute set position = position -1 where position > :position';
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->execute();

		$sql = "select id_attribute_value,position from a_tabla_attribute_value where id_attribute =:id_attribute";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute", $id_attribute, PDO::PARAM_INT);
		$statement->execute();
		while ($fila  = $statement->fetch()) {
			borrar_attribute_value($fila['id_attribute_value'],$fila['position'],$db);
		}

		//hay que eliminar cualquier información colocada en un producto, en la tabla attribute_value y finalmente en attribute
		$sql = 'delete a_tabla_attribute_product.* from a_tabla_attribute_product where id_attribute = :id_attribute';  //borro los valores ya asignados a productos
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute", $id_attribute, PDO::PARAM_INT);
		$statement->execute();

		$sql = 'delete a_tabla_attribute.* from a_tabla_attribute where id_attribute = :id_attribute';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute", $id_attribute, PDO::PARAM_INT);
		$statement->execute();
		return true;
    } catch (PDOException $e) {
		return false;
        //return sendResponse(500, "", $e->getMessage(), $response);
    }
}

function borrar_attribute_value($id_attribute_value,$position,$db){
	try {
		//al eliminar un attribute hay que corregir la posicion del resto de attributes
		$sql = 'update a_tabla_attribute_value set position = position -1 where position > :position';
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->execute();

		//marco las fichas de los productos donde se eliminan las attribute_value para rehacer el HTML
		$sql = 'UPDATE a_tabla_product INNER JOIN a_tabla_attribute_product ON a_tabla_product.id_product = a_tabla_attribute_product.id_product SET a_tabla_product.rehacerHTML = 1
		WHERE a_tabla_attribute_product.id_attribute_value=:id_attribute_value';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute_value", $id_attribute_value, PDO::PARAM_INT);
		$statement->execute();

		//hay que eliminar cualquier información colocada en un producto, en la tabla attribute_value y finalmente en attribute
		$sql = 'delete a_tabla_attribute_product.* from a_tabla_attribute_product where id_attribute_value = :id_attribute_value';  //borro los valores ya asignados a productos
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute_value", $id_attribute_value, PDO::PARAM_INT);
		$statement->execute();

		$sql = 'delete a_tabla_attribute_value.* FROM a_tabla_attribute_value WHERE id_attribute_value = :id_attribute_value';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute_value", $id_attribute_value, PDO::PARAM_INT);
		$statement->execute();

		return true;
    } catch (PDOException $e) {
		return false;
        //return sendResponse(500, "", $e->getMessage(), $response);
    }
}

$app->post('/ps_attribute_todas/get', function (Request $request, Response $response) {
	try {
		$dbInstance = new Db();
        $db = $dbInstance->connectDB();

		$sql = 'SELECT id_attribute_group,position,name,public_name,is_color_group FROM a_tabla_attribute_group order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		if ($statement->rowCount() == 0) {
			$ps_attribute_group =[];
		}else{
			$ps_attribute_group = $statement->fetchAll(PDO::FETCH_ASSOC);
		}

		$sql = 'SELECT id_attribute,id_attribute_group,position,name,color FROM a_tabla_attribute order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		if ($statement->rowCount() == 0) {
			$ps_attribute =[];
		}else{
			$ps_attribute = $statement->fetchAll(PDO::FETCH_ASSOC);
		}

		$sql = 'SELECT id_attribute_sub,id_attribute,position,name,color FROM a_tabla_attribute_sub order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		if ($statement->rowCount() == 0) {
			$ps_attribute_sub =[];
		}else{
			$ps_attribute_sub = $statement->fetchAll(PDO::FETCH_ASSOC);
		}

		return sendResponse(200, ["ps_attribute_group"=>$ps_attribute_group,"ps_attribute"=>$ps_attribute,"ps_attribute_sub"=>$ps_attribute_sub], "lista_attribute", $response);
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});

$app->post('/ps_attribute/add', function (Request $request, Response $response) {
    if (!is_numeric($id_attribute_group)){
		return sendResponse(404, null, '{"error":"'. $id_attribute_group .' no es numero"}', $response);
	}
	$color =$request->getParam("color");
	if (!ctype_xdigit($color) && $color!=""){
		return sendResponse(404, null, '{"error":"color no es numero hexadecimal"}', $response);
	}

	$sql = 'SELECT id_attribute_group,is_color_group FROM a_tabla_attribute_group where id_attribute_group = :id_attribute_group';
	$dbInstance = new Db();
	$db = $dbInstance->connectDB();
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_attribute_group", $id_attribute_group, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, '{"error":"No existe el attribute_group en la tabla a_tabla_attribute_group"}', $response);
	}

    try {
		$color ="";  //asigno un valor predeterminado
		$data = $statement->fetch();
		if($data['is_color_group']==1){
			$color =$request->getParam("color");
			if (!ctype_xdigit($color) && $color!=""){
				return sendResponse(404, null, '{"error":"color no es numero hexadecimal"}', $response);
			}else{
				$textura = $request->getParam("textura");
				//file_put_contents($id_product.'_recorte_flutter.jpg', base64_decode($textura));
				$imagen_attribute = imagecreatefromstring($textura);
				echo hash("md5",$textura)."<br>";
			}
		}
		$sql = 'SELECT COUNT(*) as contador FROM a_tabla_attribute where id_attribute_group= :id_attribute_group'; //al añadir siempre es el último en "position"
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute_group", $id_attribute_group, PDO::PARAM_INT);
		$statement->execute();
		$data = $statement->fetch();
		$position = $data['contador'];

		$sql = "insert into a_tabla_attribute (id_attribute_group,position,name,color) values (:id_attribute_group,:position,:name,:color)";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute_group", $id_attribute_group, PDO::PARAM_INT);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":name", $name,PDO::PARAM_STR);
		if ($color==""){
			$statement->bindParam(":color", "",PDO::PARAM_STR);
		}else{
			$statement->bindParam(":color", "#". $color,PDO::PARAM_STR);
		}
		$statement->execute();

		if ($statement->rowCount() > 0) {
			$id_nuevo = $db->lastInsertId();
			return sendResponse(201, null, '{"id_attribute": $id_nuevo, "position": $position}', $response);
		}else{
			return sendResponse(404, null, '{"error":"Error añadiendo attribute"}', $response);
		}
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_attribute/update', function (Request $request, Response $response) {
    $id_attribute = $request->getParam("id_attribute");
    $position = $request->getParam("position");
    $name = trim($request->getParam("name"));
	$color = trim($request->getParam("color"));
	$textura = trim($request->getParam("textura"));
	if(!is_numeric($position)){   //debe ser un número
		return sendResponse(404, null, '{"error":"Posicion no es numero"}', $response);
	}
	if(!is_numeric($id_attribute)){   //debe ser un número
		return sendResponse(404, null, '{"error":"id_attribute no es numero"}', $response);
	}
	if(strlen($name)< 1){   //minimo debe
		return sendResponse(404, null, '{"error":"No has enviado el nombre"}', $response);
	}
	if (!ctype_xdigit($color) && $color!=""){
		return sendResponse(404, null, '{"error":"color no es numero hexadecimal"}', $response);
	}

	$sql = 'SELECT position,id_attribute_group FROM a_tabla_attribute where id_attribute = :id_attribute';
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_attribute", $id_attribute, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, '{"error":"No existe el attribute"}', $response);
	}
	$data = $statement->fetch();
	$positionantigua = $data['position'];
	$id_attribute_group = $data['id_attribute_group'];

	//si cambia de posicion debe cambiar el resto de registros para que los numeros sean siempre correlativos
	// 0,1,2,3,4,5, etc
	if ($positionantigua != $position){
		if ($positionantigua > $position){
			$sql = "update a_tabla_attribute set position=position +1 where id_attribute_group = :id_attribute_group and position >= :position and position < :positionantigua";
		}else{
			$sql = "update a_tabla_attribute set position=position -1 where id_attribute_group = :id_attribute_group and position >= :positionantigua and position <= :position";
		}
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":positionantigua", $positionantigua, PDO::PARAM_INT);
		$statement->execute();
	}

    try {
		$sql = "UPDATE a_tabla_attribute SET position=:position, name=:name, color=:color WHERE id_attribute = :id_attribute";
        $statement = $db->prepare($sql);
        $statement->bindParam(":id_attribute", $id_attribute, PDO::PARAM_INT);
        $statement->bindParam(":position", $position, PDO::PARAM_INT);
        $statement->bindParam(":name", $name,PDO::PARAM_STR);
		if ($color==""){
			$statement->bindParam(":color", "",PDO::PARAM_STR);
		}else{
			$statement->bindParam(":color", "#". $color,PDO::PARAM_STR);
		}
        $statement->execute();

		if ($statement->rowCount() > 0) {
            return sendResponse(200, null, '{"id_attribute": $id_attribute,"actualizar":"ok"}', $response);
        } else {
            return sendResponse(404, null, '{"error":"No se pudo actualizar"}', $response);
        }
        $db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_attribute/delete', function (Request $request, Response $response) {
    $id_attribute = $request->getParam('id_attribute');
	if(!is_numeric($id_attribute)){   //debe ser un número
		return sendResponse(404, null, '{"error":"id_attribute no es numero"}', $response);
	}
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$sql = 'SELECT position FROM a_tabla_attribute where id_attribute = :id_attribute';
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_attribute", $id_attribute, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
	return sendResponse(404, null, '{"error":"No existe el attribute}', $response);
	}
	$data = $statement->fetch();

	if(borrar_attribute($id_attribute,$data["position"],$db)){
		$db = null;
		return sendResponse(200, null,  '{"id_attribute": $id_attribute,  "borrar":"ok"}', $response);
    }else{
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});




$app->post('/ps_attribute_value/add', function (Request $request, Response $response) {
    $name = trim($request->getParam("name"));

	if(strlen($name)< 1){   //minimo debe tener 1 letra
		return sendResponse(404, null, '{"error":"No has enviado el nombre"}', $response);
	}
	$id_attribute =$request->getParam("id_attribute");
	if (!is_numeric($id_attribute)){
		return sendResponse(404, null, '{"error":"id_attribute no es numero"}', $response);
	}

	$dbInstance = new Db();
	$db = $dbInstance->connectDB();

	$sql = 'SELECT id_attribute FROM a_tabla_attribute where id_attribute = :id_attribute';
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_attribute", $id_attribute, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, '{"error":"No existe el id_attribute en la tabla a_tabla_attribute"}', $response);
	}

    try {

		$sql = 'SELECT COUNT(*) as contador FROM a_tabla_attribute_value'; //al añadir siempre es el último en "position"
		$statement = $db->prepare($sql);
		$statement->execute();
		$data = $statement->fetch();
		$position = $data['contador'];

		$sql = "insert into a_tabla_attribute_value (position,name,id_attribute) values (:position, :name, :id_attribute)";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute", $id_attribute, PDO::PARAM_INT);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":name", $name,PDO::PARAM_STR);
		$statement->execute();

		if ($statement->rowCount() > 0) {
			$id_nuevo = $db->lastInsertId();
			return sendResponse(201, null, '{"id_attribute_value": $id_nuevo, "position": $position}', $response);
		}else{
			return sendResponse(404, null, '{"error":"Error añadiendo attribute_value"}', $response);
		}
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_attribute_value/update', function (Request $request, Response $response) {
    $id_attribute_value = $request->getParam("id_attribute_value");
    $position = $request->getParam("position");
    $name = trim($request->getParam("name"));
	if(!is_numeric($position)){   //debe ser un número
		return sendResponse(404, null, '{"error":"Posicion no es numero"}', $response);
	}
	if(!is_numeric($id_attribute_value)){   //debe ser un número
		return sendResponse(404, null, '{"error":"id_attribute_value no es numero"}', $response);
	}
	if(strlen($name)< 1){   //minimo debe
		return sendResponse(404, null, '{"error":"No has enviado el name"}', $response);
	}

	$sql = 'SELECT position,id_attribute FROM a_tabla_attribute_value where id_attribute_value = :id_attribute_value';
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_attribute_value", $id_attribute_value, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, '{"error":"No existe el attribute"}', $response);
	}
	$data = $statement->fetch();
	$positionantigua = $data['position'];
	$id_attribute = $data['id_attribute'];

	//si cambia de posicion debe cambiar el resto de registros para que los numeros sean siempre correlativos
	// 0,1,2,3,4,5, etc
	if ($positionantigua != $position){
		if ($positionantigua > $position){
			$sql = "update a_tabla_attribute_value set position=position +1 where id_attribute = :id_attribute and position >= :position and position < :positionantigua";
		}else{
			$sql = "update a_tabla_attribute_value set position=position -1 where id_attribute = :id_attribute and position >= :positionantigua and position <= :position";
		}
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute", $id_attribute, PDO::PARAM_INT);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":positionantigua", $positionantigua, PDO::PARAM_INT);
		$statement->execute();
	}

    try {
		$sql = "UPDATE a_tabla_attribute_value SET position=:position, name=:name WHERE id_attribute_value = :id_attribute_value";
        $statement = $db->prepare($sql);
        $statement->bindParam(":id_attribute_value", $id_attribute, PDO::PARAM_INT);
        $statement->bindParam(":position", $position, PDO::PARAM_INT);
        $statement->bindParam(":name", $name,PDO::PARAM_STR);
        $statement->execute();

		if ($statement->rowCount() > 0) {
            return sendResponse(200, null, '{"id_attribute_value": $id_attribute_value, "actualizar": "ok"}', $response);
        } else {
            return sendResponse(404, null, '{"error":"No se pudo actualizar"}', $response);
        }
        $db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_attribute_value/delete', function (Request $request, Response $response) {
    $id_attribute_value = $request->getParam('id_attribute_value');
	if(!is_numeric($id_attribute_value)){   //debe ser un número
		return sendResponse(404, null, '{"error":"id_attribute no es numero"}', $response);
	}
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$sql = 'SELECT position FROM a_tabla_attribute_value where id_attribute_value = :id_attribute_value';
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_attribute_value", $id_attribute_value, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, '{"error":"No existe el attribute"}', $response);
	}
	$data = $statement->fetch();
	$position = $data['position'];

	if (borrar_attribute_value($id_attribute_value,$position,$db)){
		return sendResponse(200, null, '{"id_attribute_value": $id_attribute, "borrar": "ok"}', $response);
	}else{
		return sendResponse(500, "", $e->getMessage(), $response);
	}

	$db = null;
});



$app->post('/ps_attribute_group/add', function (Request $request, Response $response) {
    $name = trim($request->getParam("name"));

	if(strlen($name)< 1){   //minimo debe tener 1 letra
		return sendResponse(404, null, '{"error":"No has enviado el nombre"}', $response);
	}
	$id_attribute_group =$request->getParam("id_attribute_group");
	if (!is_numeric($id_attribute_group)){
		return sendResponse(404, null, '{"error":"id_attribute_group no es numero"}', $response);
	}
    try {
        $dbInstance = new Db();
        $db = $dbInstance->connectDB();

		$sql = 'SELECT COUNT(*) as contador FROM a_tabla_attribute_group'; //al añadir siempre es el último en "position"
		$statement = $db->prepare($sql);
		$statement->execute();	   
		$data = $statement->fetch();
		$position = $data['contador'];

		$sql = "insert into a_tabla_attribute_group (position,name) values (:position, :name)";
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":name", $name,PDO::PARAM_STR);
		$statement->execute();

		if ($statement->rowCount() > 0) {
			$id_nuevo = $db->lastInsertId();
			return sendResponse(201, null, '{"id_attribute_group": $id_nuevo,  "position": $position}', $response);
		}else{
			return sendResponse(404, null, '{"error":"Error añadiendo attribute_group"}', $response);
		}
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_attribute_group/update', function (Request $request, Response $response) {
    $id_attribute_group = $request->getParam("id_attribute_group");
    $position = $request->getParam("position");
    $name = trim($request->getParam("name"));
	if(!is_numeric($position)){   //debe ser un número 
		return sendResponse(404, null, '{"error":"Posicion no es numero"}', $response);
	}
	if(!is_numeric($id_attribute_group)){   //debe ser un número 
		return sendResponse(404, null, '{"error":"id_attribute_group no es numero"}', $response);
	}
	if(strlen($name)< 1){   //minimo debe 
		return sendResponse(404, null, '{"error":"No has enviado el nombre"}', $response);
	}

	$sql = 'SELECT position FROM a_tabla_attribute_group where id_attribute_group = :id_attribute_group';
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_attribute_group", $id_attribute_group, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, '{"error":"No existe el attribute"}', $response);
	}
	$data = $statement->fetch();
	$positionantigua = $data['position'];

	//si cambia de posicion debe cambiar el resto de registros para que los numeros sean siempre correlativos
	// 0,1,2,3,4,5, etc
	if ($positionantigua != $position){
		if ($positionantigua > $position){
			$sql = "update a_tabla_attribute_group set position=position +1 where position >= :position and position < :positionantigua";
		}else{
			$sql = "update a_tabla_attribute_group set position=position -1 where position >= :positionantigua and position <= :position";
		}
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":positionantigua", $positionantigua, PDO::PARAM_INT);
		$statement->execute();
	}

    try {
		$sql = "UPDATE a_tabla_attribute_group SET position=:position, name=:name WHERE id_attribute_group = :id_attribute_group";
        $statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute_group", $id_attribute_group, PDO::PARAM_INT);
        $statement->bindParam(":position", $position, PDO::PARAM_INT);
        $statement->bindParam(":name", $name,PDO::PARAM_STR);
        $statement->execute();

		if ($statement->rowCount() > 0) {
            return sendResponse(200, null, '{"id_attribute_group": $id_attribute, "actualizar":"ok"}', $response);
        } else {
            return sendResponse(404, null, '{"error":"No se pudo actualizar"}', $response);
        }
        $db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_attribute_group/delete', function (Request $request, Response $response) {
    $id_attribute_group = $request->getParam('id_attribute_group');
	if(!is_numeric($id_attribute_group)){   //debe ser un número 
		return sendResponse(404, null, '{"error":"id_attribute_group no es numero"}', $response);
	}
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$sql = 'SELECT position FROM a_tabla_attribute_group where id_attribute_group = :id_attribute_group';
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_attribute_group", $id_attribute_group, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, '{"error":"No existe el attribute"}', $response);
	}
	$data = $statement->fetch();
	$position = $data['position'];

	try {
		//al eliminar un attribute hay que corregir la posicion del resto de attributes
		$sql = 'update a_tabla_attribute_group set position = position -1 where position > :position';
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->execute();

		$sql = "select id_attribute,position from a_tabla_attribute where id_attribute_group =:id_attribute_group";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute", $id_attribute, PDO::PARAM_INT);
		$statement->execute();
		while ($fila  = $statement->fetch()) {
			borrar_attribute($fila['id_attribute'],$fila['position'],$db);
		}

		$sql = 'DELETE a_tabla_attribute_group.* FROM a_tabla_attribute_group WHERE id_attribute_group=:id_attribute_group';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_attribute_group", $id_attribute_group, PDO::PARAM_INT);
		$statement->execute();
        $db = null;
		return sendResponse(200, null, '{"id_attribute_group": $id_attribute_group, "borrar":"ok"}', $response);
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_attribute/get_todos', function (Request $request, Response $response) {
	try {
		$dbInstance = new Db();
        $db = $dbInstance->connectDB();

		$sql = 'SELECT id_attribute_group,position,name FROM a_tabla_attribute_group order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		$a_tabla_attribute_group = $statement->fetchAll(PDO::FETCH_ASSOC);

		$sql = 'SELECT id_attribute,id_attribute_group,position,name FROM a_tabla_attribute order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		$a_tabla_attribute = $statement->fetchAll(PDO::FETCH_ASSOC);

		$sql = 'SELECT id_attribute_value,id_attribute,position,value FROM a_tabla_attribute_value';
		$dbInstance = new Db();
        $db = $dbInstance->connectDB();
		$statement = $db->prepare($sql);
		$statement->execute();
		$a_tabla_attribute_value = $statement->fetchAll(PDO::FETCH_ASSOC);
		$db = null;
		
		return sendResponse(200, ["ps_attribute_group"=>$ps_attribute_group, "ps_attribute"=>$ps_attribute,"ps_attribute_value"=>$ps_attribute_value], "lista_attribute_todos", $response);

    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});
?>