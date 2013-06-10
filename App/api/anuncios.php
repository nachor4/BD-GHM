<?php
	include_once ("{$_SERVER['DOCUMENT_ROOT']}/api/dbConn.php");   

	if (!$pdo){
		echo '{"error":'.json_encode("CHAN! No pudo entrar en la BD :s").'}';
		exit;
	}	
	
	switch ($_SERVER['REQUEST_METHOD']){
		case 'GET':
			//Obtener TODOS los anuncios
			$ok = $pdo->query('SELECT codigo AS id, CONCAT("Anuncio: ",codigo," (Inmueble: ",inmueble_id,")") AS nombre FROM anuncio');
			
			if($ok){
				$init = TRUE;
				echo '[';
				while($row = $ok->fetch(PDO::FETCH_ASSOC)){
					if (!$init) echo ',';
					else $init = FALSE;
					echo json_encode($row);
				}
				echo ']';	
			}else{
				echo '{"error":'.json_encode("Ups... no había data :/").'}';
			}					
		break;
	
		default:
			echo '{"error":'.json_encode("{$_SERVER['REQUEST_METHOD']} Not Allowed").'}';
		break;
	}
?>