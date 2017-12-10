CREATE PROCEDURE usp_load_inventory()
BEGIN
  # DROP INDEXES
  CALL usp_drop_index_if_exists('dim_inventory','ix_di_inventory_date');
  CALL usp_drop_index_if_exists('dim_inventory','ix_di_inventory_type');
  CALL usp_drop_index_if_exists('dim_inventory','ix_di_location');
  CALL usp_drop_index_if_exists('dim_inventory','ix_di_organization_id');
  CALL usp_drop_index_if_exists('dim_inventory','ix_di_sessiontime');

  # LOAD TABLE
  INSERT INTO dim_inventory
  SELECT
    bi.id,
    bi.sessiontime,
    FROM_UNIXTIME(bi.sessiontime) AS inventory_date,
    bi.strain,
    #CASE WHEN weight = '' OR weight IS NULL THEN NULL ELSE weight END AS weight,
    bi.weight,
    transactionid,
    plantid,
    bi.location,
    #CASE WHEN remainingweight = '' OR remainingweight IS NULL THEN NULL ELSE remainingweight END AS remaining_weight,
    remainingweight,
    requiresweighing,
    parentid,
    inventorytype,
    bi.wet,
    bi.seized,
    orgid,
    bi.deleted,
    plantarray,
    CASE WHEN usableweight = '' OR usableweight IS NULL THEN NULL ELSE usableweight END AS usable_weight,
    #usableweight,
    removescheduled,
    removescheduletime,
    IFNULL(FROM_UNIXTIME(removescheduletime),NULL) AS remove_schedule_date,
    inventoryparentid,
    productname,
    IFNULL(currentroom,NULL) AS current_room,
    idserial,
    removereason,
    CASE WHEN inventorystatus = '' OR inventorystatus IS NULL THEN NULL ELSE inventorystatus END AS inventory_status,
    CASE WHEN inventorystatustime = '' OR inventorystatustime IS NULL THEN NULL ELSE inventorystatustime END AS inventory_status_time,
    IFNULL(FROM_UNIXTIME(inventorystatustime),NULL) AS inventory_status_date,
    inventoryparentid,
    bi.sample_id,
    bi.source_id,
    transactionid_original,
    IFNULL(bi.recalled,NULL) AS recalled
  FROM
    biotrackthc.biotrackthc_inventory bi
    LEFT JOIN dim_inventory di ON bi.id = di.id
  WHERE 1=1
    AND di.id IS NULL;

  # CREATE INDEXES
  CREATE INDEX ix_di_inventory_date   ON dim_inventory (inventory_date);
  CREATE INDEX ix_di_inventory_type   ON dim_inventory (inventory_type);
  CREATE INDEX ix_di_location         ON dim_inventory (location);
  CREATE INDEX ix_di_organization_id  ON dim_inventory (organization_id);
  CREATE INDEX ix_di_sessiontime      ON dim_inventory (sessiontime);

END;
