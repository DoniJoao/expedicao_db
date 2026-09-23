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

        $sql = "SELECT
                c.id              AS coleta_id,
                c.pedido_id,
                c.tipo,
                c.nome,
                c.documento,
                c.placa_veiculo,
                LENGTH(c.assinatura) AS assinatura_tamanho,
                c.created_at,
                p.cliente,
                p.volumes_finais,
                t.nome            AS transportadora_nome
            FROM coletas c
            LEFT JOIN pedidos p ON c.pedido_id = p.id
            LEFT JOIN transportadoras t ON p.transportadora_id = t.id
            WHERE c.tipo = 'coleta'
            ORDER BY c.created_at DESC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $coletas = [];
    foreach ($resultados as $row) {
        $coletas[] = [
            "id"             => (int)$row['coleta_id'],
            "pedido_id"      => (int)$row['pedido_id'],
            "tipo"           => $row['tipo'],
            "cliente"        => $row['cliente'] ?? 'Cliente removido',
            "transportadora" => $row['transportadora_nome'] ?? 'Padrão',
            "volumes_finais" => (int)($row['volumes_finais'] ?? 0),
            "nome"           => $row['nome'],
            "documento"      => $row['documento'],
            "placa_veiculo"  => $row['placa_veiculo'],
            "assinatura_tamanho" => (int)($row['assinatura_tamanho'] ?? 0),
            "created_at"     => $row['created_at']
        ];
    }echo json_encode($coletas);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["erro" => "Erro ao listar coletas feitas: " . $e->getMessage()]);
}