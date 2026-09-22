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

    // Pedidos separados (separado=1) e ainda não coletados (coletado=0)
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
            WHERE p.separado = 1 AND p.coletado = 0
            ORDER BY p.id";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();
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

    echo json_encode(array_values($pedidos));

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["erro" => "Erro ao listar coletas: " . $e->getMessage()]);
}