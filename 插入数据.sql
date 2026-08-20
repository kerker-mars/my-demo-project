USE lab_consumable;

INSERT INTO sys_role (role_name, description) VALUES ('系统管理员', '系统最高权限');

INSERT INTO sys_user (username, password, real_name, role_id, status)
VALUES ('admin', 'admin', '系统管理员', 1, 1);

-- 1. 插入实验室管理员角色
INSERT INTO sys_role (role_name, description) 
VALUES ('实验室管理员', '系统普通管理权限');

-- 2. 插入教师角色
INSERT INTO sys_role (role_name, description) 
VALUES ('教师', '系统使用权限');

-- 3. 插入实验室管理员用户
INSERT INTO sys_user (username, password, real_name, role_id, status)
VALUES ('lab_admin', 'lab_admin', '实验室管理员', 2, 1);

-- 4. 插入教师用户
INSERT INTO sys_user (username, password, real_name, role_id, status)
VALUES ('teacher', 'teacher', '教师', 3, 1);