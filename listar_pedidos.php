<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

$host = "localhost";
$db_name = "expedicao_db";
$username = "root";
$password = "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db_name;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 1. Busca pedidos + itens + produto + transportadora
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
            WHERE p.separado = 0";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 2. Coleta os códigos únicos de produtos pra buscar lotes de uma vez
    $codigosProdutos = [];
    foreach ($resultados as $row) {
        if ($row['codigo_produto'] != null) {
            $codigosProdutos[$row['codigo_produto']] = true;
        }
    }
    $codigosProdutos = array_keys($codigosProdutos);

    // 3. Busca TODOS os lotes disponíveis desses produtos (multi-lote)
    $lotesPorProduto = [];
    if (count($codigosProdutos) > 0) {
        $placeholders = implode(',', array_fill(0, count($codigosProdutos), '?'));
        $sqlLotes = "SELECT codigo_produto, lote, saldo 
                     FROM estoque_lotes 
                     WHERE codigo_produto IN ($placeholders) 
                       AND saldo > 0
                     ORDER BY codigo_produto, lote";
        $stmtLotes = $pdo->prepare($sqlLotes);
        $stmtLotes->execute($codigosProdutos);

        foreach ($stmtLotes->fetchAll(PDO::FETCH_ASSOC) as $lote) {
            $lotesPorProduto[$lote['codigo_produto']][] = [
                'lote'  => $lote['lote'],
                'saldo' => (int)$lote['saldo']
            ];
        }
    }

    // 4. Agrupa pedidos + itens + lotes disponíveis
    $pedidos = [];

    foreach ($resultados as $row) {
        $id = $row['pedido_id'];

        if (!isset($pedidos[$id])) {
            $pedidos[$id] = [
                "id"              => (int)$id,
                "cliente"         => $row['cliente'],
                "data_criacao"    => $row['data_criacao'],
                "volumes_finais"  => (int)$row['volumes_finais'],
                "transportadora"  => $row['transportadora_nome'] ?? 'Padrão',
                "itens"           => []
            ];
        }

        if ($row['codigo_produto'] != null) {
            $codigo = $row['codigo_produto'];

            $pedidos[$id]['itens'][] = [
                "codigo"           => $codigo,
                "nome"             => $row['produto_nome'],
                "localizacao"      => $row['produto_localizacao'],
                "lote"             => $row['lote'],
                "qtd_solicitada"   => (int)$row['qtd_solicitada'],
                "qtd_conferida"    => (int)$row['qtd_conferida'],
                "lotes_disponiveis" => $lotesPorProduto[$codigo] ?? []
            ];
        }
    }

    echo json_encode(array_values($pedidos));

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "erro" => "Erro ao listar pedidos: " . $e->getMessage()
    ]);
}