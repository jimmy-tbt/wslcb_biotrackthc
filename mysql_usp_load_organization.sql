CREATE PROCEDURE usp_load_organization()
BEGIN
  # DROP INDEXES
  CALL usp_drop_index_if_exists('dim_organization','ix_do_id');
  CALL usp_drop_index_if_exists('dim_organization','ix_do_license');
  CALL usp_drop_index_if_exists('dim_organization','ix_do_organization_name');

  # TRUNCATE TABLE
  TRUNCATE TABLE biotrackthc_dw.dim_organization;

  # LOAD TABLE
  INSERT INTO biotrackthc_dw.dim_organization (
    organization_name,
    id,
    is_active,
    license,
    fifteen_day_start_date,
    status)
  SELECT
    orgname     AS organization_name,
    orgid       AS id,
    orgactive   AS is_active,
    orglicense  AS license,
    from_unixtime(fifteendaystart) AS fifteen_day_start_date,
    orgstatus   AS status
  FROM
    biotrackthc.biotrackthc_organizations;

  CREATE INDEX ix_do_id                 ON biotrackthc_dw.dim_organization (id);
  CREATE INDEX ix_do_license            ON biotrackthc_dw.dim_organization (license);
  CREATE INDEX ix_do_organization_name  ON biotrackthc_dw.dim_organization (organization_name(50));
END;
