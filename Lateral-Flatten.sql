SELECT
    m.menu_item_name,
    value:"ingredients"[0] AS ingredients
FROM tasty_bytes.raw_pos.menu m,
    LATERAL FLATTEN (input => m.menu_item_health_metrics_obj:menu_item_health_metrics);
