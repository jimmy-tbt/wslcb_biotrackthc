CREATE PROCEDURE usp_load_organization_lab()
BEGIN
  # DROP INDEXES
  CALL usp_drop_index_if_exists('dim_organization_lab','ix_dol_id');
  CALL usp_drop_index_if_exists('dim_organization_lab','ix_dol_organization_lab_name');

  # TRUNCATE
  TRUNCATE TABLE biotrackthc_dw.dim_organization_lab;

  # LOAD TABLE
  INSERT INTO biotrackthc_dw.dim_organization_lab (
    id,
    organization_lab_name,
    is_active,
    license,
    status
  )
  SELECT
    orgid          AS id,
    orgname     AS organization_lab_name,
    orgactive   AS is_active,
    IFNULL(CASE WHEN CHAR_LENGTH(orglicense)>9 THEN LEFT(orglicense,9) ELSE orglicense END,NULL) AS license,
    orgstatus   AS status
  FROM
    biotrackthc.biotrackthc_organizations_labs;

  # CREATE INDEXES
  CREATE INDEX ix_dol_id                      ON biotrackthc_dw.dim_organization_lab (id);
  CREATE INDEX ix_dol_organization_lab_name   ON biotrackthc_dw.dim_organization_lab (organization_lab_name(50));

END;
