-- ============================================================================
-- Schema para o Painel de Venda de Anões (bolt_pedselector)
-- Compatível com: MariaDB / MySQL
-- Ferramenta: HeidiSQL (ou similar)
-- Autor: Bolt
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tabela `dwarfs`
-- Armazena os detalhes de cada anão disponível para compra.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `dwarfs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL COMMENT 'Nome de exibição do anão (ex: Anão Mineiro)',
    `model` VARCHAR(100) NOT NULL UNIQUE COMMENT 'Nome do modelo de spawn do ped',
    `image_url` VARCHAR(512) NULL COMMENT 'URL da imagem para exibição no painel',
    `price` INT NOT NULL DEFAULT 0 COMMENT 'Preço em "coins" para comprar o anão',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) COMMENT='Tabela de anões disponíveis para venda.';

-- ----------------------------------------------------------------------------
-- Tabela `player_dwarfs`
-- Associa os jogadores aos anões que eles compraram.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `player_dwarfs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_identifier` VARCHAR(100) NOT NULL COMMENT 'Identificador único do jogador (ex: license:...)',
    `dwarf_id` INT NOT NULL COMMENT 'ID do anão comprado, da tabela dwarfs',
    `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Garante que um jogador não pode comprar o mesmo anão duas vezes
    UNIQUE KEY `unique_purchase` (`player_identifier`, `dwarf_id`),

    -- Chave estrangeira para garantir a integridade dos dados
    FOREIGN KEY (`dwarf_id`) REFERENCES `dwarfs`(`id`) ON DELETE CASCADE
) COMMENT='Registro de compras de anões pelos jogadores.';

-- ----------------------------------------------------------------------------
-- Índices
-- Otimiza as buscas na tabela `player_dwarfs`.
-- ----------------------------------------------------------------------------
CREATE INDEX `idx_player_identifier` ON `player_dwarfs`(`player_identifier`);


-- ============================================================================
-- INSERTS DE EXEMPLO
-- Execute esta seção para adicionar alguns anões ao seu painel.
-- Você pode alterar os valores ou adicionar mais linhas conforme necessário.
-- ============================================================================
INSERT INTO `dwarfs` (`name`, `model`, `image_url`, `price`) VALUES
('Anão de Rua', 'g_m_y_strpunk_01', 'https://i.imgur.com/tGfUa2s.png', 5000),
('Anão Fazendeiro', 'a_m_m_farmer_01', 'https://i.imgur.com/yG2A2O5.png', 7500),
('Anão Empresário', 'a_m_y_business_02', 'https://i.imgur.com/QZ3L1zW.png', 12000),
('Anão Hipster', 'a_m_y_hipster_01', 'https://i.imgur.com/rV8b9zY.png', 15000),
('Anão Lenhador', 'a_m_m_prolsec_01', 'https://i.imgur.com/O8J3fGk.png', 10000),
('Anão Corredor', 'a_m_y_runner_01', 'https://i.imgur.com/sW4tE8x.png', 11000);
