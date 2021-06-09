<?php
use \Psr\Http\Message\ResponseInterface as Response;
use \Psr\Http\Message\ServerRequestInterface as Request;
		//$sql = 'SELECT * FROM Organization WHERE City = :City AND State= :State';
		//$stmt = $db->prepare($sql);
		//$params = array(':City' => 'string1', ':State' => 'string2');
		//foreach ($params as $key => &$val) {
		//	$stmt->bindParam($key, $val);
		//}

function borrar_feature($id_feature,$position,$db){
	try {
		//al eliminar un feature hay que corregir la posicion del resto de features
		$sql = 'update ps_feature set position = position -1 where position > :position';
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->execute();

		$sql = "select id_feature_value,position from ps_feature_value where id_feature =:id_feature";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
		$statement->execute();
		while ($fila  = $statement->fetch()) {
			borrar_feature_value($fila['id_feature_value'],$fila['position'],$db);
		}

		//hay que eliminar cualquier información colocada en un producto, en la tabla feature_value y finalmente en feature
		$sql = 'delete ps_feature_product.* from ps_feature_product where id_feature = :id_feature';  //borro los valores ya asignados a productos
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
		$statement->execute();

		$sql = 'delete ps_feature.* from ps_feature where id_feature = :id_feature';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
		$statement->execute();
		return true;
    } catch (PDOException $e) {
		return false;
        //return sendResponse(500, "", $e->getMessage(), $response);
    }
}

function borrar_feature_value($id_feature_value,$position,$db){
	try {
		//al eliminar un feature hay que corregir la posicion del resto de features
		$sql = 'update ps_feature_value set position = position -1 where position > :position';
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->execute();

		//marco las fichas de los productos donde se eliminan las feature_value para rehacer el HTML
		$sql = 'UPDATE a_tabla_product INNER JOIN ps_feature_product ON a_tabla_product.id_product = ps_feature_product.id_product SET a_tabla_product.rehacerHTML = 1
		WHERE ps_feature_product.id_feature_value=:id_feature_value';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature_value", $id_feature_value, PDO::PARAM_INT);
		$statement->execute();

		//hay que eliminar cualquier información colocada en un producto, en la tabla feature_value y finalmente en feature
		$sql = 'delete ps_feature_product.* from ps_feature_product where id_feature_value = :id_feature_value';  //borro los valores ya asignados a productos
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature_value", $id_feature_value, PDO::PARAM_INT);
		$statement->execute();

		$sql = 'delete ps_feature_value.* FROM ps_feature_value WHERE id_feature_value = :id_feature_value';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature_value", $id_feature_value, PDO::PARAM_INT);
		$statement->execute();

		return true;
    } catch (PDOException $e) {
		return false;
        //return sendResponse(500, "", $e->getMessage(), $response);
    }
}


$app->post('/ps_feature_todas/get', function (Request $request, Response $response) {
	$sql = 'SELECT id_feature,id_feature_super,position,name FROM ps_feature order by position';
	try {
		$dbInstance = new Db();
        $db = $dbInstance->connectDB();

		$sql = 'SELECT id_feature_super,position,name FROM ps_feature_super order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		if ($statement->rowCount() == 0) {
			$ps_feature_super =[];
		}else{
			$ps_feature_super = $statement->fetchAll(PDO::FETCH_ASSOC);
		}

		$sql = 'SELECT id_feature,id_feature_super,position,name FROM ps_feature order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		if ($statement->rowCount() == 0) {
			$ps_feature =[];
		}else{
			$ps_feature = $statement->fetchAll(PDO::FETCH_ASSOC);
		}

		$sql = 'SELECT id_feature_value,id_feature,position,value FROM ps_feature_value';
		$statement = $db->prepare($sql);
		$statement->execute();
		if ($statement->rowCount() == 0) {
			$ps_feature_value =[];
		}else{
			$ps_feature_value = $statement->fetchAll(PDO::FETCH_ASSOC);
		}

		return sendResponse(200, ["ps_feature_super"=>$ps_feature_super,"ps_feature"=>$ps_feature,"ps_feature_value"=>$ps_feature_value], "lista_feature", $response);
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});

