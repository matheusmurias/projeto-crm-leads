-- 0. Usa o database correto
USE crm_leads;

-- 1. Limpa objetos existentes
DROP VIEW IF EXISTS view_atividade_por_usuario;
DROP VIEW IF EXISTS view_leads_sem_interacao;
DROP VIEW IF EXISTS view_interacoes_por_lead;
DROP VIEW IF EXISTS view_leads_por_estagio;

DROP FUNCTION IF EXISTS fn_tempo_em_estagio;
DROP FUNCTION IF EXISTS fn_total_interacoes;
DROP FUNCTION IF EXISTS fn_percentual_conversao;

DROP PROCEDURE IF EXISTS sp_inserir_dados_teste;
DROP PROCEDURE IF EXISTS sp_atualizar_estagios_por_interacao;
DROP PROCEDURE IF EXISTS sp_gerar_relatorio_pipeline;

DROP TRIGGER IF EXISTS trg_validar_transicao_estagio;
DROP TRIGGER IF EXISTS trg_atualiza_timestamp_lead;

-- 2. Cria Views

CREATE VIEW view_leads_por_estagio AS
SELECT
  e.estagio_nome AS estagio,
  COUNT(*)         AS total_leads
FROM `lead` l
JOIN estagio e ON l.lead_estagio_id = e.estagio_id
GROUP BY e.estagio_nome;

CREATE VIEW view_interacoes_por_lead AS
SELECT
  l.lead_id,
  l.lead_nome,
  u.usuario_nome,
  i.interacao_tipo,
  i.interacao_canal,
  i.interacao_data_hora
FROM interacao i
JOIN `lead` l ON i.interacao_lead_id = l.lead_id
JOIN usuario u ON i.interacao_usuario_id = u.usuario_id;

CREATE VIEW view_leads_sem_interacao AS
SELECT
  l.lead_id,
  l.lead_nome,
  l.lead_email
FROM `lead` l
LEFT JOIN interacao i ON l.lead_id = i.interacao_lead_id
WHERE i.interacao_id IS NULL;

CREATE VIEW view_atividade_por_usuario AS
SELECT
  u.usuario_id,
  u.usuario_nome,
  COUNT(i.interacao_id) AS total_interacoes
FROM usuario u
LEFT JOIN interacao i ON u.usuario_id = i.interacao_usuario_id
GROUP BY u.usuario_id, u.usuario_nome;

-- 3. Cria Functions
DELIMITER $$
CREATE FUNCTION fn_tempo_em_estagio(p_lead_id INT)
RETURNS INT DETERMINISTIC
BEGIN
  DECLARE dias INT;
  SELECT DATEDIFF(NOW(), lead_criado_em) INTO dias
    FROM `lead` WHERE lead_id = p_lead_id;
  RETURN dias;
END$$

CREATE FUNCTION fn_total_interacoes(p_lead_id INT)
RETURNS INT DETERMINISTIC
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total
    FROM interacao WHERE interacao_lead_id = p_lead_id;
  RETURN total;
END$$

CREATE FUNCTION fn_percentual_conversao(
  p_estagio_origem INT,
  p_estagio_destino INT
) RETURNS DECIMAL(5,2) DETERMINISTIC
BEGIN
  DECLARE total_origem INT;
  DECLARE total_convertidos INT;
  DECLARE taxa DECIMAL(5,2);
  SELECT COUNT(*) INTO total_origem
    FROM `lead` WHERE lead_estagio_id = p_estagio_origem;
  SELECT COUNT(*) INTO total_convertidos
    FROM `lead` WHERE lead_estagio_id = p_estagio_destino;
  SET taxa = IF(total_origem = 0, 0, (total_convertidos/total_origem)*100);
  RETURN taxa;
END$$
DELIMITER ;

-- 4. Cria Stored Procedures
DELIMITER $$
CREATE PROCEDURE sp_inserir_dados_teste()
BEGIN
  INSERT INTO estagio VALUES
    (1,'Novo'),
    (2,'Contato Realizado'),
    (3,'Qualificado'),
    (4,'Proposta Enviada'),
    (5,'Fechado – Ganhou'),
    (6,'Fechado – Perdido');
  INSERT INTO usuario (usuario_nome,usuario_email,usuario_perfil) VALUES
    ('Ana Silva','ana@ex.com','vendedor'),
    ('Carlos Souza','carlos@ex.com','supervisor');
  INSERT INTO `lead` (lead_nome,lead_email,lead_telefone,lead_estagio_id,lead_usuario_id) VALUES
    ('João','joao@ex.com','(11)91111-1111',1,1),
    ('Mariana','maria@ex.com','(21)92222-2222',2,1);
  INSERT INTO interacao (interacao_lead_id,interacao_usuario_id,interacao_tipo,interacao_canal) VALUES
    (1,1,'Ligação','Telefone'),
    (1,1,'E-mail','E-mail'),
    (2,1,'WhatsApp','WhatsApp');
END$$

CREATE PROCEDURE sp_atualizar_estagios_por_interacao(IN p_lead_id INT)
BEGIN
  DECLARE ultima_tipo VARCHAR(20);
  SELECT interacao_tipo INTO ultima_tipo
    FROM interacao
   WHERE interacao_lead_id = p_lead_id
   ORDER BY interacao_data_hora DESC
   LIMIT 1;
  IF ultima_tipo = 'Ligação' THEN
    UPDATE `lead` SET lead_estagio_id = 2 WHERE lead_id = p_lead_id;
  ELSEIF ultima_tipo = 'Proposta Enviada' THEN
    UPDATE `lead` SET lead_estagio_id = 4 WHERE lead_id = p_lead_id;
  END IF;
END$$

CREATE PROCEDURE sp_gerar_relatorio_pipeline()
BEGIN
  SELECT
    e.estagio_nome,
    COUNT(*) AS total_leads,
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM `lead`))*100,2), '%') AS percentual
  FROM `lead` l
  JOIN estagio e ON l.lead_estagio_id = e.estagio_id
  GROUP BY e.estagio_nome;
END$$
DELIMITER ;

-- 5. Cria Triggers
DELIMITER $$
CREATE TRIGGER trg_atualiza_timestamp_lead
AFTER INSERT ON interacao
FOR EACH ROW
BEGIN
  UPDATE `lead`
     SET lead_atualizado_em = NOW()
   WHERE lead_id = NEW.interacao_lead_id;
END$$

CREATE TRIGGER trg_validar_transicao_estagio
BEFORE UPDATE ON `lead`
FOR EACH ROW
BEGIN
  IF NEW.lead_estagio_id > OLD.lead_estagio_id + 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Transição de estágio inválida.';
  END IF;
END$$
DELIMITER ;