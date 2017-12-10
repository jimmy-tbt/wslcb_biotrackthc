DROP PROCEDURE usp_load_location_lab;
CREATE PROCEDURE usp_load_location_lab()
BEGIN
  # DROP INDEXES
  CALL usp_drop_index_if_exists('dim_location_lab','ix_dll_id');
  CALL usp_drop_index_if_exists('dim_location_lab','ix_dll_license');
  CALL usp_drop_index_if_exists('dim_location_lab','ix_dll_location_lab_name');
  CALL usp_drop_index_if_exists('dim_location_lab','ix_dll_organization_id');
  CALL usp_drop_index_if_exists('dim_location_lab','ix_dll_ubi');

  # TRUNCATE
  TRUNCATE TABLE biotrackthc_dw.dim_location_lab;

  # LOAD TABLE
  INSERT INTO biotrackthc_dw.dim_location_lab (
    id,
    organization_id,
    location_lab_name,
    address1,
    address2,
    city,
    state,
    zip_code,
    zip_plus4,
    full_address,
    is_deleted,
    license,
    expiration_date,
    issue_date,
    status,
    district_code,
    mail_address1,
    mail_address2,
    mail_city,
    mail_state,
    mail_zip_code,
    mail_zip_plus4,
    ubi,
    transaction_id,
    transaction_id_original
  )
  SELECT
    id,
    orgid                                               AS organization_id,
    name                                                AS location_lab_name,
    address1                                            AS address1,
    address2                                            AS address2,
    city                                                AS city,
    IFNULL(LEFT(TRIM(state),2),NULL)                    AS state,
    IFNULL(CAST(LEFT(TRIM(zip),5) AS UNSIGNED INTEGER),NULL) AS zip_code,
    CASE WHEN CHAR_LENGTH(TRIM(zip)) > 5 THEN CONCAT(LEFT(TRIM(zip),5),'-',RIGHT(TRIM(zip),CHAR_LENGTH(TRIM(zip))-5)) ELSE zip END AS zip_plus4,
    CONCAT_WS(' ',address1,city,state,CASE WHEN CHAR_LENGTH(TRIM(zip))>5 THEN LEFT(TRIM(zip),5) ELSE TRIM(zip) END) AS full_address,
    deleted                                             AS is_deleted,
    IFNULL(CASE WHEN CHAR_LENGTH(licensenum)>8 THEN LEFT(licensenum,8) ELSE licensenum END,NULL) AS license,
    FROM_UNIXTIME(locationexp)                          AS expiration_date,
    FROM_UNIXTIME(locationissue)                        AS issue_date,
    status                                              AS status,
    districtcode                                        AS district_code,
    mailaddress1                                        AS mail_address1,
    mailaddress2                                        AS mail_address2,
    mailcity                                            AS mail_city,
    mailstate                                           AS mail_state,
    CASE WHEN (TRIM(mailzip) = '' OR mailzip IS NULL) THEN NULL ELSE LEFT(TRIM(mailzip),5) END AS mail_zip_code,
    CASE WHEN (TRIM(mailzip) = '' OR mailzip IS NULL) THEN NULL ELSE CONCAT(LEFT(TRIM(mailzip),5),'-',RIGHT(TRIM(mailzip),CHAR_LENGTH(TRIM(mailzip))-5)) END AS mail_zip_plus4,
    CAST(locubi AS UNSIGNED INTEGER)                    AS ubi,
    transactionid                                       AS transaction_id,
    transactionid_original                              AS transaction_id_original
  FROM
    biotrackthc.biotrackthc_locations_labs;

  # CREATE INDEXES
  CREATE INDEX ix_dll_id                  ON biotrackthc_dw.dim_location_lab (id);
  CREATE INDEX ix_dll_license             ON biotrackthc_dw.dim_location_lab (license);
  CREATE INDEX ix_dll_location_lab_name   ON biotrackthc_dw.dim_location_lab (location_lab_name);
  CREATE INDEX ix_dll_organization_id     ON biotrackthc_dw.dim_location_lab (organization_id);
  CREATE INDEX ix_dll_ubi                 ON biotrackthc_dw.dim_location_lab (ubi);

END;
