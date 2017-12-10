CREATE PROCEDURE usp_load_inventory_transfers()
BEGIN
  CALL usp_drop_index_if_exists('fact_inventory_transfers','ix_fit_deleted');
  CALL usp_drop_index_if_exists('fact_inventory_transfers','ix_fit_inbound_license');
  CALL usp_drop_index_if_exists('fact_inventory_transfers','ix_fit_inbound_location');
  CALL usp_drop_index_if_exists('fact_inventory_transfers','ix_fit_inbound_organization_id');
  CALL usp_drop_index_if_exists('fact_inventory_transfers','ix_fit_inventory_id');
  CALL usp_drop_index_if_exists('fact_inventory_transfers','ix_fit_inventory_type');
  CALL usp_drop_index_if_exists('fact_inventory_transfers','ix_fit_location');
  CALL usp_drop_index_if_exists('fact_inventory_transfers','ix_fit_organization_id');
  CALL usp_drop_index_if_exists('fact_inventory_transfers','ix_fit_outbound_license');

  SET @max_id = (SELECT MAX(id) AS max_id FROM fact_inventory_transfers);

  INSERT INTO fact_inventory_transfers (
    id,
    inventory_id,
    strain,
    weight,
    transaction_id,
    location,
    direction,
    requires_weighing,
    transfer_type,
    organization_id,
    parent_id,
    inventory_type,
    usable_weight,
    outbound_license,
    inbound_license,
    description,
    sale_price,
    manifest_id,
    manifest_stop,
    received,
    receive_weight,
    deleted,
    unit_price,
    is_refund,
    refund_amount,
    inbound_location,
    transaction_id_original,
    inbound_organization_id,
    transaction_id_original_inbound
  )
  SELECT
    id,
    inventoryid AS inventory_id,
    strain,
    weight,
    transactionid AS transaction_id,
    location,
    direction,
    requiresweighing AS requires_weighing,
    transfertype AS transfer_type,
    orgid AS organization_id,
    parentid AS parent_id,
    inventorytype AS inventory_type,
    usableweight AS usable_weight,
    outbound_license,
    inbound_license,
    description,
    saleprice AS sale_price,
    manifestid AS manifest_id,
    manifest_stop,
    received,
    receiveweight AS receive_weight,
    deleted,
    unitprice AS unit_price,
    is_refund,
    refund_amount,
    inbound_location,
    transactionid_original AS transaction_id_original,
    inbound_orgid,
    transactionid_original_inbound AS transaction_id_original_inbound
  FROM
    biotrackthc.biotrackthc_inventorytransfers
  WHERE 1=1
    AND id > @max_id;

  CREATE INDEX ix_fit_deleted                   ON fact_inventory_transfers (deleted);
  CREATE INDEX ix_fit_inbound_license           ON fact_inventory_transfers (inbound_license);
  CREATE INDEX ix_fit_inbound_location          ON fact_inventory_transfers (inbound_location);
  CREATE INDEX ix_fit_inbound_organization_id   ON fact_inventory_transfers (inbound_organization_id);
  CREATE INDEX ix_fit_inventory_id              ON fact_inventory_transfers (inventory_id);
  CREATE INDEX ix_fit_inventory_type            ON fact_inventory_transfers (inventory_type);
  CREATE INDEX ix_fit_location                  ON fact_inventory_transfers (location);
  CREATE INDEX ix_fit_organization_id           ON fact_inventory_transfers (organization_id);
  CREATE INDEX ix_fit_outbound_license          ON fact_inventory_transfers (outbound_license);
END;
