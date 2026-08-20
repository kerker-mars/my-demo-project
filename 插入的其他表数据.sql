USE lab_consumable;
SET NAMES utf8mb4;
-- ============ 1) 角色（补齐系统管理员/实验室管理员/教师）============
INSERT INTO sys_role(role_name, description)
SELECT '系统管理员', '系统最高权限'
WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_name='系统管理员');
INSERT INTO sys_role(role_name, description)
SELECT '实验室管理员', '系统普通管理权限'
WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_name='实验室管理员');
INSERT INTO sys_role(role_name, description)
SELECT '教师', '系统使用权限'
WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_name='教师');

-- 取角色ID
SET @rid_admin := (SELECT id FROM sys_role WHERE role_name='系统管理员' LIMIT 1);
SET @rid_lab   := (SELECT id FROM sys_role WHERE role_name='实验室管理员' LIMIT 1);
SET @rid_tch   := (SELECT id FROM sys_role WHERE role_name='教师' LIMIT 1);

-- ============ 2) 用户（存在则不重复插入；并确保 role_id 正确）============
INSERT INTO sys_user(username, password, real_name, role_id, status)
SELECT 'admin','admin','系统管理员', @rid_admin, 1
WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE username='admin');
INSERT INTO sys_user(username, password, real_name, role_id, status)
SELECT 'lab_admin','lab_admin','实验室管理员', @rid_lab, 1
WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE username='lab_admin');
INSERT INTO sys_user(username, password, real_name, role_id, status)
SELECT 'teacher','teacher','教师', @rid_tch, 1
WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE username='teacher');

-- 若你之前插入过但 role_id 不对，这里强制纠正为对应角色
UPDATE sys_user SET role_id=@rid_admin WHERE username='admin';
UPDATE sys_user SET role_id=@rid_lab   WHERE username='lab_admin';
UPDATE sys_user SET role_id=@rid_tch   WHERE username='teacher';

-- 取用户ID
SET @uid_admin := (SELECT id FROM sys_user WHERE username='admin' LIMIT 1);
SET @uid_lab   := (SELECT id FROM sys_user WHERE username='lab_admin' LIMIT 1);
SET @uid_tch   := (SELECT id FROM sys_user WHERE username='teacher' LIMIT 1);

-- ============ 3) 实验室（先 principal_id 置空，避免插入时循环外键问题）============
INSERT INTO lab(lab_name, lab_code, location, principal_id, danger_level, remark)
SELECT '计算机实验教学中心A实验室', 'LAB-A', '实验楼A-301', NULL, 1, '含危险化学品，需五双管理'
WHERE NOT EXISTS (SELECT 1 FROM lab WHERE lab_code='LAB-A');

-- 取实验室ID
SET @lab_id := (SELECT id FROM lab WHERE lab_code='LAB-A' LIMIT 1);
-- 绑定实验室负责人（principal_id -> lab_admin）
UPDATE lab SET principal_id=@uid_lab WHERE id=@lab_id;
-- ============ 4) 绑定用户所属实验室（满足“lab_id 不为空”硬条件）============
UPDATE sys_user SET lab_id=@lab_id WHERE username IN ('lab_admin','teacher');
-- ============ 5) 耗材基础数据（至少插入几条，含危险品与非危险品）============
INSERT INTO consumable(name, category, spec, unit, is_dangerous, storage_require, validity_period, remark)
SELECT '无水乙醇', '试剂', '500ml/瓶', '瓶', 1, '避光密封，远离火源', 365, '危险化学品'
WHERE NOT EXISTS (SELECT 1 FROM consumable WHERE name='无水乙醇');
INSERT INTO consumable(name, category, spec, unit, is_dangerous, storage_require, validity_period, remark)
SELECT '一次性手套', '一般耗材', 'L号/100只', '盒', 0, '干燥保存', NULL, ''
WHERE NOT EXISTS (SELECT 1 FROM consumable WHERE name='一次性手套');
INSERT INTO consumable(name, category, spec, unit, is_dangerous, storage_require, validity_period, remark)
SELECT '烧杯', '器皿', '250ml', '个', 0, '防摔防震', NULL, ''
WHERE NOT EXISTS (SELECT 1 FROM consumable WHERE name='烧杯');

-- 取耗材ID
SET @cid_ethanol := (SELECT id FROM consumable WHERE name='无水乙醇' LIMIT 1);
SET @cid_glove   := (SELECT id FROM consumable WHERE name='一次性手套' LIMIT 1);
SET @cid_beaker  := (SELECT id FROM consumable WHERE name='烧杯' LIMIT 1);

-- ============ 6) 库存数据（满足“stock 里存在 lab+consumable 且数量充足”）============
INSERT INTO stock(lab_id, consumable_id, total_quantity, safe_quantity, warning_quantity)
SELECT @lab_id, @cid_ethanol, 20, 5, 10
WHERE NOT EXISTS (SELECT 1 FROM stock WHERE lab_id=@lab_id AND consumable_id=@cid_ethanol);
INSERT INTO stock(lab_id, consumable_id, total_quantity, safe_quantity, warning_quantity)
SELECT @lab_id, @cid_glove, 50, 10, 20
WHERE NOT EXISTS (SELECT 1 FROM stock WHERE lab_id=@lab_id AND consumable_id=@cid_glove);
INSERT INTO stock(lab_id, consumable_id, total_quantity, safe_quantity, warning_quantity)
SELECT @lab_id, @cid_beaker, 30, 5, 10
WHERE NOT EXISTS (SELECT 1 FROM stock WHERE lab_id=@lab_id AND consumable_id=@cid_beaker);

-- ============ 7)（可选）快速检查输出 ============
SELECT 'roles' AS t, id, role_name FROM sys_role;
SELECT 'users' AS t, id, username, real_name, role_id, lab_id, status FROM sys_user;
SELECT 'lab' AS t, id, lab_name, lab_code, principal_id, danger_level FROM lab;
SELECT 'consumable' AS t, id, name, is_dangerous FROM consumable;
SELECT 'stock' AS t, id, lab_id, consumable_id, total_quantity FROM stock WHERE lab_id=@lab_id;

-- ============ 8) 归还登记（教师 teacher 无数据时）============
-- 列表只显示「当前登录用户 = outbound_order.apply_user_id」且已出库(status=3)的明细。
-- 若历史领用是 admin/lab_admin 申请的，teacher 登录会为空。请执行项目根目录：
--   测试数据_归还登记_teacher.sql

-- ============ 9) 教师「使用反馈」功能 ============
-- 执行项目根目录：扩展_usage_feedback表.sql（创建 usage_feedback 表）

-- ============ 10) 库存盘点 ============
-- 表 inventory_check / inventory_check_item 已包含在 基本结构_数据库.sql 中。
-- 实验室管理员从菜单「库存盘点」进入，由 ServletInventory 读写。
