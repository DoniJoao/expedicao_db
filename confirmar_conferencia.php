<?php
// Permite requisições de outras origens e define a resposta como JSON
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// 1. Recebe os dados JSON brutos enviados pelo Flutter
$dados_brutos = file_get_contents("php://input");
$data = json_decode($dados_brutos, true);

// Validação basica para garantir que o payload chegou correto
if (!$data || !isset($data['pedido_id']) || !isset($data['volumes']) || !isset($data['itens'])) {
    echo json_encode([
        "sucesso" => false,
        "mensagem" => "Dados de conferência inválidos ou incompletos."
    ]);
    exit;
}

$pedido_id = $data['pedido_id'];
$volumes = intval($data['volumes']);
$itens = $data['itens'];

// 2. Configurações da Conexão com o Banco de Dados (Ajuste se necessário)
$host = "localhost";
$db_name = "expedicao_db";
$username = "root";
$password = ""; // Insira a senha do MySQL se houver

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db_name;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Inicia uma transação para garantir que tudo seja salvo ou nada seja alterado em caso de falha
    $pdo->beginTransaction();

    // 3. Atualiza o status e volumes na tabela de pedidos
    // (Ajuste os nomes da tabela e colunas de acordo com a sua estrutura)
    $stmtPedido = $pdo->prepare("UPDATE pedidos SET volumes = :volumes, status = 'CONFERIDO' WHERE id = :id");
    $stmtPedido->execute([
        ':volumes' => $volumes,
        ':id' => $pedido_id
    ]);

    // 4. Salva a conferência individual de cada lote
    // (Caso utilize uma tabela separada para os itens conferidos)
    $stmtItem = $pdo->prepare("INSERT INTO conferencia_itens (pedido_id, codigo_produto, lote, qtd_coletada) VALUES (:pedido_id, :codigo, :lote, :qtd_coletada)");

    foreach ($itens as $item) {
        // Registra apenas os lotes em que houve quantidade coletada
        if (isset($item['qtd_coletada']) && intval($item['qtd_coletada']) > 0) {
            $stmtItem->execute([
                ':pedido_id'    => $pedido_id,
                ':codigo'       => $item['codigo'],
                ':lote'         => $item['lote'],
                ':qtd_coletada' => intval($item['qtd_coletada'])
            ]);
        }
    }

    // Confirma todas as operações no banco de dados
    $pdo->commit();

    // Retorna a resposta de sucesso formatada em JSON
    echo json_encode([
        "sucesso" => true,
        "mensagem" => "Conferência do pedido #{$pedido_id} finalizada com sucesso!"
    ]);

} catch (PDOException $e) {
    // Se ocorrer algum erro no banco de dados, cancela a transação
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }

    echo json_encode([
        "sucesso" => false,
        "mensagem" => "Erro ao salvar no banco de dados: " . $e->getMessage()
    ]);
}
?>