-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Tempo de geração: 22/09/2026 às 20:48
-- Versão do servidor: 8.4.7
-- Versão do PHP: 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `expedicao_db`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `coletas`
--

DROP TABLE IF EXISTS `coletas`;
CREATE TABLE IF NOT EXISTS `coletas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pedido_id` int NOT NULL,
  `tipo` enum('coleta','entrega') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'coleta',
  `nome` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `documento` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `placa_veiculo` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `motorista_id` int DEFAULT NULL,
  `assinatura` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_coletas_pedidos` (`pedido_id`),
  KEY `fk_coletas_motorista` (`motorista_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `coletas`
--

INSERT INTO `coletas` (`id`, `pedido_id`, `tipo`, `nome`, `documento`, `placa_veiculo`, `motorista_id`, `assinatura`, `created_at`) VALUES
(1, 1, 'coleta', 'Carlos Silva', '12345678900', 'ABC1D23', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANS...', '2026-09-22 20:42:06');

-- --------------------------------------------------------

--
-- Estrutura para tabela `estoque_lotes`
--

DROP TABLE IF EXISTS `estoque_lotes`;
CREATE TABLE IF NOT EXISTS `estoque_lotes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `codigo_produto` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `lote` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `saldo` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `codigo_produto` (`codigo_produto`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `estoque_lotes`
--

INSERT INTO `estoque_lotes` (`id`, `codigo_produto`, `lote`, `saldo`) VALUES
(1, 'VNT-40', 'LOTE-26D133', 10),
(2, 'VNT-40', 'LOTE-27A456', 8),
(3, 'VNT-40', 'LOTE-28B789', 5),
(4, 'AQ-200', 'LOTE-25D3851', 5),
(5, 'AQ-200', 'LOTE-26C111', 12),
(6, 'EX-300', 'LOTE-26E001', 7),
(7, 'FAN-500', 'LOTE-26F001', 4),
(8, 'FAN-500', 'LOTE-26F002', 3);

-- --------------------------------------------------------

--
-- Estrutura para tabela `itens_pedido`
--

DROP TABLE IF EXISTS `itens_pedido`;
CREATE TABLE IF NOT EXISTS `itens_pedido` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pedido_id` int NOT NULL,
  `codigo_produto` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `lote` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qtd_solicitada` int NOT NULL DEFAULT '0',
  `qtd_conferida` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `pedido_id` (`pedido_id`),
  KEY `codigo_produto` (`codigo_produto`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `itens_pedido`
--

INSERT INTO `itens_pedido` (`id`, `pedido_id`, `codigo_produto`, `lote`, `qtd_solicitada`, `qtd_conferida`) VALUES
(1, 1, 'VNT-40', 'LOTE-26D133', 3, 3),
(2, 1, 'AQ-200', 'LOTE-25D3851', 1, 1),
(3, 2, 'VNT-40', 'LOTE-26D133', 5, 0),
(4, 3, 'EX-300', 'LOTE-26E001', 4, 0),
(5, 4, 'VNT-40', 'LOTE-26D133', 12, 0),
(6, 5, 'VNT-40', 'LOTE-26D133', 30, 0),
(7, 6, 'AQ-200', 'LOTE-25D3851', 1, 0);

-- --------------------------------------------------------

--
-- Estrutura para tabela `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
CREATE TABLE IF NOT EXISTS `pedidos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `transportadora_id` int DEFAULT NULL,
  `separado` tinyint(1) DEFAULT '0',
  `volumes_finais` int DEFAULT '0',
  `data_criacao` datetime DEFAULT CURRENT_TIMESTAMP,
  `coletado` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_pedido_transportadora` (`transportadora_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `pedidos`
--

INSERT INTO `pedidos` (`id`, `cliente`, `transportadora_id`, `separado`, `volumes_finais`, `data_criacao`, `coletado`) VALUES
(1, 'Indústria de Alimentos Jampac', 1, 1, 2, '2026-09-21 15:01:50', 1),
(2, 'Metalúrgica Silva', 2, 0, 0, '2026-09-21 15:01:50', 0),
(3, 'Distribuidora Central', 3, 0, 0, '2026-09-21 15:01:50', 0),
(4, 'Móveis Planejados Oliveira', 1, 0, 0, '2026-09-21 15:01:50', 0),
(5, 'Papelaria Estrela', 2, 0, 0, '2026-09-21 15:01:50', 0),
(6, 'Comércio de Bebidas Norte', 3, 1, 2, '2026-09-21 15:01:50', 0);

-- --------------------------------------------------------

--
-- Estrutura para tabela `produtos`
--

DROP TABLE IF EXISTS `produtos`;
CREATE TABLE IF NOT EXISTS `produtos` (
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `localizacao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `produtos`
--

INSERT INTO `produtos` (`codigo`, `nome`, `descricao`, `localizacao`) VALUES
('AQ-200', 'Aquecedor 20 centímetros', 'Aquecedor 20 centímetros', 'Corredor A, Prat. 2'),
('EX-300', 'Exaustor 30 centímetros', 'Exaustor 30 centímetros', 'Corredor B, Prat. 1'),
('FAN-500', 'Ventilador de Teto 50cm', 'Ventilador de Teto 50cm', 'Corredor B, Prat. 2'),
('VNT-40', 'Ventilador Industrial 40cm', 'Ventilador Industrial 40cm', 'Corredor A, Prat. 1');

-- --------------------------------------------------------

--
-- Estrutura para tabela `transportadoras`
--

DROP TABLE IF EXISTS `transportadoras`;
CREATE TABLE IF NOT EXISTS `transportadoras` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cnpj` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endereco` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cnpj_unico` (`cnpj`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `transportadoras`
--

INSERT INTO `transportadoras` (`id`, `nome`, `cnpj`, `endereco`, `ativo`, `created_at`) VALUES
(1, 'Transportadora Padrão', NULL, NULL, 1, '2026-09-21 18:01:50'),
(2, 'Log Express', '12.345.678/0001-90', 'Av. das Rotas, 100 - São Paulo/SP', 1, '2026-09-21 18:01:50'),
(3, 'Rápido Sul', '98.765.432/0001-10', 'Rua do Frete, 500 - Curitiba/PR', 1, '2026-09-21 18:01:50');

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `funcao` enum('administrador','vendedor','expedicao','motorista') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_unico` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `usuarios`
--

INSERT INTO `usuarios` (`id`, `nome`, `email`, `senha`, `funcao`) VALUES
(1, 'Admin', 'admin@teste.com', '$2y$10$hQCi5W8v5VgPyfayLMWlGuEMs66xDV1Ijw0CUa1iRj0/zLPitavJu', 'administrador'),
(2, 'Vendedor João', 'vendas@teste.com', '$2y$10$hQCi5W8v5VgPyfayLMWlGuEMs66xDV1Ijw0CUa1iRj0/zLPitavJu', 'vendedor'),
(3, 'Separador Pedro', 'expedicao@teste.com', '$2y$10$hQCi5W8v5VgPyfayLMWlGuEMs66xDV1Ijw0CUa1iRj0/zLPitavJu', 'expedicao'),
(4, 'Motorista Carlos', 'motorista@teste.com', '$2y$10$hQCi5W8v5VgPyfayLMWlGuEMs66xDV1Ijw0CUa1iRj0/zLPitavJu', 'motorista');

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `coletas`
--
ALTER TABLE `coletas`
  ADD CONSTRAINT `fk_coletas_motorista` FOREIGN KEY (`motorista_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_coletas_pedidos` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `estoque_lotes`
--
ALTER TABLE `estoque_lotes`
  ADD CONSTRAINT `fk_estoque_produto` FOREIGN KEY (`codigo_produto`) REFERENCES `produtos` (`codigo`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Restrições para tabelas `itens_pedido`
--
ALTER TABLE `itens_pedido`
  ADD CONSTRAINT `fk_item_pedido` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_item_produto` FOREIGN KEY (`codigo_produto`) REFERENCES `produtos` (`codigo`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Restrições para tabelas `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `fk_pedido_transportadora` FOREIGN KEY (`transportadora_id`) REFERENCES `transportadoras` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
