<?php

$db['hostname'] = 'cs.okstate.edu';
$db['port'] = 3306;
$db['database'] = '4153rgb';
$db['username'] = 'hussach';
$db['password'] = 'pMtCaeL';

$dbh = null;
$result = array('result'=>'success');

function error($message){
	header('Content-Type: application/json');
	echo json_encode(array('result'=>'error', 'message'=>$message));
	die();
}

try {
    $db_conn_str = "mysql:host=" . $db['hostname'] . ";port=" . $db['port'] . ";dbname=" . $db['database'];
	$dbh = new PDO($db_conn_str, $db['username'], $db['password']);
	$dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	$dbh->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
	error("database connection failed!: $e");
}

$action = null;
$method = $_SERVER['REQUEST_METHOD'];
if('GET'===$method && isset($_GET['action'])){
	$action = $_GET['action'];
	if($action==='load'){
		$stmt = $dbh->prepare("SELECT * FROM hp_tasks ORDER BY id ASC");
		$stmt->execute();
  		$rs = $stmt->fetchAll();
  		$result['data'] = $rs;
	}else{
		error("unknown action: $action for GET request");
	}
}else if('POST'===$method && isset($_POST['action'])){
	$action = $_POST['action'];
	if($action==='create'){
		$title = $_POST['title'];
		$subtitle = $_POST['subtitle'];
		$priority = $_POST['priority'];
		$stmt = $dbh->prepare("INSERT INTO hp_tasks(title, subtitle, priority) VALUES(?, ?, ?)");
		$stmt->execute(array($title, $subtitle, $priority));
		$result['data'] = $dbh->lastInsertId('id');
	}else if($action==='updateStatus'){
		$task_id = $_POST['id'];
		$status = $_POST['status'];
		$stmt = $dbh->prepare("UPDATE hp_tasks SET status=? WHERE id=?");
		$stmt->execute(array($status, $task_id));
		$result['data'] = array('id'=> $task_id, 'status'=> $status);
	}else if($action==='delete'){
		$task_id = $_POST['id'];
		$stmt = $dbh->prepare("DELETE FROM hp_tasks WHERE id=?");
		$stmt->execute(array($task_id));
		$result['data'] = array('id'=> $task_id);
	}else{
		error("unknown action: $action for POST request");
	}
}else{
	if(isset($_REQUEST['action'])){
		error("request method: $method does not support");
	}else{
		error("action parameter is required");
	}
}

header('Content-Type: application/json');
$result['action'] = $action;
echo json_encode($result);


