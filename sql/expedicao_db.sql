-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Tempo de geração: 14/09/2026 às 20:55
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
  `nome` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `documento` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `placa_veiculo` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `assinatura` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_coletas_pedidos` (`pedido_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `estoque_lotes`
--

INSERT INTO `estoque_lotes` (`id`, `codigo_produto`, `lote`, `saldo`) VALUES
(1, 'VNT-40', 'LOTE-26D133', 10),
(2, 'AQ-200', 'LOTE-25D3851', 5);

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `itens_pedido`
--

INSERT INTO `itens_pedido` (`id`, `pedido_id`, `codigo_produto`, `lote`, `qtd_solicitada`, `qtd_conferida`) VALUES
(1, 1, 'VNT-40', 'LOTE-26D133', 3, 0),
(2, 1, 'AQ-200', 'LOTE-25D3851', 1, 0);

-- --------------------------------------------------------

--
-- Estrutura para tabela `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
CREATE TABLE IF NOT EXISTS `pedidos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `separado` tinyint(1) DEFAULT '0',
  `volumes_finais` int DEFAULT '0',
  `data_criacao` datetime DEFAULT CURRENT_TIMESTAMP,
  `coletado` tinyint(1) DEFAULT '0'
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `pedidos`
--

INSERT INTO `pedidos` (`id`, `cliente`, `separado`, `volumes_finais`, `data_criacao`, `coletado`, `volumes`) VALUES
(1, 'Indústria de Alimentos Jampac', 0, 0, '2026-09-11 09:40:08', 0, 0);

-- --------------------------------------------------------

--
-- Estrutura para tabela `produtos`
--

DROP TABLE IF EXISTS `produtos`;
CREATE TABLE IF NOT EXISTS `produtos` (
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `produtos`
--

INSERT INTO `produtos` (`codigo`, `nome`, `descricao`) VALUES
('AQ-200', 'Aquecedor 20 centimetros', 'Aquecedor 20 centimetros'),
('EX-300', 'Exaustor 30 centimetros', 'Exaustor 30 centimetros'),
('VNT-40', 'Ventilador Industrial 40cm', 'Ventilador Industrial 40cm');

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