$app->post('/ps_feature/add', function (Request $request, Response $response) {
    $name = trim($request->getParam("name"));

	if(strlen($name)< 1){   //minimo debe tener 1 letra
		return sendResponse(404, null, "No has enviado el nombre", $response);
	}
	$id_feature_super =$request->getParam("id_feature_super");
	if (!is_numeric($id_feature_super)){
		return sendResponse(404, null, "id_feature_super no es numero", $response);
	}
	$sql = 'SELECT id_feature_super FROM ps_feature_super where id_feature_super = :id_feature_super';
	$dbInstance = new Db();
	$db = $dbInstance->connectDB();
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_feature_super", $id_feature_super, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, "No existe el feature_super en la tabla ps_feature_super", $response);
	}

    try {
		$sql = 'SELECT COUNT(*) as contador FROM ps_feature where id_feature_super= :id_feature_super'; //al añadir siempre es el último en "position"
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature_super", $id_feature_super, PDO::PARAM_INT);
		$statement->execute();
		$data = $statement->fetch();
		$position = $data['contador'];

		$sql = "insert into ps_feature (position,name,id_feature_super) values (:position, :name, :id_feature_super)";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature_super", $id_feature_super, PDO::PARAM_INT);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":name", $name,PDO::PARAM_STR);
		$statement->execute();

		if ($statement->rowCount() > 0) {
			$id = $db->lastInsertId();
			return sendResponse(201, null, "Nueva id_feature: $id  position: $position", $response);
		}else{
			return sendResponse(404, null, "Error añadiendo feature", $response);
		}
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_feature/update', function (Request $request, Response $response) {
    $id_feature = $request->getParam("id_feature");
    $position = $request->getParam("position");
    $name = trim($request->getParam("name"));
	if(!is_numeric($position)){   //debe ser un número
		return sendResponse(404, null, "Posicion no es numero", $response);
	}
	if(!is_numeric($id_feature)){   //debe ser un número
		return sendResponse(404, null, "id_feature no es numero", $response);
	}
	if(strlen($name)< 1){   //minimo debe
		return sendResponse(404, null, "No has enviado el nombre", $response);
	}

	$sql = 'SELECT position,id_feature_super FROM ps_feature where id_feature = :id_feature';
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, "No existe el feature", $response);
	}
	$data = $statement->fetch();
	$positionantigua = $data['position'];
	$id_feature_super = $data['id_feature_super'];

	//si cambia de posicion debe cambiar el resto de registros para que los numeros sean siempre correlativos
	// 0,1,2,3,4,5, etc
	if ($positionantigua != $position){
		if ($positionantigua > $position){
			$sql = "update ps_feature set position=position +1 where id_feature_super = :id_feature_super and position >= :position and position < :positionantigua";
		}else{
			$sql = "update ps_feature set position=position -1 where id_feature_super = :id_feature_super and position >= :positionantigua and position <= :position";
		}
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":positionantigua", $positionantigua, PDO::PARAM_INT);
		$statement->execute();
	}

    try {
		$sql = "UPDATE ps_feature SET position=:position, name=:name WHERE id_feature = :id_feature";
        $statement = $db->prepare($sql);
        $statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
        $statement->bindParam(":position", $position, PDO::PARAM_INT);
        $statement->bindParam(":name", $name,PDO::PARAM_STR);
        $statement->execute();

		if ($statement->rowCount() > 0) {
            return sendResponse(200, null, "ActualizadoOk", $response);
        } else {
            return sendResponse(404, null, "No se pudo actualizar", $response);
        }
        $db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_feature/delete', function (Request $request, Response $response) {
    $id_feature = $request->getParam('id_feature');
	if(!is_numeric($id_feature)){   //debe ser un número
		return sendResponse(404, null, "id_feature no es numero", $response);
	}
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$sql = 'SELECT position FROM ps_feature where id_feature = :id_feature';
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, "No existe el feature", $response);
	}
	$data = $statement->fetch();

	if(borrar_feature($id_feature,$data["position"],$db)){
		$db = null;
		return sendResponse(200, null, "BorradoOk", $response);
    }else{
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});









