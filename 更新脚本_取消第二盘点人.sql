-- ============================================================
-- 更新脚本：取消第二盘点人功能 + 添加新建时间字段 + 添加盘点范围字段
-- 功能：
-- 1. 修改 inventory_check 表，让 checker2_id 字段允许为 NULL
-- 2. 新增 create_time 字段用于记录盘点单创建时间
-- 3. 新增 scope 字段用于记录盘点范围（all/dangerous/normal）
-- 执行前请确保已备份数据库！
-- ============================================================

USE lab_consumable;

-- 1. 检查并修改 inventory_check 表的 checker2_id 字段
SELECT '修改 inventory_check 表的 checker2_id 字段...' AS message;
ALTER TABLE inventory_check MODIFY COLUMN checker2_id INT NULL COMMENT '盘点人2 ID（已弃用）';

-- 2. 检查并添加 create_time 字段（如果不存在）
SELECT '检查并添加 create_time 字段...' AS message;
SET @col_exists = (
    SELECT COUNT(*) 
    FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'inventory_check' 
        AND COLUMN_NAME = 'create_time'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE inventory_check ADD COLUMN create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT ''盘点单创建时间'' AFTER status',
    'SELECT ''create_time 字段已存在，跳过'' AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. 检查并添加 scope 字段（如果不存在）
SELECT '检查并添加 scope 字段...' AS message;
SET @col_exists = (
    SELECT COUNT(*) 
    FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'inventory_check' 
        AND COLUMN_NAME = 'scope'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE inventory_check ADD COLUMN scope VARCHAR(20) NOT NULL DEFAULT ''all'' COMMENT ''盘点范围：all-全部耗材，dangerous-仅危化品，normal-仅非危化品'' AFTER period',
    'SELECT ''scope 字段已存在，跳过'' AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT '更新完成！' AS message;
