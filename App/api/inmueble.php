<?php
	include_once ("{$_SERVER['DOCUMENT_ROOT']}/api/dbConn.php");   

	if (!$pdo){
		echo '{"error":'.json_encode("CHAN! No pudo entrar en la BD :s").'}';
		exit;
	}	
	
	switch ($_SERVER['REQUEST_METHOD']){
		case 'POST':
			//Guardar los Inmuebles
			if (!empty($_POST['tipo'])) $_POST['tipo'] = strtolower($_POST['tipo']);
			
			if (preg_match("/[casa|departamento]/", $_POST['tipo'])){
				$pdo->beginTransaction();
				
				//insertar el inmueble y Obtener el ID insertado
				$sql = "INSERT INTO inmueble (direccion, m2) ";
				$sql .= "VALUES('{$_POST['direccion']}',{$_POST['m2']})";
				
				$ok = $pdo->query($sql);
				
				if ($ok){
					$newInmueble = $pdo->lastInsertId();
					
					switch ($_POST['tipo']){
						case 'casa':
							//Agregar la casa
							$sql = "INSERT INTO casa (inmueble_id, cantidad_habitaciones, categoria_id) ";
							$sql .= "VALUES({$newInmueble},{$_POST['habitaciones']},{$_POST['categoria']})";
							$ok = $pdo->query($sql);							
						break;
						
						case 'departamento':
							//Agregar el departamento
							$sql = "INSERT INTO departamento (inmueble_id, expensas) ";
							$sql .= "VALUES({$newInmueble},{$_POST['expensas']})";
							$ok = $pdo->query($sql);
						break;
					}
				}
				
				//Commit || Rollback
				if ($ok){
					$ok = $pdo->commit();
					//Mostrar Mensaje
					if ($ok){ 
						echo '{"OK":'.json_encode("ENHORABUENA! Se agrego el inmueble (y no sabes el trabajo que me dio!) ;)").'}';
					}else{
						echo '{"error":'.json_encode("RECORCHOLIS! Todo estaba bien pero en el Commit algo paso :s").'}';
					}
				}
				else{
					$ok = $pdo->rollback();
					if ($ok){ 
						echo '{"error":'.json_encode("CARAMBOLAS! Algo paso y no pudimos agregar el Inmueble pero hicimos un Rollback y todo volvio a la normalidad :D").'}';
					}else{
						echo '{"error":'.json_encode("HORROR!!! No pudimos cargar el inmueble y tampoco hacer el Rollback. Llama YA al Administrador!").'}';
					}
				}
				
			}else{
				echo '{"error":'.json_encode("CARAMBOLAS! Estas tratando de agregar un inmueble que no existe!").'}';
			}

		break;

		case 'DELETE':
			parse_str(file_get_contents("php://input", "r"),$_DELETE);
			//Eliminar el Inmueble
			
			if(empty($_DELETE['inmueble'])){
				echo '{"error":'.json_encode("CHAN! Estas tratando de eliminar vacio! (No se recibieron datos) :s").'}';
				break;
			}
			
			$ok = $pdo->query("DELETE FROM inmueble WHERE id={$_DELETE['inmueble']}");

			if($ok && $ok->rowCount()>0){
				echo '{"OK":'.json_encode("ENHORABUENA! Se elimino el Inmueble que pediste. ;)").'}';
			}else{
				echo '{"error":'.json_encode("MATANGA! No se elimino NADA! (ID no válido o error con la BD)").'}';
			}
		break;
		
		case 'GET':
			//Obtener la lista de TODOS los inmuebles

			$ok = $pdo->query("SELECT id, CONCAT(id,': ',direccion) AS nombre FROM inmueble");
			
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