$app->post('/ps_feature_value/add', function (Request $request, Response $response) {
    $value = trim($request->getParam("value"));

	if(strlen($value)< 1){   //minimo debe tener 1 letra
		return sendResponse(404, null, "No has enviado el nombre", $response);
	}
	$id_feature =$request->getParam("id_feature");
	if (!is_numeric($id_feature)){
		return sendResponse(404, null, "id_feature no es numero", $response);
	}

	$dbInstance = new Db();
	$db = $dbInstance->connectDB();

	$sql = 'SELECT id_feature FROM ps_feature where id_feature = :id_feature';
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, "No existe el id_feature en la tabla ps_feature", $response);
	}

    try {

		$sql = 'SELECT COUNT(*) as contador FROM ps_feature_value'; //al añadir siempre es el último en "position"
		$statement = $db->prepare($sql);
		$statement->execute();
		$data = $statement->fetch();
		$position = $data['contador'];

		$sql = "insert into ps_feature_value (position,value,id_feature) values (:position, :value, :id_feature)";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":value", $value,PDO::PARAM_STR);
		$statement->execute();

		if ($statement->rowCount() > 0) {
			$id = $db->lastInsertId();
			return sendResponse(201, null, "Nueva id_feature_value: $id  position: $position", $response);
		}else{
			return sendResponse(404, null, "Error añadiendo feature_value", $response);
		}
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_feature_value/update', function (Request $request, Response $response) {
    $id_feature_value = $request->getParam("id_feature_value");
    $position = $request->getParam("position");
    $value = trim($request->getParam("value"));
	if(!is_numeric($position)){   //debe ser un número
		return sendResponse(404, null, "Posicion no es numero", $response);
	}
	if(!is_numeric($id_feature_value)){   //debe ser un número
		return sendResponse(404, null, "id_feature_value no es numero", $response);
	}
	if(strlen($value)< 1){   //minimo debe
		return sendResponse(404, null, "No has enviado el value", $response);
	}

	$sql = 'SELECT position,id_feature FROM ps_feature_value where id_feature_value = :id_feature_value';
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_feature_value", $id_feature_value, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, "No existe el feature", $response);
	}
	$data = $statement->fetch();
	$positionantigua = $data['position'];
	$id_feature = $data['id_feature'];

	//si cambia de posicion debe cambiar el resto de registros para que los numeros sean siempre correlativos
	// 0,1,2,3,4,5, etc
	if ($positionantigua != $position){
		if ($positionantigua > $position){
			$sql = "update ps_feature_value set position=position +1 where id_feature = :id_feature and position >= :position and position < :positionantigua";
		}else{
			$sql = "update ps_feature_value set position=position -1 where id_feature = :id_feature and position >= :positionantigua and position <= :position";
		}
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":positionantigua", $positionantigua, PDO::PARAM_INT);
		$statement->execute();
	}

    try {
		$sql = "UPDATE ps_feature_value SET position=:position, value=:value WHERE id_feature_value = :id_feature_value";
        $statement = $db->prepare($sql);
        $statement->bindParam(":id_feature_value", $id_feature, PDO::PARAM_INT);
        $statement->bindParam(":position", $position, PDO::PARAM_INT);
        $statement->bindParam(":value", $value,PDO::PARAM_STR);
        $statement->execute();

		if ($statement->rowCount() > 0) {
            return sendResponse(200, null, "ActualizadoOk", $response);
        } else {
            return sendResponse(404, null, "No se pudo actualizar", $response);
        }
        $db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_feature_value/delete', function (Request $request, Response $response) {
    $id_feature_value = $request->getParam('id_feature_value');
	if(!is_numeric($id_feature_value)){   //debe ser un número
		return sendResponse(404, null, "id_feature no es numero", $response);
	}
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$sql = 'SELECT position FROM ps_feature_value where id_feature_value = :id_feature_value';
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_feature_value", $id_feature_value, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, "No existe el feature", $response);
	}
	$data = $statement->fetch();
	$position = $data['position'];

	if (borrar_feature_value($id_feature_value,$position,$db)){
		return sendResponse(200, null, "BorradoOk", $response);
	}else{
		return sendResponse(500, "", $e->getMessage(), $response);
	}

	$db = null;
});





