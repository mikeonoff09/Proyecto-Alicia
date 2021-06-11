<?php
use \Psr\Http\Message\ResponseInterface as Response;
use \Psr\Http\Message\ServerRequestInterface as Request;


function removeDoubleSpaces($str) {
	$str = trim($str);
	while (strpos($str,"  ")){
		$str = str_replace("  ", " ",$str);
	}
	return $str;
}


$app->post('/inicio_aplicacion/get', function (Request $request, Response $response) {
try {
	$dbInstance = new Db();
	$db = $dbInstance->connectDB();
	$statement = $db->prepare("select id_category,name,id_parent,level_depth,nleft,nright,active,position,is_root_category from a_tabla_category order by position");
	$statement->execute();
	$lista_categorias = $statement->fetchAll(PDO::FETCH_OBJ);

	$statement = $db->prepare("select id_manufacturer,name, description from a_tabla_manufacturer order by name");
	$statement->execute();
	$lista_fabricantes = $statement->fetchAll(PDO::FETCH_OBJ);

	$statement = $db->prepare("select id_supplier,name, description from a_tabla_supplier order by name");
	$statement->execute();
	$lista_distribuidores = $statement->fetchAll(PDO::FETCH_OBJ);
	$db = null;
	return sendResponse(200, ["categorias"=>$lista_categorias, "fabricantes"=>$lista_fabricantes, "distribuidores"=>$lista_distribuidores],"Inicio", $response);
    } catch (PDOException $e) {
		return sendResponse(500, "", $e->getMessage(), $response);
    }
});


