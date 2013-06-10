<?php
/*
	echo "[";
	echo json_encode($_SERVER);	
	echo ',';

	switch ($_SERVER['REQUEST_METHOD']){
		case 'POST':
			echo json_encode($_POST);
		break;

		case 'GET':
			echo json_encode($_GET);	
		break;

		case 'PUT':
			parse_str(file_get_contents("php://input", "r"),$_PUT);
			echo json_encode(@$_PUT);	
		break;
		
		case 'DELETE':
			parse_str(file_get_contents("php://input", "r"),$_DELETE);
			echo json_encode(@$_DELETE);			
		break;
		
		default:
			echo '{"error":'.json_encode("{$_SERVER['REQUEST_METHOD']} Not Allowed").'}';
		break;
	}
	echo "]";
*/
?>