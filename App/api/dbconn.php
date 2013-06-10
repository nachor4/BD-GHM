<?php
    $dbConn = array (
        'dbName' => 'proyecto_ghm',
        'dbHost' => 'localhost',
        'dbPort' => 3306,
        'dbUser' => 'root',
        'dbPass' => ''
    );
	
	$pdo = new PDO(
		"mysql:host={$dbConn['dbHost']};dbname={$dbConn['dbName']};". (($dbConn['dbPort'] != '')?"port={$dbConn['dbPort']}":"") ."charset=utf8", 
		$dbConn['dbUser'],
		$dbConn['dbPass']
	);			

?>