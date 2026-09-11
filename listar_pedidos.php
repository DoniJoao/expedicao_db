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
    $pdo = new PDO("mysql:host=" . $host . ";dbname=" . $db_name . ";charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Busca os pedidos que ainda estão pendentes de separação (separado = 0)
    $sql = "SELECT 
                p.id AS pedido_id, 
                p.cliente, 
                p.data_criacao,
                p.volumes_finais,
                i.codigo_produto,
                pr.nome AS produto_nome,
                i.lote,
                i.qtd_solicitada,
                i.qtd_conferida
            FROM pedidos p
            LEFT JOIN itens_pedido i ON p.id = i.pedido_id
            LEFT JOIN produtos pr ON i.codigo_produto = pr.codigo
            WHERE p.separado = 0"; 

    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $pedidos = [];

    // Agrupa os itens dentro de cada pedido para bater com a estrutura do Flutter
    foreach ($resultados as $row) {
        $id = $row['pedido_id'];

        if (!isset($pedidos[$id])) {
            $pedidos[$id] = [
                "id" => $id, 
                "cliente" => $row['cliente'],
                "data_criacao" => $row['data_criacao'],
                "volumes_finais" => (int)$row['volumes_finais'],
                "itens" => []
            ];
        }

        if ($row['codigo_produto'] != null) {
            $pedidos[$id]['itens'][] = [
                "codigo" => $row['codigo_produto'],
                "nome" => $row['produto_nome'], 
                "lote" => $row['lote'],
                "qtd_solicitada" => (int)$row['qtd_solicitada'],
                "qtd_conferida" => (int)$row['qtd_conferida']
            ];
        }
    }

    // Retorna a lista limpa indexada em array JSON puro
    echo json_encode(array_values($pedidos));

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "erro" => "Erro ao listar pedidos: " . $e->getMessage()
    ]);
}
?>