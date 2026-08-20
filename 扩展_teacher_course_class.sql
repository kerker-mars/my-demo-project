USE lab_consumable;
SET NAMES utf8mb4;

-- ============ 1) 教师课程表 ============
CREATE TABLE IF NOT EXISTS teacher_course (
    id          INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    teacher_id  INT NOT NULL COMMENT '教师用户ID',
    course_name VARCHAR(100) NOT NULL COMMENT '课程名称',
    course_code VARCHAR(50)  NULL COMMENT '课程编号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教师所授课程表';

-- ============ 2) 教师班级表 ============
CREATE TABLE IF NOT EXISTS teacher_class (
    id          INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    teacher_id  INT NOT NULL COMMENT '教师用户ID',
    class_name  VARCHAR(100) NOT NULL COMMENT '班级名称',
    class_code  VARCHAR(50)  NULL COMMENT '班级编号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教师所授班级表';

-- ============ 3) consumable 表新增 returnable 字段 ============
-- 先检查字段是否存在，不存在才添加（兼容重复执行）
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'lab_consumable'
      AND TABLE_NAME   = 'consumable'
      AND COLUMN_NAME  = 'returnable'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE consumable ADD COLUMN returnable TINYINT NOT NULL DEFAULT 0 COMMENT ''是否可归还：0消耗品 1可归还''',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============ 4) 取 teacher 用户 ID ============
SET @uid_tch := (SELECT id FROM sys_user WHERE username='teacher' LIMIT 1);

-- ============ 5) 插入教师课程数据 ============
INSERT INTO teacher_course(teacher_id, course_name, course_code)
SELECT @uid_tch, '大学物理实验', 'PHY101'
WHERE NOT EXISTS (SELECT 1 FROM teacher_course WHERE teacher_id=@uid_tch AND course_name='大学物理实验');

INSERT INTO teacher_course(teacher_id, course_name, course_code)
SELECT @uid_tch, '有机化学实验', 'CHE201'
WHERE NOT EXISTS (SELECT 1 FROM teacher_course WHERE teacher_id=@uid_tch AND course_name='有机化学实验');

INSERT INTO teacher_course(teacher_id, course_name, course_code)
SELECT @uid_tch, '无机化学实验', 'CHE101'
WHERE NOT EXISTS (SELECT 1 FROM teacher_course WHERE teacher_id=@uid_tch AND course_name='无机化学实验');

INSERT INTO teacher_course(teacher_id, course_name, course_code)
SELECT @uid_tch, '计算机组成原理实验', 'CS301'
WHERE NOT EXISTS (SELECT 1 FROM teacher_course WHERE teacher_id=@uid_tch AND course_name='计算机组成原理实验');

INSERT INTO teacher_course(teacher_id, course_name, course_code)
SELECT @uid_tch, '数字电路实验', 'EE201'
WHERE NOT EXISTS (SELECT 1 FROM teacher_course WHERE teacher_id=@uid_tch AND course_name='数字电路实验');

-- ============ 6) 插入教师班级数据 ============
INSERT INTO teacher_class(teacher_id, class_name, class_code)
SELECT @uid_tch, '计算机科学2201班', 'CS2201'
WHERE NOT EXISTS (SELECT 1 FROM teacher_class WHERE teacher_id=@uid_tch AND class_name='计算机科学2201班');

INSERT INTO teacher_class(teacher_id, class_name, class_code)
SELECT @uid_tch, '计算机科学2202班', 'CS2202'
WHERE NOT EXISTS (SELECT 1 FROM teacher_class WHERE teacher_id=@uid_tch AND class_name='计算机科学2202班');

INSERT INTO teacher_class(teacher_id, class_name, class_code)
SELECT @uid_tch, '软件工程2201班', 'SE2201'
WHERE NOT EXISTS (SELECT 1 FROM teacher_class WHERE teacher_id=@uid_tch AND class_name='软件工程2201班');

INSERT INTO teacher_class(teacher_id, class_name, class_code)
SELECT @uid_tch, '软件工程2202班', 'SE2202'
WHERE NOT EXISTS (SELECT 1 FROM teacher_class WHERE teacher_id=@uid_tch AND class_name='软件工程2202班');

INSERT INTO teacher_class(teacher_id, class_name, class_code)
SELECT @uid_tch, '网络工程2201班', 'NE2201'
WHERE NOT EXISTS (SELECT 1 FROM teacher_class WHERE teacher_id=@uid_tch AND class_name='网络工程2201班');

INSERT INTO teacher_class(teacher_id, class_name, class_code)
SELECT @uid_tch, '电子信息2201班', 'EI2201'
WHERE NOT EXISTS (SELECT 1 FROM teacher_class WHERE teacher_id=@uid_tch AND class_name='电子信息2201班');

-- ============ 7) 更新 consumable 的 returnable 属性 ============
SET SQL_SAFE_UPDATES = 0;
UPDATE consumable SET returnable=1 WHERE category='器皿' OR name IN ('烧杯','量筒','锥形瓶','试管','烧瓶');
UPDATE consumable SET returnable=0 WHERE category IN ('试剂','一般耗材') OR name IN ('一次性手套','无水乙醇');
SET SQL_SAFE_UPDATES = 1;

-- ============ 8) 验证 ============
SELECT 'teacher_course' AS t, tc.id, tc.course_name, u.username
FROM teacher_course tc JOIN sys_user u ON tc.teacher_id=u.id;

SELECT 'teacher_class' AS t, tcl.id, tcl.class_name, u.username
FROM teacher_class tcl JOIN sys_user u ON tcl.teacher_id=u.id;

SELECT 'consumable_returnable' AS t, id, name, category, returnable FROM consumable;
