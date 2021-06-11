<?php
use \Psr\Http\Message\ResponseInterface as Response;
use \Psr\Http\Message\ServerRequestInterface as Request;

$app->post('/productos/get', function (Request $request, Response $response) {
    $id_product = $request->getParam("id_product");
	if(!is_numeric($id_product)){
		return sendResponse(404, null, "No has enviado el numero", $response);
	}
	try {
		$sql = 'SELECT id_product,`id_supplier`, `id_manufacturer`,`id_category_default`,`ean13`,`quantity`, `minimal_quantity`, `price`,`reference`, `supplier_reference`,'.
			'`cache_default_attribute`, `date_add`,`date_upd`, `stateWeb`, `description`, `description_short`, `link_rewrite`, `meta_description`, `meta_keywords`, `meta_title`,'.
			'`name`, `delivery_in_stock`, `delivery_out_stock`,`paso`,preciocoste FROM a_tabla_product where id_product = :id_product';
		$dbInstance = new Db();
		$db = $dbInstance->connectDB();

		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();
		if ($statement->rowCount() == 0) {
			return sendResponse(404, null, '{"razon": "id '.$id_product.' no existe"}', $response);
		}
		$ps_product = $statement->fetchAll(PDO::FETCH_ASSOC);
		$id_combinacion =$ps_product[0]['cache_default_attribute'];

		
		$sql = "select id_feature_value,position from a_tabla_feature_value where id_feature =:id_feature";
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_feature", $id_feature, PDO::PARAM_INT);
		$statement->execute();
		while ($fila  = $statement->fetch()) {
			borrar_feature_value($fila['id_feature_value'],$fila['position'],$db);
		}

		$sql = 'SELECT * FROM a_tabla_image where id_product= :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();
		$ps_image = $statement->fetchAll(PDO::FETCH_ASSOC);

		$sql = 'SELECT id_category FROM a_tabla_category_product where id_product= :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();
		$ps_category_product = $statement->fetchAll(PDO::FETCH_ASSOC);

		$sql = 'SELECT id_feature_value FROM a_tabla_feature_product where id_product= :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();
		$ps_feature_product = $statement->fetchAll(PDO::FETCH_ASSOC);

		$sql = 'SELECT id_feature_super,position,name FROM a_tabla_feature_super order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		$ps_feature_super = $statement->fetchAll(PDO::FETCH_ASSOC);

		$sql = 'SELECT id_feature,id_feature_super,position,name FROM a_tabla_feature order by position';
		$statement = $db->prepare($sql);
		$statement->execute();
		$ps_feature = $statement->fetchAll(PDO::FETCH_ASSOC);

		$sql = 'SELECT id_feature_value,id_feature,position,name FROM a_tabla_feature_value';
		$dbInstance = new Db();
        $db = $dbInstance->connectDB();
		$statement = $db->prepare($sql);
		$statement->execute();
		$ps_feature_value = $statement->fetchAll(PDO::FETCH_ASSOC);

		//if($id_combinacion==0){
		if(0==0){	
			return sendResponse(200, [[],"ps_tabla_attribute"=>[],"ps_product_attribute"=>[],"ps_product_attribute_combination"=>[],"ps_product_attribute_image"=>[],"ps_product"=>$ps_product, "ps_image"=>$ps_image,"ps_category_product"=>$ps_category_product, "ps_feature_product"=>$ps_feature_product,"ps_feature_super"=>$ps_feature_super,"ps_feature"=>$ps_feature,"ps_feature_value"=>$ps_feature_value],"Todo de Producto Simple".$id_combinacion."-.-", $response);
		}else{
			$sql = 'select id_attribute,id_attribute_group,color,position,name from a_tabla_attribute';
			$statement = $db->prepare($sql);
			$statement->execute();
			$ps_tabla_attribute = $statement->fetchAll(PDO::FETCH_ASSOC);

			$sql = 'select id_attribute_group, is_color_group, group_type, position, name, public_name from a_tabla_attribute_group';
			$statement = $db->prepare($sql);
			$statement->execute();
			$ps_attribute_group = $statement->fetchAll(PDO::FETCH_ASSOC);
			
			$sql = 'SELECT id_product_attribute,reference,supplier_reference,ean13,price,quantity,default_on,available_date FROM a_tabla_product_attribute where id_product= :id_product';
			$statement = $db->prepare($sql);
			$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
			$statement->execute();
			$ps_product_attribute = $statement->fetchAll(PDO::FETCH_ASSOC);
			$lista_id_combinaciones="";
			foreach ($ps_product_attribute as $key => $fila) {
				$lista_id_combinaciones .= $fila['id_product_attribute']. ",";
			}
			$lista_id_combinaciones = substr($lista_id_combinaciones,0,-1);

			$sql = "SELECT id_product_attribute, id_attribute FROM a_tabla_product_attribute_combination where id_product_attribute in ( ".$lista_id_combinaciones.") order by id_product_attribute";
			$statement = $db->prepare($sql);
			$statement->execute();
			$ps_product_attribute_combination = $statement->fetchAll(PDO::FETCH_ASSOC);

			$sql = "SELECT id_product_attribute,id_image FROM a_tabla_product_attribute_image where id_product_attribute in (".$lista_id_combinaciones.")";
			$statement = $db->prepare($sql);
			$statement->execute();
			$ps_product_attribute_image= $statement->fetchAll(PDO::FETCH_ASSOC);

			return sendResponse(200, ["ps_attribute_group"=>$ps_attribute_group,"ps_tabla_attribute"=>$ps_tabla_attribute,"ps_product_attribute"=>$ps_product_attribute,"ps_product_attribute_combination"=>$ps_product_attribute_combination,"ps_product_attribute_image"=>$ps_product_attribute_image,	"ps_product"=>$ps_product,"ps_image"=>$ps_image,"ps_category_product"=>$ps_category_product, "ps_feature_product"=>$ps_feature_product,"ps_feature_super"=>$ps_feature_super,"ps_feature"=>$ps_feature,"ps_feature_value"=>$ps_feature_value],"Todo de Producto con Combinaciones", $response);
		}

		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, $sql . $id_product, $e->getMessage(), $response);
    }
});

