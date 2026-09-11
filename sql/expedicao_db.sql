SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `coletas`;
DROP TABLE IF EXISTS `estoque_lotes`;
DROP TABLE IF EXISTS `itens_pedido`;
DROP TABLE IF EXISTS `pedidos`;
DROP TABLE IF EXISTS `produtos`;
DROP TABLE IF EXISTS `usuarios`;

-- --------------------------------------------------------

CREATE TABLE `produtos` (
  `codigo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `produtos` (`codigo`, `nome`, `descricao`) VALUES
('AQ-200', 'Aquecedor 20 centimetros', 'Aquecedor 20 centimetros'),
('VNT-40', 'Ventilador Industrial 40cm', 'Ventilador Industrial 40cm'),
('EX-300', 'Exaustor 30 centimetros', 'Exaustor 30 centimetros');

-- --------------------------------------------------------

CREATE TABLE `estoque_lotes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `codigo_produto` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lote` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `saldo` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `codigo_produto` (`codigo_produto`),
  CONSTRAINT `fk_estoque_produto` FOREIGN KEY (`codigo_produto`) REFERENCES `produtos` (`codigo`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `estoque_lotes` (`codigo_produto`, `lote`, `saldo`) VALUES
('VNT-40', 'LOTE-26D133', 10),
('AQ-200', 'LOTE-25D3851', 5);

-- --------------------------------------------------------

CREATE TABLE `pedidos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `separado` tinyint(1) DEFAULT '0',
  `volumes_finais` int DEFAULT '0',
  `data_criacao` datetime DEFAULT CURRENT_TIMESTAMP,
  `coletado` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `pedidos` (`cliente`, `separado`, `volumes_finais`, `coletado`) VALUES
('Indústria de Alimentos Jampac', 0, 0, 0);

-- --------------------------------------------------------

CREATE TABLE `itens_pedido` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pedido_id` int NOT NULL,
  `codigo_produto` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lote` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qtd_solicitada` int NOT NULL DEFAULT '0',
  `qtd_conferida` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `pedido_id` (`pedido_id`),
  KEY `codigo_produto` (`codigo_produto`),
  CONSTRAINT `fk_item_pedido` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_item_produto` FOREIGN KEY (`codigo_produto`) REFERENCES `produtos` (`codigo`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `itens_pedido` (`pedido_id`, `codigo_produto`, `lote`, `qtd_solicitada`, `qtd_conferida`) VALUES
(1, 'VNT-40', 'LOTE-26D133', 3, 0),
(1, 'AQ-200', 'LOTE-25D3851', 1, 0);

-- --------------------------------------------------------

CREATE TABLE `coletas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pedido_id` int NOT NULL,
  `nome` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `documento` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `placa_veiculo` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `assinatura` longtext COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_coletas_pedidos` (`pedido_id`),
  CONSTRAINT `fk_coletas_pedidos` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

CREATE TABLE `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `funcao` enum('administrador','vendedor','expedicao','motorista') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_unico` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `usuarios` (`nome`, `email`, `senha`, `funcao`) VALUES
('Admin', 'admin@teste.com', '123456', 'administrador'),
('Vendedor João', 'vendas@teste.com', '123456', 'vendedor'),
('Separador Pedro', 'expedicao@teste.com', '123456', 'expedicao'),
('Motorista Carlos', 'motorista@teste.com', '123456', 'motorista');

SET FOREIGN_KEY_CHECKS = 1;