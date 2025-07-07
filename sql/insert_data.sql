USE crm_leads;


SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE interacao;
TRUNCATE TABLE `lead`;
TRUNCATE TABLE usuario;
TRUNCATE TABLE estagio;
SET FOREIGN_KEY_CHECKS = 1;


CALL sp_inserir_dados_teste();


INSERT INTO `lead`
  (lead_nome, lead_email, lead_telefone, lead_estagio_id, lead_usuario_id)
VALUES
  ('Lucas',    'lucas@ex.com',    '(31)93333-3333', 3, 2),  -- Qualificado
  ('Fernanda', 'fernanda@ex.com', '(41)94444-4444', 4, 1),  -- Proposta Enviada
  ('Pedro',    'pedro@ex.com',    '(51)95555-5555', 5, 2),  -- Fechado – Ganhou
  ('Marcos',   'marcos@ex.com',   '(61)96666-6666', 6, 1);  -- Fechado – Perdido


INSERT INTO interacao
  (interacao_lead_id, interacao_usuario_id, interacao_tipo, interacao_canal)
VALUES
  (3, 2, 'Proposta Enviada', 'E-mail'),
  (4, 1, 'Ligação',          'Telefone'),
  (5, 2, 'WhatsApp',         'WhatsApp'),
  (6, 1, 'Ligação',          'Telefone');