$app->post('/productos/delete', function (Request $request, Response $response) {
	$id_product = trim($request->getParam("id_product"));

	if (!is_numeric($id_product)){
		return sendResponse(404, null, "id_product no es numero", $response);
	}

	try{
		$sql = 'SELECT id_category,position FROM a_tabla_category_product where id_product= :id_product';
		$dbInstance = new Db();
		$db = $dbInstance->connectDB();

		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();
		while ($fila = $statement->fetch()){
			$sql = 'update a_tabla_category_product set position = position -1 where id_category=:id_category and position>:position';
			$eliminar = $db->prepare($sql);
			$eliminar->bindParam(":position", $position, PDO::PARAM_INT);
			$eliminar->bindParam(":id_category", $fila['id_category'], PDO::PARAM_INT);
			$eliminar->execute();
		}

		$sql = 'delete a_tabla_category_product.* FROM a_tabla_category_product where id_product= :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();

		//habrá que borrar las imagenes.jpg en algun momento
		$sql = 'delete a_tabla_image.* FROM a_tabla_image where id_product= :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();

		$sql = 'delete a_tabla_feature_product.* FROM a_tabla_feature_product where id_product= :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();

		$sql = 'delete a_tabla_product_attachment.* from a_tabla_product_attachment where id_product = :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();

		$sql = 'DELETE a_tabla_product_attribute_image.* FROMa_tabla_product_attribute INNER JOIN a_tabla_product_attribute_image
		ON a_tabla_product_attribute.id_product_attribute = a_tabla_product_attribute_image.id_product_attribute
		WHERE a_tabla_product_attribute.id_product = :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();

		$sql = 'DELETE a_tabla_product_attribute_combination.* FROM a_tabla_product_attribute INNER JOIN a_tabla_product_attribute_combination
		ON a_tabla_product_attribute.id_product_attribute = a_tabla_product_attribute_combination.id_product_attribute
		WHERE a_tabla_product_attribute.id_product= :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();

		$sql = 'DELETE a_tabla_product_attribute.* FROM a_tabla_product_attribute WHERE id_product= :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();

		$sql = 'delete a_tabla_product.* from a_tabla_product where id_product = :id_product';
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->execute();

		return sendResponse(200, "Producto Borrado Correctamente", "resultado_eliminar_productos", $response);
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});

$app->post('/productos/add_update', function (Request $request, Response $response) {
	$id_product =$request->getParam("id_product");
	if (!is_numeric($id_product)){
		return sendResponse(400, "I dont know if it is new.".$id_product.".","API Stop", $response);
	}
	if ($id_product == "0"){
		try {
			$dbInstance = new Db();
			$db = $dbInstance->connectDB();
			$sql="insert into a_tabla_product (rehacerHTML, id_supplier, id_manufacturer, id_category_default, ean13, quantity, minimal_quantity, price, preciocoste, reference, supplier_reference,   cache_default_attribute, date_add, date_upd, stateWeb, description, description_short, link_rewrite, meta_description, meta_keywords, meta_title, name, delivery_in_stock, delivery_out_stock, paso) values
										(	0,				0,				0,					0,			'',		0,				1,			0,			0,		'',			'',									0,	'".date('Y-m-d H:i:s')."',now(),0,			'',				'',				'',				'',					'',			'',		'',			'',				'',				0)";
			$statement = $db->prepare($sql);
			$statement->execute();
			$id_product = $db->lastInsertId();

		} catch (PDOException $e) {
			return sendResponse(500, "", $e->getMessage(), $response);
		}
	}

	try {
		$sql="update a_tabla_product set date_upd =:date_upd,stateWeb=:stateWeb, id_supplier =:id_supplier,id_manufacturer =:id_manufacturer, id_category_default =:id_category_default,".
			"ean13 =:ean13,quantity =:quantity,minimal_quantity =:minimal_quantity, price =:price,reference =:reference,supplier_reference =:supplier_reference,".
			"paso=:paso,preciocoste = :preciocoste,cache_default_attribute=:cache_default_attribute,description =:description,".
			"description_short =:description_short,link_rewrite =:link_rewrite,meta_description =:meta_description,meta_keywords =:meta_keywords,".
			"meta_title =:meta_title,name =:name,delivery_in_stock =:delivery_in_stock,delivery_out_stock =:delivery_out_stock where id_product = :id_product";
		if ($id_product != "0"){
			$dbInstance = new Db();
			$db = $dbInstance->connectDB();
		}
		$statement = $db->prepare($sql);
		$params = array(
			':stateWeb' => $request->getParam("stateWeb"),
			':id_supplier' => $request->getParam("id_supplier"),
			':id_manufacturer' => $request->getParam("id_manufacturer"),
			':id_category_default' => $request->getParam("id_category_default"),
			':ean13' => $request->getParam("ean13"),
			':quantity' => $request->getParam("quantity"),
			':minimal_quantity' => $request->getParam("minimal_quantity"),
			':price' => $request->getParam("price"),
			':reference' => $request->getParam("reference"),
			':supplier_reference' => $request->getParam("supplier_reference"),
			':paso' => $request->getParam("paso"),
			':preciocoste' => $request->getParam("preciocoste"),
			':cache_default_attribute' => $request->getParam("cache_default_attribute"),
			':description' => $request->getParam("description"),
			':description_short' => $request->getParam("description_short"),
			':link_rewrite' => $request->getParam("link_rewrite"),
			':meta_description' => $request->getParam("meta_description"),
			':meta_keywords' => $request->getParam("meta_keywords"),
			':meta_title' => $request->getParam("meta_title"),
			':name' => $request->getParam("name"),
			':date_upd'=> date('Y-m-d H:i:s'),
			':delivery_in_stock' => $request->getParam("delivery_in_stock"),
			':delivery_out_stock' => $request->getParam("delivery_out_stock"),
			':id_product' => $id_product);

		$traduccion = $sql;
		$respuesta="";
		foreach ($params as $key => &$val) {
			$statement->bindParam($key, $val);
			if (!is_numeric($val)){
				$sql = str_replace($key, "'".$val."'",$sql);
			}else{
				$sql = str_replace($key, $val,$sql);
			}
			$respuesta .= $key ."__".$val."###";
		}
		//
		$statement->execute();
		$db = null;
		return sendResponse(200,$sql."#####".$respuesta. "ID Producto: $id_product" , "Proceso new terminado", $response);
	}catch (PDOException $e) {
		return sendResponse(500, $sql. "    producto $id_product" , $e->getMessage(), $response);
	}
});


$app->post('/productos/add_category', function (Request $request, Response $response) {
	// attachment ps_product_attachment attributes ps_product_attribute ps_product_attribute_combination ps_product_attribute_image

    $id_product = $request->getParam("id_product");
	$id_category = $request->getParam("id_category");
	if (!is_numeric($id_category)){
		return sendResponse(404, null, "No has indicado la id_category $id_category", $response);
	}
	if (!is_numeric($id_product)){
		return sendResponse(404, null, "No has indicado el id_product $id_product", $response);
	}

	try {
		$sql = 'SELECT * FROM a_tabla_category_product where id_product = :id_product and id_category = :id_category';
		$dbInstance = new Db();
		$db = $dbInstance->connectDB();
		$statement = $db->prepare($sql);
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
		$statement->bindParam(":id_category", $id_category, PDO::PARAM_INT);
		$statement->execute();

		if ($statement->rowCount() == 0) {
			$sql = 'SELECT COUNT(*) as contador FROM a_tabla_category_product where id_category= :id_category'; //al añadir siempre es el último en "position"
			$statement = $db->prepare($sql);
			
			$statement->bindParam(":id_category", $id_category, PDO::PARAM_INT);
			$statement->execute();
			$data = $statement->fetch();
			$position = $data['contador'];
			
			$sql = 'insert into a_tabla_category_product(id_category,id_product,position) values(:id_category, :id_product, :position)'; //al añadir siempre es el último en "position"
			$statement = $db->prepare($sql);
			$statement->bindParam(":id_product", $id_product, PDO::PARAM_INT);
			$statement->bindParam(":id_category", $id_category, PDO::PARAM_INT);
			$statement->bindParam(":position", $position, PDO::PARAM_INT);
			$statement->execute();
		}else{
			return sendResponse(404, null, "El producto ya está en la categoría $id_category", $response);
		}
		return sendResponse(200, "añadido a $id_category correctamente", "resultado_añadir_categoria_a_producto", $response);
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, "", $e->getMessage(), $response);
    }
});
?>