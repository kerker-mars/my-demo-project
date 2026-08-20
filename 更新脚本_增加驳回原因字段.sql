-- ============================================================
-- 增加驳回原因字段到 outbound_order 表
-- ============================================================
USE lab_consumable;
SET NAMES utf8mb4;

SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'lab_consumable'
      AND TABLE_NAME   = 'outbound_order'
      AND COLUMN_NAME  = 'reject_reason'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE outbound_order ADD COLUMN reject_reason VARCHAR(500) NULL COMMENT ''驳回原因''',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- 更新完成
-- ============================================================
