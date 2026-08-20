-- ============================================================
-- 更新脚本：修正历史库存盘点单的盘点范围
-- 功能：
-- 1. PD0013、PD0012 的盘点范围改为 "仅非危化品"
-- 2. PD0011、PD0004 的盘点范围改为 "仅危化品"
-- 安全边界：只修改 id <= 13 的数据
-- 执行前请确保已备份数据库！
-- ============================================================

USE lab_consumable;

-- 检查并备份当前数据（可选）
-- CREATE TABLE inventory_check_backup AS SELECT * FROM inventory_check;

-- 显示修正前的数据
SELECT '修正前的数据：' AS message;
SELECT
    id AS '盘点单号',
    CONCAT('PD', LPAD(id, 4, '0')) AS '显示单号',
    period AS '盘点周期',
    CASE scope
        WHEN 'all' THEN '全部耗材'
        WHEN 'dangerous' THEN '仅危化品'
        WHEN 'normal' THEN '仅非危化品'
    END AS '盘点范围',
    CASE status
        WHEN 0 THEN '进行中'
        WHEN 1 THEN '已完成'
    END AS '状态'
FROM inventory_check
WHERE id <= 13
ORDER BY id;

-- 1. PD0012、PD0013 改为仅非危化品
SELECT '更新 PD0012、PD0013 为仅非危化品...' AS message;
UPDATE inventory_check
SET scope = 'normal'
WHERE id IN (12, 13);

-- 2. PD0004、PD0011 改为仅危化品
SELECT '更新 PD0004、PD0011 为仅危化品...' AS message;
UPDATE inventory_check
SET scope = 'dangerous'
WHERE id IN (4, 11);

-- 显示更新后的结果
SELECT '修正完成！以下是前13条数据的结果：' AS message;
SELECT
    id AS '盘点单号',
    CONCAT('PD', LPAD(id, 4, '0')) AS '显示单号',
    period AS '盘点周期',
    CASE scope
        WHEN 'all' THEN '全部耗材'
        WHEN 'dangerous' THEN '仅危化品'
        WHEN 'normal' THEN '仅非危化品'
    END AS '盘点范围',
    CASE status
        WHEN 0 THEN '进行中'
        WHEN 1 THEN '已完成'
    END AS '状态'
FROM inventory_check
WHERE id <= 13
ORDER BY id;

SELECT '脚本执行完毕！' AS message;