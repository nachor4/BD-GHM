<?php
	include_once ("{$_SERVER['DOCUMENT_ROOT']}/api/dbConn.php");   

	if (!$pdo){
		echo '{"error":'.json_encode("CHAN! No pudo entrar en la BD :s").'}';
		exit;
	}	 
	
	switch ($_SERVER['REQUEST_METHOD']){
		case 'GET':
			//Obtener Todas las consultas y Respuestas del anuncio pasado por GET
			/*
				[
					{
						consulta:texto,
						respueta:
							[
								{respuesta:texto,usuario:usuario_usuario}
							]
					}
				]
			*/
			
			if(!empty($_GET['anuncio']))
				$ok = $pdo->query("SELECT id, texto FROM consulta WHERE anuncio_codigo = {$_GET['anuncio']}");
			else
				$ok = FALSE;
			
			if($ok){
				if ($ok->rowCount()>0){
					$init = TRUE;
					echo '[';
					while($row = $ok->fetch(PDO::FETCH_ASSOC)){
						if (!$init) echo ',';
						else $init = FALSE;
						echo '{"Consulta":'.json_encode($row['texto']).', "respuestas":';
						//busco las respuestas
							$respuestas = $pdo->query("SELECT usuario_usuario AS usuario, texto AS respuesta FROM respuesta WHERE consulta_id = {$row['id']}");
							if ($ok && $respuestas->rowCount()>0){
								$initRta = TRUE;
								echo '[';
								while($rowRta = $respuestas->fetch(PDO::FETCH_ASSOC)){
									if (!$initRta) echo ',';
									else $initRta = FALSE;
									echo json_encode($rowRta);
								}
								echo ']';	
							}else{
								echo json_encode("No hay respuespuestas a esta consulta.");
							}
							
						echo '}';
					}
					echo ']';	
				}else{
					echo '{"mensaje":'.json_encode("CARAMBA! A nadie le interesa ese inmueble, No tiene consultas :/").'}';
				}
			}else{
				echo '{"error":'.json_encode("CARAMBA! No se pudo hacer la consulta :/").'}';
			}
			
		break;
	
		default:
			echo '{"error":'.json_encode("{$_SERVER['REQUEST_METHOD']} Not Allowed").'}';
		break;
	}
?>