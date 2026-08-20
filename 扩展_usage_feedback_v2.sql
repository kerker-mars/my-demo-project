USE lab_consumable;
SET NAMES utf8mb4;

-- ============ 1) usage_feedback 表新增字段 ============
-- 反馈分类
SET @col1 = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='usage_feedback' AND COLUMN_NAME='category');
SET @sql1 = IF(@col1=0,
    "ALTER TABLE usage_feedback ADD COLUMN category VARCHAR(50) NOT NULL DEFAULT '其他' COMMENT '反馈分类'",
    'SELECT 1');
PREPARE s FROM @sql1; EXECUTE s; DEALLOCATE PREPARE s;

-- 处理状态：0未查看 1已查看 2已处理
SET @col2 = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='usage_feedback' AND COLUMN_NAME='feedback_status');
SET @sql2 = IF(@col2=0,
    'ALTER TABLE usage_feedback ADD COLUMN feedback_status TINYINT NOT NULL DEFAULT 0 COMMENT 处理状态：0未查看1已查看2已处理',
    'SELECT 1');
-- 注意：COMMENT 里不能有单引号，用变量绕过
SET @sql2 = IF(@col2=0,
    "ALTER TABLE usage_feedback ADD COLUMN feedback_status TINYINT NOT NULL DEFAULT 0 COMMENT '处理状态：0未查看 1已查看 2已处理'",
    'SELECT 1');
PREPARE s FROM @sql2; EXECUTE s; DEALLOCATE PREPARE s;

-- 管理员回复
SET @col3 = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='usage_feedback' AND COLUMN_NAME='admin_reply');
SET @sql3 = IF(@col3=0,
    "ALTER TABLE usage_feedback ADD COLUMN admin_reply VARCHAR(500) NULL COMMENT '管理员回复'",
    'SELECT 1');
PREPARE s FROM @sql3; EXECUTE s; DEALLOCATE PREPARE s;

-- 验证
SELECT id, outbound_order_id, user_id, category, feedback_status, admin_reply, content, create_time FROM usage_feedback LIMIT 5;
