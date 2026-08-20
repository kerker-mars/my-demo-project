-- 教师「使用反馈」：对本人领用单(outbound_order)提交文字反馈（与归还记录的 feedback 独立）
USE lab_consumable;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS usage_feedback (
    id                 INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    outbound_order_id  INT         NOT NULL COMMENT '领用单ID',
    user_id            INT         NOT NULL COMMENT '反馈人（教师）',
    content            VARCHAR(500) NOT NULL COMMENT '反馈内容',
    create_time        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '首次提交时间',
    update_time        DATETIME    NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
    UNIQUE KEY uk_order_user (outbound_order_id, user_id),
    CONSTRAINT fk_uf_order FOREIGN KEY (outbound_order_id) REFERENCES outbound_order (id),
    CONSTRAINT fk_uf_user FOREIGN KEY (user_id) REFERENCES sys_user (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教师使用反馈（按领用单）';
