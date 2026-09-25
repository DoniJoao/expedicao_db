<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// -------- Parâmetros opcionais --------
$limite = isset($_GET['limite']) ? max(1, min(500, intval($_GET['limite']))) : 500;
$offset = isset($_GET['offset']) ? max(0, intval($_GET['offset'])) : 0;
$busca  = isset($_GET['busca'])  ? trim($_GET['busca']) : '';

// Se busca vier preenchida, filtra por id ou cliente
$filtroBusca = '';
$params = [];

if ($busca !== '') {
    if (ctype_digit($busca)) {
        // Busca numérica: casa com id OU parte do nome do cliente
        $filtroBusca = " AND (p.id = :busca_id OR p.cliente LIKE :busca_nome)";
        $params[':busca_id'] = intval($busca);
        $params[':busca_nome'] = '%' . $busca . '%';
    } else {
        // Busca textual: só por cliente
        $filtroBusca = " AND p.cliente LIKE :busca_nome";
        $params[':busca_nome'] = '%' . $busca . '%';
    }
}

$host = "localhost";
$db_name = "expedicao_db";
$username = "root";
$password = "";

$limite = isset($_GET['limite']) ? max(1, min(500, intval($_GET['limite']))) : 500;
$offset = isset($_GET['offset']) ? max(0, intval($_GET['offset'])) : 0;

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db_name;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // -------- Conta o total (pra paginação saber se tem mais) --------
    $sqlCount = "SELECT COUNT(DISTINCT p.id) AS total
                 FROM pedidos p
                 WHERE p.separado = 1 AND p.coletado = 0
                 $filtroBusca";
    $stmtCount = $pdo->prepare($sqlCount);
    $stmtCount->execute($params);
    $total = (int)$stmtCount->fetch(PDO::FETCH_ASSOC)['total'];

    // -------- Busca os pedidos paginados --------
    $sql = "SELECT
                p.id AS pedido_id,
                p.cliente,
                p.data_criacao,
                p.volumes_finais,
                t.nome AS transportadora_nome,
                i.codigo_produto,
                pr.nome AS produto_nome,
                pr.localizacao AS produto_localizacao,
                i.lote,
                i.qtd_solicitada,
                i.qtd_conferida
            FROM pedidos p
            LEFT JOIN transportadoras t ON p.transportadora_id = t.id
            LEFT JOIN itens_pedido i ON p.id = i.pedido_id
            LEFT JOIN produtos pr ON i.codigo_produto = pr.codigo
            WHERE p.separado = 0 AND p.coletado = 0
            $filtroBusca
            ORDER BY p.id
            LIMIT $limite OFFSET $offset";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $pedidos = [];
    foreach ($resultados as $row) {
        $id = $row['pedido_id'];

        if (!isset($pedidos[$id])) {
            $pedidos[$id] = [
                "id"             => (int)$id,
                "cliente"        => $row['cliente'],
                "data_criacao"   => $row['data_criacao'],
                "volumes_finais" => (int)$row['volumes_finais'],
                "transportadora" => $row['transportadora_nome'] ?? 'Padrão',
                "itens"          => []
            ];
        }

        if ($row['codigo_produto'] != null) {
            $pedidos[$id]['itens'][] = [
                "codigo"          => $row['codigo_produto'],
                "nome"            => $row['produto_nome'],
                "localizacao"     => $row['produto_localizacao'],
                "lote"            => $row['lote'],
                "qtd_solicitada"  => (int)$row['qtd_solicitada'],
                "qtd_conferida"   => (int)$row['qtd_conferida']
            ];
        }
    }

    // -------- Metadados de paginação --------
    // Mantém compatibilidade: a resposta continua sendo um array puro.
    // Os metadados vão em headers, não no corpo.
    header('X-Total-Count: ' . $total);
    header('X-Page-Limit: ' . $limite);
    header('X-Page-Offset: ' . $offset);

    echo json_encode(array_values($pedidos));

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["erro" => "Erro ao listar coletas: " . $e->getMessage()]);
}