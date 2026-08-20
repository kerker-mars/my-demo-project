-- ============================================================
-- 更新脚本：修正历史库存盘点单的新建时间
-- 功能：
-- 1. 已完成的单据：新建时间早于完成时间几天
-- 2. 进行中的单据：新建时间在最近15天内错落有致
-- 安全边界：只修改 id <= 12 的数据
-- 执行前请确保已备份数据库！
-- ============================================================

USE lab_consumable;

-- 检查并备份当前数据（可选）
-- CREATE TABLE inventory_check_backup AS SELECT * FROM inventory_check;

-- 1. 更新已完成的单据（status = 1）：新建时间比完成时间早 1-7 天
SELECT '更新已完成单据的新建时间...' AS message;
UPDATE inventory_check
SET create_time = DATE_SUB(check_time, INTERVAL FLOOR(1 + RAND() * 7) DAY)
WHERE id <= 12
  AND status = 1
  AND check_time IS NOT NULL;

-- 2. 更新进行中的单据（status = 0）：新建时间在最近15天内
SELECT '更新进行中单据的新建时间...' AS message;
UPDATE inventory_check
SET create_time = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 15) DAY)
WHERE id <= 12
  AND status = 0;

-- 显示更新后的结果
SELECT '更新完成！以下是前12条数据的结果：' AS message;
SELECT
    id AS '盘点单号',
    CONCAT('PD', LPAD(id, 4, '0')) AS '显示单号',
    period AS '盘点周期',
    CASE status
        WHEN 0 THEN '进行中'
        WHEN 1 THEN '已完成'
    END AS '状态',
    DATE_FORMAT(create_time, '%Y-%m-%d %H:%i:%s') AS '新建时间',
    DATE_FORMAT(check_time, '%Y-%m-%d %H:%i:%s') AS '完成时间'
FROM inventory_check
WHERE id <= 12
ORDER BY id;

SELECT '脚本执行完毕！' AS message;