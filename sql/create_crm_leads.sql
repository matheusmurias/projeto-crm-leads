DROP DATABASE IF EXISTS crm_leads;


CREATE DATABASE crm_leads
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE crm_leads;


DROP TABLE IF EXISTS `interacao`;
DROP TABLE IF EXISTS `lead`;
DROP TABLE IF EXISTS `usuario`;
DROP TABLE IF EXISTS `estagio`;


CREATE TABLE estagio (
  estagio_id   SMALLINT     NOT NULL,
  estagio_nome VARCHAR(50)  NOT NULL,
  PRIMARY KEY (estagio_id),
  UNIQUE KEY (estagio_nome)
) ENGINE=InnoDB;


CREATE TABLE usuario (
  usuario_id     INT          NOT NULL AUTO_INCREMENT,
  usuario_nome   VARCHAR(100) NOT NULL,
  usuario_email  VARCHAR(100) NOT NULL,
  usuario_perfil VARCHAR(20)  NOT NULL,
  PRIMARY KEY (usuario_id),
  UNIQUE KEY (usuario_email)
) ENGINE=InnoDB;


CREATE TABLE `lead` (
  `lead_id`            INT           NOT NULL AUTO_INCREMENT,
  `lead_nome`          VARCHAR(100)  NOT NULL,
  `lead_email`         VARCHAR(100)  NOT NULL,
  `lead_telefone`      VARCHAR(20),
  `lead_estagio_id`    SMALLINT      NOT NULL,
  `lead_usuario_id`    INT           NOT NULL,
  `lead_criado_em`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lead_atualizado_em` DATETIME      NULL DEFAULT NULL,
  PRIMARY KEY (`lead_id`),
  UNIQUE KEY (`lead_email`),
  INDEX idx_lead_estagio   (`lead_estagio_id`),
  INDEX idx_lead_usuario   (`lead_usuario_id`),
  CONSTRAINT fk_lead_estagio FOREIGN KEY (`lead_estagio_id`) REFERENCES `estagio`(`estagio_id`),
  CONSTRAINT fk_lead_usuario FOREIGN KEY (`lead_usuario_id`) REFERENCES `usuario`(`usuario_id`)
) ENGINE=InnoDB;


CREATE TABLE interacao (
  interacao_id          INT         NOT NULL AUTO_INCREMENT,
  interacao_lead_id     INT         NOT NULL,
  interacao_usuario_id  INT         NOT NULL,
  interacao_tipo        VARCHAR(20) NOT NULL,
  interacao_canal       VARCHAR(20) NOT NULL,
  interacao_data_hora   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  interacao_observacao  TEXT,
  PRIMARY KEY (interacao_id),
  INDEX idx_interacao_lead (interacao_lead_id),
  INDEX idx_interacao_user (interacao_usuario_id),
  CONSTRAINT fk_interacao_lead  
    FOREIGN KEY (interacao_lead_id)  
    REFERENCES `lead`(lead_id),
  CONSTRAINT fk_interacao_user  
    FOREIGN KEY (interacao_usuario_id) 
    REFERENCES usuario(usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

