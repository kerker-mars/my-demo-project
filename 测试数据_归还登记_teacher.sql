-- ============================================================
-- 归还登记：为「教师 teacher」补可归还数据
-- 原因：listReturnableItems 只列出 outbound_order.apply_user_id = 当前登录用户
--       且 status=3（已出库）、且无待审/已通过归还记录。
--       若历史领用单的申请人是 admin(1)/lab_admin(15)，teacher(16) 登录列表必为空。
-- ============================================================
USE lab_consumable;
SET NAMES utf8mb4;

SET @lab_id := (SELECT id FROM lab WHERE lab_code = 'LAB-A' LIMIT 1);
SET @uid_teacher := (SELECT id FROM sys_user WHERE username = 'teacher' LIMIT 1);
SET @uid_lab := (SELECT id FROM sys_user WHERE username = 'lab_admin' LIMIT 1);

-- 可选：确保教师绑实验室（与报废、业务一致）
UPDATE sys_user SET lab_id = @lab_id WHERE id = @uid_teacher AND (@lab_id IS NOT NULL);

-- 仅当尚未插入过演示数据时再插入（避免重复执行产生多条）
INSERT INTO outbound_order (lab_id, apply_user_id, course_name, class_name, purpose, status, audit_user_id, audit_time)
SELECT @lab_id, @uid_teacher, '教师测试课程', '测试班级', '【测试】归还登记-教师账号专用', 3, @uid_lab, NOW()
FROM DUAL
WHERE @uid_teacher IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM outbound_order o
    WHERE o.apply_user_id = @uid_teacher
      AND o.status = 3
      AND o.purpose = '【测试】归还登记-教师账号专用'
  );

SET @oid := (SELECT id FROM outbound_order
             WHERE apply_user_id = @uid_teacher
               AND status = 3
               AND purpose = '【测试】归还登记-教师账号专用'
             ORDER BY id DESC LIMIT 1);

INSERT INTO outbound_item (outbound_id, consumable_id, quantity, should_return, remark)
SELECT @oid, 3, 3, 1, '教师登录后可在此明细上提交归还'
FROM DUAL
WHERE @oid IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM outbound_item i WHERE i.outbound_id = @oid
  );

-- 自检：teacher 应能看到至少 1 条可归还明细
SELECT u.id AS user_id, u.username, COUNT(*) AS returnable_rows
FROM sys_user u
JOIN outbound_order o ON o.apply_user_id = u.id AND o.status = 3
JOIN outbound_item i ON i.outbound_id = o.id
LEFT JOIN return_record r ON r.outbound_item_id = i.id AND r.status IN (0, 1)
WHERE u.username = 'teacher' AND r.id IS NULL
GROUP BY u.id, u.username;