$app->post('/listado_productos/get', function (Request $request, Response $response) {
	$DondeEntra = "";
	$fabricante = trim($request->getParam("fabricante"));
	if (!is_numeric($fabricante)){
		return sendResponse(404, null, "fabricante no es numero", $response);
	}
	$id_product = trim($request->getParam("idproduct"));
	if ($id_product ==""){
		$id_product =0;
	}else{
		if (!is_numeric($id_product)){
			return sendResponse(404, [], "id_product no es numero", $response);
		}
	}

	$category = trim($request->getParam("category"));
	if (!is_numeric($category)){
		return sendResponse(404, null, "category no es numero", $response);
	}
	$referencia = trim($request->getParam("referencia"));
	$name = trim($request->getParam("name"));
	$supplier = trim($request->getParam("supplier"));
	if (!is_numeric($supplier)){
		return sendResponse(404, null, "supplier no es numero", $response);
	}
	$stateWeb = trim($request->getParam("stateWeb"));
	if (!is_numeric($stateWeb)){
		return sendResponse(404, null, "stateWeb no es numero", $response);
	}
	$orden = trim($request->getParam("orden"));
	$pagina = trim($request->getParam("pagina"));
	if (!is_numeric($pagina)){
		return sendResponse(404, null, "pagina no existe", $response);
	}

	$query = "SELECT id_product, '' as Portada, '' as Ambiente,name as Nombre_Producto,".
		"CONCAT(reference,' || ',supplier_reference) as Referencias,id_category_default as Categoría,".
        "id_manufacturer as Fabricante,id_supplier as Proveedor, round(price*(1+21/100),2) AS PVP,stateWeb,".
        "paso FROM a_tabla_product ";

	$query_simple = "SELECT Count(*) as Contador FROM a_tabla_product ";
	$where = "";

	if ($id_product != 0){
		$query_simple .= "where id_product = :id_product";
		$query .= "where id_product = :id_product";
	}else{
		if ($stateWeb == "1" || $stateWeb == "0") {
		  $where = "stateWeb = :stateWeb and ";
		}
		if ($fabricante != 0) {
		  $where .=  "id_manufacturer= :fabricante and ";
		}
		if ($category != 0) {
			$DondeEntra .="a";
			$where .= "id_category_default = :category and ";
		}
		if ($name != "") {
			$name = removeDoubleSpaces($name);
			$nombres = explode(" ",$name);

			for ($i = 0; $i < count($nombres); $i++){
			  $where .= "(name like '%" . $nombres[$i] . "%' or meta_keywords like '%" . $nombres[$i] . "%')  and ";
			}
		}
		if ($supplier != 0) {
		  $where .= "id_supplier= :supplier and ";
		}
		if ($referencia != "") {
		  $where .= "(reference like :referencia or supplier_reference like :referencia) and ";
		}
		if($where != "" ){
			$where = " where ". substr($where,0,-4);
		}
		$query .=$where;
		$query_simple.=$where;

		if ($orden == "") {
			$query .=  " order by id_product desc limit ". $pagina*50 . "," . ($pagina+1)*50;
		}else{
			$query .=  " order by :orden limit ". $pagina*50 . "," . ($pagina+1)*50;
		}
	}

	$dbInstance = new Db();
	$db = $dbInstance->connectDB();	
	$statement = $db->prepare($query_simple);
	
	if ($id_product != 0) {
		$statement->bindParam(":id_product", $id_product, PDO::PARAM_STR);
	}else{
		if ($stateWeb == "1" || $stateWeb == "0") {
			$DondeEntra .="1";
			$statement->bindParam(":stateWeb", $stateWeb, PDO::PARAM_STR);
		}
		if ($fabricante != 0) {
			$DondeEntra .="2";
			$statement->bindParam(":fabricante", $fabricante, PDO::PARAM_INT);
		}
		if ($category != 0) {
			$DondeEntra .="b";
			$statement->bindParam(":category", $category, PDO::PARAM_INT);
		}
		//if ($nombre != "") 
		//  $statement->bindParam(":nombre", $nombre, PDO::PARAM_STR);
		//}	
		if ($supplier != 0) {
			$DondeEntra .="3";
		  $statement->bindParam(":supplier", $supplier, PDO::PARAM_INT);
		}
		if ($referencia != "") {
			$DondeEntra .="4";
			$referencia= "%".$referencia."%";
			$statement->bindParam(":referencia", $referencia, PDO::PARAM_STR);
		}
	}

	try {
		$DondeEntra .="g";
		$statement->execute();
		$DondeEntra .="f";
		$Contador = $statement->fetch();
		if ($Contador["Contador"]==0){
			return sendResponse(200, [], "No encontrado:".$query , $response);
		}
		$statement = $db->prepare($query);
		if ($id_product != 0) {
			$statement->bindParam(":id_product", $id_product, PDO::PARAM_STR);
		}else{
			if ($stateWeb == "1" || $stateWeb == "0") {
				$statement->bindParam(":stateWeb", $stateWeb, PDO::PARAM_STR);
			}
			if ($fabricante != 0) {
				$statement->bindParam(":fabricante", $fabricante, PDO::PARAM_INT);
			}
			if ($category != 0) {
				$statement->bindParam(":category", $category, PDO::PARAM_INT);
			}
			//if ($name != "") 
			//  $statement->bindParam(":name", $name, PDO::PARAM_STR);
			//}
			if ($supplier != 0) {
			  $statement->bindParam(":supplier", $supplier, PDO::PARAM_INT);
			}
			if ($referencia != "") {
				$statement->bindParam(":referencia", $referencia, PDO::PARAM_STR);
			}
			if ($orden != "") {
				$statement->bindParam(":orden", $orden, PDO::PARAM_STR);
			}
		}
		$statement->execute();

		$lista_id_products="";
		$productos = $statement->fetchAll(PDO::FETCH_ASSOC);
		foreach ($productos as $key => $fila) {
			$lista_id_products .= $fila['id_product']. ",";
		}

		$lista_id_products = substr($lista_id_products,0,-1);
		$query= "select id_image,id_product FROM a_tabla_image where id_product in ( $lista_id_products ) and cover =1";
		$statement2 = $db->prepare($query);
		$statement2->execute();
		$covers = $statement2->fetchAll(PDO::FETCH_ASSOC);
		 

		$query= "SELECT id_image, id_product FROM a_tabla_image where id_product in ( $lista_id_products) and isnull(cover)= true and descartada = 0 ORDER by id_product,position";
		$statement2 = $db->prepare($query);
		$anterior = 0;
		$statement2->execute();

		$ambientes = $statement2->fetchAll(PDO::FETCH_ASSOC);

		for ($i = 0; $i < count($productos);$i++){
			$idProduct = $productos[$i]["id_product"];
			foreach ($covers as $key => $coverValue) {
				if($coverValue["id_product"] == $idProduct){
					$productos[$i]["Portada"] = $coverValue["id_image"];
					break;
				}
			}
			foreach ($ambientes as $key => $ambienteValue) {
				if($ambienteValue["id_product"] == $idProduct){
					$productos[$i]["Ambiente"] = $ambienteValue["id_image"];
					break;
				}
			}
		}

		return sendResponse(200, $productos, "totalPage: ".$Contador["Contador"], $response);
		$db = null;
    } catch (PDOException $e) {
        return sendResponse(500, $query . "..........." .$DondeEntra , $e->getMessage(), $response);
    }
});

?>