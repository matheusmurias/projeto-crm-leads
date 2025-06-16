# Projeto CRM de Leads

Repositório contendo:

- **`sql/create_crm_leads.sql`** – Script DDL original para criação de tabelas  
- **`sql/create_objects.sql`** – Criação de Views, Functions, Stored Procedures e Triggers  
- **`sql/insert_data.sql`** – População inicial de dados de teste  
- **`docs/er_diagrama.png`** – Diagrama Entidade-Relacionamento  
- **`docs/Ideia+Murias.pdf`** – Documentação da Entrega 1  
- **`docs/Entrega2+Murias.pdf`** – Documentação da Entrega 2  

## Links “raw” dos scripts

- Create tables (DDL):  
  https://raw.githubusercontent.com/matheusmurias/projeto-crm-leads/main/sql/create_crm_leads.sql
- Create objects:  
  https://raw.githubusercontent.com/matheusmurias/projeto-crm-leads/main/sql/create_objects.sql
- Insert data:  
  https://raw.githubusercontent.com/matheusmurias/projeto-crm-leads/main/sql/insert_data.sql

## Como executar

1. **Criar o schema e as tabelas**  
   No MySQL Workbench, abra `sql/create_crm_leads.sql` e clique em ⚡ Execute All.  
2. **Criar Views, Functions, SPs e Triggers**  
   Abra `sql/create_objects.sql` e execute tudo de uma vez.  
3. **Popular dados de teste**  
   Abra `sql/insert_data.sql` e execute; ou use “Table Data Import Wizard” para CSVs, se preferir.  
4. **Verificar resultados**  
   - Em **Schemas → crm_leads → Views** confira as Views criadas.  
   - Em **Schemas → crm_leads → Functions** veja as funções.  
   - Em **Schemas → crm_leads → Stored Procedures** e **Triggers** confira os objetos criados.  
   - Rode alguns `SELECT * FROM view_leads_por_estagio;` ou `CALL sp_gerar_relatorio_pipeline();` para validar.  
