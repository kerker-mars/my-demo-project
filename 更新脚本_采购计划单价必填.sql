-- ============================================================
-- 数据库更新脚本：设置采购计划明细表单价为必填项
-- ============================================================
USE lab_consumable;

-- 步骤1：先处理已有的NULL数据（如果有的话，可以设置为0或者其他默认值）
-- 这里先检查是否有NULL值
-- SELECT * FROM purchase_plan_item WHERE plan_price IS NULL;

-- 如果有NULL值，可以先将其设置为0（或者根据业务需求调整）
-- UPDATE purchase_plan_item SET plan_price = 0 WHERE plan_price IS NULL;

-- 步骤2：修改表结构，将 plan_price 设置为 NOT NULL
ALTER TABLE purchase_plan_item 
MODIFY COLUMN plan_price DECIMAL(10,2) NOT NULL COMMENT '计划单价';

-- ============================================================
-- 更新完成
-- ============================================================