$app->post('/ps_feature_super/add', function (Request $request, Response $response) {
    $name = trim($request->getParam("name"));

	if(strlen($name)< 1){   //minimo debe tener 1 letra
		return sendResponse(404, null, "No has enviado el nombre", $response);
	}
	$id_feature_super =$request->getParam("id_feature_super");
	if (!is_numeric($id_feature_super)){
		return sendResponse(404, null, "id_feature_super no es numero", $response);
	}
    try {
        $dbInstance = new Db();
        $db = $dbInstance->connectDB();

		$sql = 'SELECT COUNT(*) as contador FROM ps_feature_super'; //al añadir siempre es el último en "position"
		$statement = $db->prepare($sql);
		$statement->execute();	   
		$data = $statement->fetch();
		$position = $data['contador'];

		$sql = "insert into ps_feature_super (position,name) values (:position, :name)";
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":name", $name,PDO::PARAM_STR);
		$statement->execute();

		if ($statement->rowCount() > 0) {
			$id = $db->lastInsertId();
			return sendResponse(201, null, "Nueva id_feature_super: $id  position: $position", $response);
		}else{
			return sendResponse(404, null, "Error añadiendo feature_super", $response);
		}
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_feature_super/update', function (Request $request, Response $response) {
    $id_feature_super = $request->getParam("id_feature_super");
    $position = $request->getParam("position");
    $name = trim($request->getParam("name"));
	if(!is_numeric($position)){   //debe ser un número 
		return sendResponse(404, null, "Posicion no es numero", $response);
	}
	if(!is_numeric($id_feature_super)){   //debe ser un número 
		return sendResponse(404, null, "id_feature_super no es numero", $response);
	}
	if(strlen($name)< 1){   //minimo debe 
		return sendResponse(404, null, "No has enviado el nombre", $response);
	}

	$sql = 'SELECT position FROM ps_feature_super where id_feature_super = :id_feature_super';
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_feature_super", $id_feature_super, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, "No existe el feature", $response);
	}
	$data = $statement->fetch();
	$positionantigua = $data['position'];

	//si cambia de posicion debe cambiar el resto de registros para que los numeros sean siempre correlativos
	// 0,1,2,3,4,5, etc
	if ($positionantigua != $position){
		if ($positionantigua > $position){
			$sql = "update ps_feature_super set position=position +1 where position >= :position and position < :positionantigua";
		}else{
			$sql = "update ps_feature_super set position=position -1 where position >= :positionantigua and position <= :position";
		}
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->bindParam(":positionantigua", $positionantigua, PDO::PARAM_INT);
		$statement->execute();
	}

    try {
		$sql = "UPDATE ps_feature_super SET position=:position, name=:name WHERE id_feature_super = :id_feature_super";
        $statement = $db->prepare($sql);
		$statement->bindParam(":id_feature_super", $id_feature_super, PDO::PARAM_INT);
        $statement->bindParam(":position", $position, PDO::PARAM_INT);
        $statement->bindParam(":name", $name,PDO::PARAM_STR);
        $statement->execute();

		if ($statement->rowCount() > 0) {
            return sendResponse(200, null, "ActualizadoOk", $response);
        } else {
            return sendResponse(404, null, "No se pudo actualizar", $response);
        }
        $db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_feature_super/delete', function (Request $request, Response $response) {
    $id_feature_super = $request->getParam('id_feature_super');
	if(!is_numeric($id_feature_super)){   //debe ser un número 
		return sendResponse(404, null, "id_feature_super no es numero", $response);
	}
	$dbInstance = new Db();
    $db = $dbInstance->connectDB();
	$sql = 'SELECT position FROM ps_feature_super where id_feature_super = :id_feature_super';
	$statement = $db->prepare($sql);
	$statement->bindParam(":id_feature_super", $id_feature_super, PDO::PARAM_INT);
	$statement->execute();
	if ($statement->rowCount() == 0) {
		return sendResponse(404, null, "No existe el feature", $response);
	}
	$data = $statement->fetch();
	$position = $data['position'];

	try {
		//al eliminar un feature hay que corregir la posicion del resto de features
		$sql = 'update ps_feature_super set position = position -1 where position > :position';
		$statement = $db->prepare($sql);
		$statement->bindParam(":position", $position, PDO::PARAM_INT);
		$statement->execute();

		$sql = "select id_feature,position from ps_feature where id_feature_super =:id_feature_super";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
		$statement->execute();
		while ($fila  = $statement->fetch()) {
			borrar_feature($fila['id_feature'],$fila['position'],$db);
		}
		
		$sql = 'DELETE ps_feature_super.* FROM ps_feature_super WHERE id_feature_super=:id_feature_super';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature_super", $id_feature_super, PDO::PARAM_INT);
		$statement->execute();
        $db = null;
		return sendResponse(200, null, "BorradoOk", $response);
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/ps_feature/get_todos', function (Request $request, Response $response) {
	try {
		$dbInstance = new Db();
        $db = $dbInstance->connectDB();

		$sql = 'SELECT id_feature_super,position,name FROM ps_feature_super order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		$ps_feature_super = $statement->fetchAll(PDO::FETCH_ASSOC);

		$sql = 'SELECT id_feature,id_feature_super,position,name FROM ps_feature order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		$ps_feature = $statement->fetchAll(PDO::FETCH_ASSOC);

		$sql = 'SELECT id_feature_value,id_feature,position,value FROM ps_feature_value';
		$dbInstance = new Db();
        $db = $dbInstance->connectDB();
		$statement = $db->prepare($sql);
		$statement->execute();
		$ps_feature_value = $statement->fetchAll(PDO::FETCH_ASSOC);
		$db = null;
		
		return sendResponse(200, ["ps_feature_super"=>$ps_feature_super, "ps_feature"=>$ps_feature,"ps_feature_value"=>$ps_feature_value], "lista_feature_todos", $response);

    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});
?>