CREATE PROCEDURE usp_load_location()
BEGIN
  # DROP INDEXES
  CALL usp_drop_index_if_exists('dim_location','ix_dl_id');
  CALL usp_drop_index_if_exists('dim_location','ix_dl_license');
  CALL usp_drop_index_if_exists('dim_location','ix_dl_location_name');
  CALL usp_drop_index_if_exists('dim_location','ix_dl_organization_id');
  CALL usp_drop_index_if_exists('dim_location','ix_dl_ubi');

  # TRUNCATE
  TRUNCATE TABLE biotrackthc_dw.dim_location;

  # LOAD TABLE
  #IFNULL(FROM_UNIXTIME(l.locationexp),NULL)   AS expiration_date,
  INSERT INTO biotrackthc_dw.dim_location (
    organization_id,
    location_index,
    location_name,
    address1,
    address2,
    city,
    state,
    zip_code,
    zip_plus4,
    full_address,
    is_deleted,
    location_type,
    license,
    id,
    expiration_date,
    issue_date,
    status,
    district_code,
    latitude,
    longitude,
    mail_address1,
    mail_address2,
    mail_city,
    mail_state,
    mail_zip_code,
    mail_zip_plus4,
    ubi,
    is_producer,
    is_processor,
    is_retail,
    business_type,
    transaction_id,
    transaction_id_original,
    fifteenday_end_date,
    deleted_date)
  SELECT
    orgid                           AS organization_id,
    locationid                      AS location_index,
    name                            AS location_name,
    address1                        AS address1,
    address2                        AS address2,
    city                            AS city,
    state                           AS state,
    CAST(LEFT(zip,5) AS UNSIGNED INTEGER) AS zip_code,
    CASE WHEN CHAR_LENGTH(zip) > 5 THEN CONCAT(LEFT(zip,5),'-',RIGHT(zip,CHAR_LENGTH(zip)-5)) ELSE zip END AS zip_plus4,
    CONCAT_WS(' ',address1,city,state,LEFT(zip,5)) AS full_address,
    deleted                         AS is_deleted,
    locationtype                    AS location_type,
    CAST(LEFT(licensenum,6) AS UNSIGNED INTEGER) AS license_number,
    id                              AS id,
    FROM_UNIXTIME(locationexp)      AS expiration_date,
    FROM_UNIXTIME(locationissue)    AS issue_date,
    status                          AS status,
    districtcode                    AS district_code,
    loclatitude                     AS latitude,
    loclongitude                    AS longitude,
    mailaddress1                    AS mail_address1,
    mailaddress2                    AS mail_address2,
    mailcity                        AS mail_city,
    mailstate                       AS mail_state,
    CAST(LEFT(mailzip,5) AS UNSIGNED INTEGER) AS mail_zip_code,
    CASE WHEN CHAR_LENGTH(mailzip) > 5 THEN CONCAT(LEFT(mailzip,5),'-',RIGHT(mailzip,CHAR_LENGTH(mailzip)-5)) ELSE mailzip END AS mail_zip_plus4,
    locubi                          AS ubi,
    CASE WHEN producer = 1 THEN TRUE ELSE FALSE END AS is_producer,
    CASE WHEN processor = 1 THEN TRUE ELSE FALSE END AS is_processor,
    CASE WHEN retail = 1 THEN TRUE ELSE FALSE END AS is_retailer,
    CASE
      WHEN (producer = 1 AND processor = 1) THEN 'Producer/Processor'
      WHEN producer = 1 THEN 'Producer'
      WHEN processor = 1 THEN 'Processor'
      WHEN retail = 1 THEN 'Retailer'
      ELSE 'TBD'
    END AS business_type,
    transactionid                   AS transaction_id,
    transactionid_original          AS transaction_id_original,
    FROM_UNIXTIME(fifteenday_end)   AS fifteenday_end_date,
    FROM_UNIXTIME(delete_time)      AS deleted_date
  from
    biotrackthc.biotrackthc_locations;

  # CREATE INDEXES
  CREATE INDEX ix_dl_id               ON biotrackthc_dw.dim_location (id);
  CREATE INDEX ix_dl_license          ON biotrackthc_dw.dim_location (license);
  CREATE INDEX ix_dl_location_name    ON biotrackthc_dw.dim_location (location_name(50));
  CREATE INDEX ix_dl_organization_id  ON biotrackthc_dw.dim_location (organization_id);
  CREATE INDEX ix_dl_ubi              ON biotrackthc_dw.dim_location (ubi);

END;
