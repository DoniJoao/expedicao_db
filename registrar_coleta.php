<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

$dados_brutos = file_get_contents("php://input");
$data = json_decode($dados_brutos, true);

// Validação do payload
if (!$data
    || !isset($data['pedido_id'])
    || !isset($data['nome'])
    || !isset($data['documento'])
    || !isset($data['placa_veiculo'])) {
    http_response_code(400);
    echo json_encode([
        "sucesso" => false,
        "mensagem" => "Dados incompletos. Informe pedido_id, nome, documento e placa_veiculo."
    ]);
    exit;
}

$pedido_id  = intval($data['pedido_id']);
$nome       = trim($data['nome']);
$documento  = trim($data['documento']);
$placa      = strtoupper(trim($data['placa_veiculo']));
$assinatura = $data['assinatura'] ?? null; // base64 opcional

if ($nome === '' || $documento === '' || $placa === '') {
    http_response_code(400);
    echo json_encode([
        "sucesso" => false,
        "mensagem" => "Nome, documento e placa não podem estar vazios."
    ]);
    exit;
}

$host = "localhost";
$db_name = "expedicao_db";
$username = "root";
$password = "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db_name;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 1. Verifica o pedido
    $stmtCheck = $pdo->prepare("SELECT id, separado, coletado FROM pedidos WHERE id = :id");
    $stmtCheck->execute([':id' => $pedido_id]);
    $pedido = $stmtCheck->fetch(PDO::FETCH_ASSOC);

    if (!$pedido) {
        http_response_code(404);
        echo json_encode(["sucesso" => false, "mensagem" => "Pedido #$pedido_id não encontrado."]);
        exit;
    }

    if ((int)$pedido['separado'] !== 1) {
        http_response_code(409);
        echo json_encode([
            "sucesso" => false,
            "mensagem" => "Pedido #$pedido_id ainda não foi separado. Não pode ser coletado."
        ]);
        exit;
    }

    if ((int)$pedido['coletado'] === 1) {
        http_response_code(409);
        echo json_encode([
            "sucesso" => false,
            "mensagem" => "Pedido #$pedido_id já foi coletado anteriormente."
        ]);
        exit;
    }

    // 2. Transação
    $pdo->beginTransaction();

    // 2.1 Registra a coleta
    $stmtColeta = $pdo->prepare(
        "INSERT INTO coletas (pedido_id, tipo, nome, documento, placa_veiculo, assinatura)
         VALUES (:pedido_id, 'coleta', :nome, :documento, :placa, :assinatura)"
    );
    $stmtColeta->execute([
        ':pedido_id'   => $pedido_id,
        ':nome'        => $nome,
        ':documento'   => $documento,
        ':placa'       => $placa,
        ':assinatura'  => $assinatura
    ]);

    // 2.2 Marca o pedido como coletado
    $stmtPedido = $pdo->prepare("UPDATE pedidos SET coletado = 1 WHERE id = :id");
    $stmtPedido->execute([':id' => $pedido_id]);

    $pdo->commit();

    echo json_encode([
        "sucesso"  => true,
        "mensagem" => "Coleta do pedido #$pedido_id registrada com sucesso."
    ]);

} catch (Exception $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    http_response_code(500);
    echo json_encode([
        "sucesso"  => false,
        "mensagem" => "Erro ao registrar coleta: " . $e->getMessage()
    ]);
}