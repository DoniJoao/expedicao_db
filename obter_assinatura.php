<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

$coleta_id = isset($_GET['id']) ? intval($_GET['id']) : 0;

if ($coleta_id <= 0) {
    http_response_code(400);
    echo json_encode(["sucesso" => false, "mensagem" => "ID da coleta não informado."]);
    exit;
}

$host = "localhost";
$db_name = "expedicao_db";
$username = "root";
$password = "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db_name;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->prepare("SELECT id, assinatura FROM coletas WHERE id = :id");
    $stmt->execute([':id' => $coleta_id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        http_response_code(404);
        echo json_encode(["sucesso" => false, "mensagem" => "Coleta não encontrada."]);
        exit;
    }

    echo json_encode([
        "sucesso" => true,
        "assinatura" => $row['assinatura']
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["sucesso" => false, "mensagem" => "Erro: " . $e->getMessage()]);
}