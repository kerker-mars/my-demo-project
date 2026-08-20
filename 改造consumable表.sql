USE lab_consumable;

-- 【关键修复 1】：临时关闭 MySQL 的安全更新模式
SET SQL_SAFE_UPDATES = 0; 

-- （注意：如果你刚才第一步 ALTER TABLE 添加字段已经成功了，就把下面这句 ALTER TABLE 删掉，否则会报字段已存在）
-- ALTER TABLE consumable 
-- ADD COLUMN min_safe_stock INT NOT NULL DEFAULT 0 COMMENT '最低安全库存（常规耗材触发缺货预警）' AFTER validity_period,
-- ADD COLUMN max_limit_stock INT NOT NULL DEFAULT 9999 COMMENT '最高合规库存（危险品触发超量预警）' AFTER min_safe_stock;

-- =========================================================
-- 第二步：初始化基础基线（双轨制分离）
-- =========================================================
UPDATE consumable SET min_safe_stock = 10, max_limit_stock = 9999 WHERE is_dangerous = 0;
UPDATE consumable SET min_safe_stock = 1, max_limit_stock = 20 WHERE is_dangerous = 1;

-- =========================================================
-- 第三步：精细化数据
-- =========================================================
UPDATE consumable SET min_safe_stock = 50 WHERE id IN (23, 24, 25, 26);
UPDATE consumable SET min_safe_stock = 20 WHERE id IN (8, 17, 22);
UPDATE consumable SET min_safe_stock = 5 WHERE id IN (11, 14, 15, 16, 19, 20, 27);

UPDATE consumable SET max_limit_stock = 10 WHERE id IN (41, 32, 33, 36, 44, 45);
UPDATE consumable SET max_limit_stock = 15 WHERE id IN (5, 10, 40);
UPDATE consumable SET max_limit_stock = 20 WHERE id IN (34, 37, 38, 42);


-- 【关键修复 2】：数据更新完毕，重新开启安全更新模式，保护数据库
SET SQL_SAFE_UPDATES = 1; 

SELECT '数据更新成功，安全模式已重新开启！' AS message;
