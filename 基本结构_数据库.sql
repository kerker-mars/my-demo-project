-- ============================================================
-- 计算机实验教学中心耗材管理系统 - 完整数据库结构
-- ============================================================
USE lab_consumable;
SET NAMES utf8mb4;

-- ============================================================
-- 1. 系统用户与角色
-- ============================================================

-- 角色表：系统管理员 / 实验室管理员 / 教师
DROP TABLE IF EXISTS sys_role;
CREATE TABLE sys_role (
    id          INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    role_name   VARCHAR(50) NOT NULL COMMENT '角色名称，如管理员、实验室管理员、教师',
    description VARCHAR(200) NULL COMMENT '角色说明'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统角色表';

-- 用户表
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
    id          INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    username    VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号',
    password    VARCHAR(100) NOT NULL COMMENT '登录密码（建议加密存储）',
    real_name   VARCHAR(50) NOT NULL COMMENT '真实姓名',
    role_id     INT NOT NULL COMMENT '角色ID，关联sys_role',
    lab_id      INT NULL COMMENT '所属实验室ID，实验室管理员使用',
    phone       VARCHAR(20) NULL COMMENT '联系电话',
    email       VARCHAR(100) NULL COMMENT '邮箱',
    status      TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用 0停用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- ============================================================
-- 2. 实验室与耗材基础信息
-- ============================================================

-- 实验室表
DROP TABLE IF EXISTS lab;
CREATE TABLE lab (
    id            INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    lab_name      VARCHAR(100) NOT NULL COMMENT '实验室名称',
    lab_code      VARCHAR(50) NOT NULL UNIQUE COMMENT '实验室编号',
    location      VARCHAR(200) NULL COMMENT '实验室地点',
    principal_id  INT NULL COMMENT '负责人用户ID，对应sys_user',
    danger_level  TINYINT NOT NULL DEFAULT 0 COMMENT '危险等级：0-普通 1-含危险化学品',
    remark        VARCHAR(200) NULL COMMENT '备注信息'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实验室信息表';

-- 耗材基础信息表
DROP TABLE IF EXISTS consumable;
CREATE TABLE consumable (
    id               INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    name             VARCHAR(100) NOT NULL COMMENT '耗材名称',
    category         VARCHAR(50) NOT NULL COMMENT '耗材类别：试剂、器皿、一般耗材等',
    spec             VARCHAR(100) NULL COMMENT '规格型号',
    unit             VARCHAR(20) NOT NULL COMMENT '计量单位：瓶、盒、个等',
    is_dangerous     TINYINT NOT NULL DEFAULT 0 COMMENT '是否危险化学品：0否 1是',
    storage_require  VARCHAR(200) NULL COMMENT '存储要求，如避光、冷藏等',
    validity_period  INT NULL COMMENT '保质期天数，可选',
    remark           VARCHAR(200) NULL COMMENT '备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='耗材基础信息表';

-- consumable 表新增 returnable 字段
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

-- ============================================================
-- 3. 采购计划与入库
-- ============================================================

-- 采购计划主表
DROP TABLE IF EXISTS purchase_plan;
CREATE TABLE purchase_plan (
    id              INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    lab_id          INT NOT NULL COMMENT '申请实验室ID',
    apply_user_id   INT NOT NULL COMMENT '申请人ID，实验室管理员',
    total_amount    DECIMAL(12,2) NULL COMMENT '预算总金额',
    status          TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0草稿 1待审核 2已通过 3已退回',
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    audit_user_id   INT NULL COMMENT '审核人ID，系统管理员',
    audit_time      DATETIME NULL COMMENT '审核时间',
    audit_comment   VARCHAR(200) NULL COMMENT '审核意见'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购计划主表';

-- 采购计划明细表
DROP TABLE IF EXISTS purchase_plan_item;
CREATE TABLE purchase_plan_item (
    id              INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    plan_id         INT NOT NULL COMMENT '采购计划ID',
    consumable_id   INT NOT NULL COMMENT '耗材ID',
    plan_quantity   INT NOT NULL COMMENT '计划采购数量',
    plan_price      DECIMAL(10,2) NULL COMMENT '计划单价',
    remark          VARCHAR(200) NULL COMMENT '备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购计划明细表';

-- 入库单主表
DROP TABLE IF EXISTS inbound_order;
CREATE TABLE inbound_order (
    id               INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    plan_id          INT NULL COMMENT '关联采购计划ID，可为空',
    lab_id           INT NOT NULL COMMENT '入库实验室ID',
    inbound_user_id  INT NOT NULL COMMENT '入库操作人ID',
    supplier         VARCHAR(100) NULL COMMENT '供应商名称',
    inbound_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入库时间',
    status           TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1已入库'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='入库单主表';

-- 入库明细表
DROP TABLE IF EXISTS inbound_item;
CREATE TABLE inbound_item (
    id              INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    inbound_id      INT NOT NULL COMMENT '入库单ID',
    consumable_id   INT NOT NULL COMMENT '耗材ID',
    batch_no        VARCHAR(50) NULL COMMENT '批次号',
    quantity        INT NOT NULL COMMENT '入库数量',
    unit_price      DECIMAL(10,2) NULL COMMENT '入库单价',
    product_date    DATE NULL COMMENT '生产日期',
    expire_date     DATE NULL COMMENT '失效日期'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='入库明细表';

-- ============================================================
-- 4. 库存、出库、归还、报废
-- ============================================================

-- 库存表：按 实验室 + 耗材 维度
DROP TABLE IF EXISTS stock;
CREATE TABLE stock (
    id               INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    lab_id           INT NOT NULL COMMENT '实验室ID',
    consumable_id    INT NOT NULL COMMENT '耗材ID',
    total_quantity   INT NOT NULL DEFAULT 0 COMMENT '当前库存数量',
    safe_quantity    INT NOT NULL DEFAULT 0 COMMENT '安全库存量',
    warning_quantity INT NOT NULL DEFAULT 0 COMMENT '预警库存量'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存表（实验室+耗材）';

-- 出库单（领用）主表
DROP TABLE IF EXISTS outbound_order;
CREATE TABLE outbound_order (
    id                   INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    lab_id               INT NOT NULL COMMENT '所属实验室ID',
    apply_user_id        INT NOT NULL COMMENT '申请人ID，教师',
    course_name          VARCHAR(100) NULL COMMENT '课程名称',
    class_name           VARCHAR(100) NULL COMMENT '班级信息',
    purpose              VARCHAR(200) NULL COMMENT '用途说明',
    status               TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待审核 1已通过 2已驳回 3已出库',
    create_time          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    audit_user_id        INT NULL COMMENT '审核人ID，实验室管理员',
    audit_time           DATETIME NULL COMMENT '审核时间',
    second_audit_user_id INT NULL COMMENT '第二审核人ID（五双管理复核人）',
    second_audit_time    DATETIME NULL COMMENT '第二审核时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='出库单主表（领用申请）';

-- 出库明细表
DROP TABLE IF EXISTS outbound_item;
CREATE TABLE outbound_item (
    id               INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    outbound_id      INT NOT NULL COMMENT '出库单ID',
    consumable_id    INT NOT NULL COMMENT '耗材ID',
    quantity         INT NOT NULL COMMENT '领用数量',
    should_return    TINYINT NOT NULL DEFAULT 0 COMMENT '是否需要归还：0否 1是',
    remark           VARCHAR(200) NULL COMMENT '备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='出库明细表';

-- 归还记录表
DROP TABLE IF EXISTS return_record;
CREATE TABLE return_record (
    id               INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    outbound_item_id INT NOT NULL COMMENT '对应出库明细ID',
    return_user_id   INT NOT NULL COMMENT '归还人ID，教师',
    return_quantity  INT NOT NULL COMMENT '归还数量',
    apply_time       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '归还申请时间',
    check_user_id    INT NULL COMMENT '审核人ID，实验室管理员',
    check_time       DATETIME NULL COMMENT '审核时间',
    status           TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待审核 1已通过 2已驳回',
    feedback         VARCHAR(200) NULL COMMENT '使用反馈，如破损、质量问题'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='归还记录表';

-- 报废记录表
DROP TABLE IF EXISTS scrap_record;
CREATE TABLE scrap_record (
    id               INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    lab_id           INT NOT NULL COMMENT '实验室ID',
    consumable_id    INT NOT NULL COMMENT '耗材ID',
    quantity         INT NOT NULL COMMENT '报废数量',
    reason           VARCHAR(200) NOT NULL COMMENT '报废原因：过期/损坏/规定报废等',
    apply_user_id    INT NOT NULL COMMENT '申请人ID，实验室管理员',
    apply_time       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    audit_user_id    INT NULL COMMENT '审核人ID，系统管理员或复核人',
    audit_time       DATETIME NULL COMMENT '审核时间',
    status           TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待审核 1已通过 2已驳回'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报废记录表';

-- ============================================================
-- 5. 盘点（落实“五双”中的双人检查）
-- ============================================================

-- 盘点单主表
DROP TABLE IF EXISTS inventory_check;
CREATE TABLE inventory_check (
    id           INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    lab_id       INT NOT NULL COMMENT '实验室ID',
    period       VARCHAR(50) NOT NULL COMMENT '盘点周期，如2025-上学期',
    checker1_id  INT NOT NULL COMMENT '盘点人1 ID',
    checker2_id  INT NOT NULL COMMENT '盘点人2 ID',
    status       TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0进行中 1已完成',
    check_time   DATETIME NULL COMMENT '盘点完成时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存盘点主表';

-- 盘点明细表
DROP TABLE IF EXISTS inventory_check_item;
CREATE TABLE inventory_check_item (
    id              INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    inventory_id    INT NOT NULL COMMENT '盘点单ID',
    consumable_id   INT NOT NULL COMMENT '耗材ID',
    system_quantity INT NOT NULL COMMENT '系统记录数量',
    real_quantity   INT NOT NULL COMMENT '实际盘点数量',
    diff_quantity   INT NOT NULL COMMENT '差异数量=实际-系统',
    remark          VARCHAR(200) NULL COMMENT '备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存盘点明细表';

-- ============================================================
-- 6. 教师课程与班级表（扩展）
-- ============================================================

-- 教师课程表
DROP TABLE IF EXISTS teacher_course;
CREATE TABLE IF NOT EXISTS teacher_course (
    id          INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    teacher_id  INT NOT NULL COMMENT '教师用户ID',
    course_name VARCHAR(100) NOT NULL COMMENT '课程名称',
    course_code VARCHAR(50)  NULL COMMENT '课程编号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教师所授课程表';

-- 教师班级表
DROP TABLE IF EXISTS teacher_class;
CREATE TABLE IF NOT EXISTS teacher_class (
    id          INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    teacher_id  INT NOT NULL COMMENT '教师用户ID',
    class_name  VARCHAR(100) NOT NULL COMMENT '班级名称',
    class_code  VARCHAR(50)  NULL COMMENT '班级编号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教师所授班级表';

-- ============================================================
-- 7. 教师使用反馈表（扩展）
-- ============================================================

-- 教师使用反馈表
DROP TABLE IF EXISTS usage_feedback;
CREATE TABLE IF NOT EXISTS usage_feedback (
    id                 INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    outbound_order_id  INT         NOT NULL COMMENT '领用单ID',
    user_id            INT         NOT NULL COMMENT '反馈人（教师）',
    content            VARCHAR(500) NOT NULL COMMENT '反馈内容',
    category           VARCHAR(50) NOT NULL DEFAULT '其他' COMMENT '反馈分类',
    feedback_status    TINYINT NOT NULL DEFAULT 0 COMMENT '处理状态：0未查看 1已查看 2已处理',
    admin_reply        VARCHAR(500) NULL COMMENT '管理员回复',
    create_time        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '首次提交时间',
    update_time        DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    UNIQUE KEY uk_order_user (outbound_order_id, user_id),
    CONSTRAINT fk_uf_order FOREIGN KEY (outbound_order_id) REFERENCES outbound_order (id),
    CONSTRAINT fk_uf_user FOREIGN KEY (user_id) REFERENCES sys_user (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教师使用反馈（按领用单）';

-- ============================================================
-- 8. 操作日志
-- ============================================================

-- 系统操作日志表
DROP TABLE IF EXISTS sys_log;
CREATE TABLE sys_log (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id     INT NULL COMMENT '操作人ID',
    action      VARCHAR(100) NOT NULL COMMENT '操作类型，如新增耗材、审核采购等',
    detail      VARCHAR(500) NULL COMMENT '操作详情',
    ip_address  VARCHAR(50) NULL COMMENT '操作IP',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统操作日志表';

-- ============================================================
-- 9. 外键约束
-- ============================================================

-- 先删除已有的外键约束，避免重复创建
SET FOREIGN_KEY_CHECKS = 0;

-- 再重新添加外键约束
ALTER TABLE sys_user
    ADD CONSTRAINT fk_user_role
        FOREIGN KEY (role_id) REFERENCES sys_role(id),
    ADD CONSTRAINT fk_user_lab
        FOREIGN KEY (lab_id) REFERENCES lab(id);
        
ALTER TABLE lab
    ADD CONSTRAINT fk_lab_principal
        FOREIGN KEY (principal_id) REFERENCES sys_user(id);
        
ALTER TABLE purchase_plan
    ADD CONSTRAINT fk_plan_lab
        FOREIGN KEY (lab_id) REFERENCES lab(id),
    ADD CONSTRAINT fk_plan_apply_user
        FOREIGN KEY (apply_user_id) REFERENCES sys_user(id),
    ADD CONSTRAINT fk_plan_audit_user
        FOREIGN KEY (audit_user_id) REFERENCES sys_user(id);
        
ALTER TABLE purchase_plan_item
    ADD CONSTRAINT fk_plan_item_plan
        FOREIGN KEY (plan_id) REFERENCES purchase_plan(id),
    ADD CONSTRAINT fk_plan_item_consumable
        FOREIGN KEY (consumable_id) REFERENCES consumable(id);
        
ALTER TABLE inbound_order
    ADD CONSTRAINT fk_inbound_plan
        FOREIGN KEY (plan_id) REFERENCES purchase_plan(id),
    ADD CONSTRAINT fk_inbound_lab
        FOREIGN KEY (lab_id) REFERENCES lab(id),
    ADD CONSTRAINT fk_inbound_user
        FOREIGN KEY (inbound_user_id) REFERENCES sys_user(id);
        
ALTER TABLE inbound_item
    ADD CONSTRAINT fk_inbound_item_order
        FOREIGN KEY (inbound_id) REFERENCES inbound_order(id),
    ADD CONSTRAINT fk_inbound_item_consumable
        FOREIGN KEY (consumable_id) REFERENCES consumable(id);
        
ALTER TABLE stock
    ADD CONSTRAINT fk_stock_lab
        FOREIGN KEY (lab_id) REFERENCES lab(id),
    ADD CONSTRAINT fk_stock_consumable
        FOREIGN KEY (consumable_id) REFERENCES consumable(id);
        
ALTER TABLE outbound_order
    ADD CONSTRAINT fk_outbound_lab
        FOREIGN KEY (lab_id) REFERENCES lab(id),
    ADD CONSTRAINT fk_outbound_apply_user
        FOREIGN KEY (apply_user_id) REFERENCES sys_user(id),
    ADD CONSTRAINT fk_outbound_audit_user
        FOREIGN KEY (audit_user_id) REFERENCES sys_user(id),
    ADD CONSTRAINT fk_outbound_second_audit_user
        FOREIGN KEY (second_audit_user_id) REFERENCES sys_user(id);
        
ALTER TABLE outbound_item
    ADD CONSTRAINT fk_outbound_item_order
        FOREIGN KEY (outbound_id) REFERENCES outbound_order(id),
    ADD CONSTRAINT fk_outbound_item_consumable
        FOREIGN KEY (consumable_id) REFERENCES consumable(id);
        
ALTER TABLE return_record
    ADD CONSTRAINT fk_return_outbound_item
        FOREIGN KEY (outbound_item_id) REFERENCES outbound_item(id),
    ADD CONSTRAINT fk_return_user
        FOREIGN KEY (return_user_id) REFERENCES sys_user(id),
    ADD CONSTRAINT fk_return_check_user
        FOREIGN KEY (check_user_id) REFERENCES sys_user(id);
        
ALTER TABLE scrap_record
    ADD CONSTRAINT fk_scrap_lab
        FOREIGN KEY (lab_id) REFERENCES lab(id),
    ADD CONSTRAINT fk_scrap_consumable
        FOREIGN KEY (consumable_id) REFERENCES consumable(id),
    ADD CONSTRAINT fk_scrap_apply_user
        FOREIGN KEY (apply_user_id) REFERENCES sys_user(id),
    ADD CONSTRAINT fk_scrap_audit_user
        FOREIGN KEY (audit_user_id) REFERENCES sys_user(id);
        
ALTER TABLE inventory_check
    ADD CONSTRAINT fk_inventory_lab
        FOREIGN KEY (lab_id) REFERENCES lab(id),
    ADD CONSTRAINT fk_inventory_checker1
        FOREIGN KEY (checker1_id) REFERENCES sys_user(id),
    ADD CONSTRAINT fk_inventory_checker2
        FOREIGN KEY (checker2_id) REFERENCES sys_user(id);
        
ALTER TABLE inventory_check_item
    ADD CONSTRAINT fk_inventory_item_inventory
        FOREIGN KEY (inventory_id) REFERENCES inventory_check(id),
    ADD CONSTRAINT fk_inventory_item_consumable
        FOREIGN KEY (consumable_id) REFERENCES consumable(id);
        
ALTER TABLE teacher_course
    ADD CONSTRAINT fk_teacher_course_user
        FOREIGN KEY (teacher_id) REFERENCES sys_user(id);
        
ALTER TABLE teacher_class
    ADD CONSTRAINT fk_teacher_class_user
        FOREIGN KEY (teacher_id) REFERENCES sys_user(id);
        
ALTER TABLE sys_log
    ADD CONSTRAINT fk_log_user
        FOREIGN KEY (user_id) REFERENCES sys_user(id);

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 数据库结构创建完成
-- ============================================================