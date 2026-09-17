<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

$host = "localhost";
$db_name = "expedicao_db";
$username = "root";
$password = "";

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['email']) || !isset($data['senha'])) {
    http_response_code(400);
    echo json_encode(["sucesso" => false, "mensagem" => "E-mail e senha são obrigatórios."]);
    exit;
}

try {
    $pdo = new PDO("mysql:host=" . $host . ";dbname=" . $db_name, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $sql = "SELECT id, nome, email, senha, funcao FROM usuarios WHERE email = :email";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([':email' => $data['email']]);

    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($usuario && password_verify($data['senha'], $usuario['senha'])) {
        unset($usuario['senha']); 
        
        echo json_encode([
            "sucesso" => true,
            "mensagem" => "Login realizado com sucesso.",
            "usuario" => $usuario 
        ]);
    } else {
        http_response_code(401);
        echo json_encode(["sucesso" => false, "mensagem" => "E-mail ou senha incorretos."]);
    }

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["sucesso" => false, "mensagem" => "Erro no servidor: " . $e->getMessage()]);
}
?>