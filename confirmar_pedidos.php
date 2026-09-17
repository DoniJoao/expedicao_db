<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 1. Recebe e valida o payload
$dados_brutos = file_get_contents("php://input");
$data = json_decode($dados_brutos, true);

if (!$data || !isset($data['pedido_id']) || !isset($data['volumes']) || !isset($data['itens'])) {
    http_response_code(400);
    echo json_encode([
        "sucesso" => false,
        "mensagem" => "Dados de conferência inválidos ou incompletos."
    ]);
    exit;
}

$pedido_id = intval($data['pedido_id']);
$volumes   = intval($data['volumes']);
$itens     = $data['itens'];

if (!is_array($itens) || count($itens) === 0) {
    http_response_code(400);
    echo json_encode([
        "sucesso" => false,
        "mensagem" => "Nenhum item foi enviado para conferência."
    ]);
    exit;
}

// 2. Conexão
$host = "localhost";
$db_name = "expedicao_db";
$username = "root";
$password = "";

try {
    $pdo = new PDO(
        "mysql:host=$host;dbname=$db_name;charset=utf8mb4",
        $username,
        $password
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 3. Verifica se o pedido existe e ainda não foi separado
    $stmtCheck = $pdo->prepare("SELECT id, separado FROM pedidos WHERE id = :id");
    $stmtCheck->execute([':id' => $pedido_id]);
    $pedido = $stmtCheck->fetch(PDO::FETCH_ASSOC);

    if (!$pedido) {
        http_response_code(404);
        echo json_encode([
            "sucesso" => false,
            "mensagem" => "Pedido #$pedido_id não encontrado."
        ]);
        exit;
    }

    if ((int)$pedido['separado'] === 1) {
        http_response_code(409);
        echo json_encode([
            "sucesso" => false,
            "mensagem" => "Pedido #$pedido_id já foi confirmado anteriormente."
        ]);
        exit;
    }

    // 4. Transação
    $pdo->beginTransaction();

    // 4.1 Atualiza o status do pedido
    $stmtPedido = $pdo->prepare(
        "UPDATE pedidos 
         SET separado = 1, volumes_finais = :volumes 
         WHERE id = :id"
    );
    $stmtPedido->execute([
        ':volumes' => $volumes,
        ':id'      => $pedido_id
    ]);

    // 4.2 Prepara statements dos itens (fora do loop, dentro da transação)
    $stmtItem = $pdo->prepare(
        "UPDATE itens_pedido 
         SET qtd_conferida = :qtd 
         WHERE pedido_id = :pedido_id 
           AND codigo_produto = :codigo 
           AND lote = :lote"
    );

    $stmtEstoque = $pdo->prepare(
        "UPDATE estoque_lotes 
         SET saldo = saldo - :qtd 
         WHERE codigo_produto = :codigo 
           AND lote = :lote"
    );

    $itensProcessados = 0;

    foreach ($itens as $item) {
        if (!isset($item['codigo']) || !isset($item['lote']) || !isset($item['qtd_coletada'])) {
            throw new Exception("Item com formato inválido: " . json_encode($item));
        }

        $qtd = intval($item['qtd_coletada']);

        if ($qtd <= 0) {
            continue; // ignora itens sem coleta
        }

        // Atualiza a quantidade conferida do item
        $stmtItem->execute([
            ':qtd'        => $qtd,
            ':pedido_id'  => $pedido_id,
            ':codigo'     => $item['codigo'],
            ':lote'       => $item['lote']
        ]);

        // Abate do estoque
        $stmtEstoque->execute([
            ':qtd'    => $qtd,
            ':codigo' => $item['codigo'],
            ':lote'   => $item['lote']
        ]);

        $itensProcessados++;
    }

    if ($itensProcessados === 0) {
        throw new Exception("Nenhum item tinha quantidade coletada maior que zero.");
    }

    $pdo->commit();

    echo json_encode([
        "sucesso"  => true,
        "mensagem" => "Pedido #$pedido_id confirmado. $itensProcessados item(ns) processado(s). $volumes volume(s) registrado(s)."
    ]);

} catch (Exception $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }

    http_response_code(500);
    echo json_encode([
        "sucesso"  => false,
        "mensagem" => "Erro ao confirmar pedido: " . $e->getMessage()
    ]);
}