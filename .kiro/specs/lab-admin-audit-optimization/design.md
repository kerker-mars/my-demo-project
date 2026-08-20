# 设计文档：实验室管理员端领用/归还审核模块优化

## 概述

本设计针对「计算机实验教学中心耗材管理系统」中实验室管理员端的两个核心审核模块进行优化：

- **领用申请审核**（`outboundAudit.jsp` / `ServletOutbound.java`）：修复筛选失效、拆分搜索框、实现危化品双板块展示与双审核状态流转、行内操作按钮动态渲染。
- **归还登记审核**（`returnAudit.jsp` / `ServletReturn.java`）：新增历史记录全量查看、多维度筛选、归还数量校验、驳回理由弹窗、危化品 ⚠️ 标识，以及审核通过后的事务性库存回补与 `returned_quantity` 更新。

技术约束：Java 17 + Servlet + JSP + jQuery EasyUI 1.9.14 + 原生 AJAX + MySQL 8.0 + DBUtils + Druid，非 Maven 项目，不引入新框架。

---

## 架构

系统采用经典 MVC 分层：

```
浏览器（JSP + EasyUI + jQuery AJAX）
        ↕ HTTP GET/POST
Servlet 层（ServletOutbound / ServletReturn）
        ↕ JDBC / DBUtils
MySQL 8.0（outbound_order / outbound_item / return_record / stock / consumable / sys_user）
```

数据库字段扩展通过各 Servlet 的 `init()` 方法在应用启动时幂等执行，无需手动 DDL。

### 状态机

**领用申请（outbound_order.status）**

```
草稿(-1) → 待初审(0) → 初审通过(1) → [危化品] 二审通过(4) → 已出库(3)
                     ↘ 已驳回(2)
普通申请：status=1 即可直接出库
危化品申请：status=1 需先二审至 status=4 才可出库
```

**归还记录（return_record.status）**

```
待审核(0) → 已通过(1)（触发库存回补 + returned_quantity 更新）
          ↘ 已驳回(2)（存储 reject_reason）
```

---

## 组件与接口

### ServletOutbound 扩展

#### `init()` — 幂等 DDL

```java
// 新增字段（已存在则跳过）
ALTER TABLE outbound_item ADD COLUMN returned_quantity INT NOT NULL DEFAULT 0
// 已有逻辑：teacher_course / teacher_class 建表、consumable.returnable 字段
```

#### `listPending` — 扩展过滤与 has_dangerous 字段

新增请求参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| `status` | int（可空） | 按 `outbound_order.status` 精确过滤；空则不限 |
| `order_id` | int（可空） | 按 `outbound_order.id` 精确匹配 |
| `applicant` | string（可空） | 按 `sys_user.real_name` LIKE %keyword% 模糊匹配 |

响应新增字段：

| 字段 | 说明 |
|------|------|
| `has_dangerous` | `1`/`0`，该申请是否含危化品明细（子查询） |

SQL 核心逻辑（伪代码）：

```sql
SELECT o.*, u.real_name AS apply_user_name,
  (SELECT COUNT(*) FROM outbound_item i2
   JOIN consumable c2 ON i2.consumable_id=c2.id
   WHERE i2.outbound_id=o.id AND c2.is_dangerous=1) > 0 AS has_dangerous
FROM outbound_order o
LEFT JOIN sys_user u ON o.apply_user_id=u.id
WHERE o.lab_id=?
  [AND o.status=?]          -- status 参数存在时
  [AND o.id=?]              -- order_id 参数存在时
  [AND u.real_name LIKE ?]  -- applicant 参数存在时
ORDER BY o.id DESC LIMIT ?,?
```

状态过滤范围：无 `status` 参数时返回 `status IN (0,1,2,4)`（排除草稿 -1 和已出库 3）。

#### `audit2` — 危化品二审

- 前置条件：`outbound_order.status=1` 且 `has_dangerous=1`
- 操作：`status → 4`，记录 `second_audit_user_id`、`second_audit_time`（需在 `init()` 中幂等添加这两个字段）
- 失败返回 `409`

#### `doOutbound` — 出库前置校验增强

- 普通申请：要求 `status=1`
- 危化品申请：要求 `status=4`
- 不满足时返回 `409`，提示「审核未完成，不可出库」

---

### ServletReturn 扩展

#### `init()` — 幂等 DDL

```java
// 新增字段（已存在则跳过，通过 information_schema 检测）
ALTER TABLE return_record ADD COLUMN reject_reason VARCHAR(200) NULL
ALTER TABLE outbound_item ADD COLUMN returned_quantity INT NOT NULL DEFAULT 0
ALTER TABLE outbound_order ADD COLUMN second_audit_user_id INT NULL
ALTER TABLE outbound_order ADD COLUMN second_audit_time DATETIME NULL
```

#### `listAll` — 新增 action，全量历史记录

请求参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| `page` / `rows` | int | 分页 |
| `status` | int（可空） | 按 `return_record.status` 过滤；空则全部 |
| `consumable_name` | string（可空） | 按 `consumable.name` LIKE %keyword% |
| `return_user` | string（可空） | 按 `sys_user.real_name` LIKE %keyword% |
| `course_name` | string（可空） | 按 `outbound_order.course_name` LIKE %keyword% |
| `class_name` | string（可空） | 按 `outbound_order.class_name` LIKE %keyword% |

响应字段（在原有基础上新增）：

| 字段 | 来源 |
|------|------|
| `check_user_name` | `sys_user.real_name`（通过 `check_user_id` 关联） |
| `check_time` | `return_record.check_time` |
| `reject_reason` | `return_record.reject_reason` |
| `is_dangerous` | `consumable.is_dangerous`（通过 `outbound_item` 关联） |

SQL 核心逻辑（伪代码）：

```sql
SELECT rr.id, rr.return_quantity, rr.feedback, rr.apply_time, rr.status,
       rr.check_time, rr.reject_reason,
       u.real_name AS return_user_name,
       cu.real_name AS check_user_name,
       c.name AS consumable_name, c.unit, c.is_dangerous,
       o.course_name, o.class_name
FROM return_record rr
JOIN outbound_item i ON rr.outbound_item_id=i.id
JOIN outbound_order o ON i.outbound_id=o.id
JOIN consumable c ON i.consumable_id=c.id
JOIN sys_user u ON rr.return_user_id=u.id
LEFT JOIN sys_user cu ON rr.check_user_id=cu.id
WHERE o.lab_id=?
  [AND rr.status=?]
  [AND c.name LIKE ?]
  [AND u.real_name LIKE ?]
  [AND o.course_name LIKE ?]
  [AND o.class_name LIKE ?]
ORDER BY rr.id DESC LIMIT ?,?
```

#### `auditReturn` — 增强校验与事务

审核通过（`pass=1`）事务步骤：

1. 查询 `return_record`（`status=0`）及关联的 `outbound_item.quantity`（原领用数量）
2. 校验 `return_quantity > 0`，否则返回 `400`
3. 校验 `return_quantity <= outbound_item.quantity`，否则返回 `400`
4. `UPDATE return_record SET status=1, check_user_id=?, check_time=NOW() WHERE id=? AND status=0`
5. 回补库存：`UPDATE stock SET total_quantity=total_quantity+? WHERE lab_id=? AND consumable_id=?`（不存在则 INSERT）
6. 更新已归还数量：`UPDATE outbound_item SET returned_quantity=returned_quantity+? WHERE id=?`
7. 任意步骤异常 → `ROLLBACK`，返回 `500`

审核驳回（`pass=0`）步骤：

1. 校验 `reject_reason` 非空，否则返回 `400`
2. `UPDATE return_record SET status=2, check_user_id=?, check_time=NOW(), reject_reason=? WHERE id=? AND status=0`

---

## 数据模型

### 现有表（相关字段）

```
outbound_order: id, lab_id, apply_user_id, course_name, class_name, purpose,
                status(-1/0/1/2/3/4), audit_user_id, audit_time,
                [NEW] second_audit_user_id, [NEW] second_audit_time

outbound_item:  id, outbound_id, consumable_id, quantity, should_return, remark,
                [NEW] returned_quantity INT NOT NULL DEFAULT 0

return_record:  id, outbound_item_id, return_user_id, return_quantity, feedback,
                status(0/1/2), check_user_id, check_time,
                [NEW] reject_reason VARCHAR(200) NULL

stock:          id, lab_id, consumable_id, total_quantity, safe_quantity, warning_quantity

consumable:     id, name, unit, is_dangerous(0/1), returnable, category
sys_user:       id, real_name, lab_id, role_id, status
```

### 字段扩展（通过 init() 幂等执行）

| 表 | 新增字段 | 类型 | 默认值 | 用途 |
|----|---------|------|--------|------|
| `return_record` | `reject_reason` | `VARCHAR(200) NULL` | NULL | 驳回理由 |
| `outbound_item` | `returned_quantity` | `INT NOT NULL` | 0 | 已归还数量 |
| `outbound_order` | `second_audit_user_id` | `INT NULL` | NULL | 二审人 |
| `outbound_order` | `second_audit_time` | `DATETIME NULL` | NULL | 二审时间 |

幂等检测方式（统一模式）：

```java
Object col = DBUtils.QueryScalar(
    "SELECT COUNT(*) FROM information_schema.COLUMNS " +
    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?",
    tableName, columnName);
if (col == null || Integer.parseInt(col.toString()) == 0) {
    DBUtils.Update("ALTER TABLE " + tableName + " ADD COLUMN " + columnDef);
}
```

---

## 前端设计

### outboundAudit.jsp 重构

**布局**：EasyUI Layout，north（筛选栏 + 操作栏）+ center（双板块列表）+ east（明细面板）

**筛选栏**：
- 状态下拉（全部/待初审/初审通过/已驳回/二审通过/已出库）
- 单号输入框（自动去除 `#`）
- 申请人输入框（模糊匹配）
- 查询 / 重置按钮

**双板块展示**：

```
┌─────────────────────────────────────────────┐
│ ⚠️ 含危险品领用申请（黄色背景高亮）           │
│  [datagrid #dgDanger]                        │
├─────────────────────────────────────────────┤
│ 📦 普通耗材领用申请                           │
│  [datagrid #dgNormal]                        │
└─────────────────────────────────────────────┘
```

前端根据 `has_dangerous` 字段将数据分发到两个 datagrid，无需二次请求。

**行内操作列（formatter 动态渲染）**：

| 状态 | 普通申请 | 危化品申请 |
|------|---------|-----------|
| `status=0` | 初审通过 / 驳回 | 初审通过 / 驳回 |
| `status=1` | ✅ 执行出库 | 危险品二审通过（出库置灰） |
| `status=4` | — | ✅ 执行出库 |
| `status=2` | 已驳回（只读） | 已驳回（只读） |
| `status=3` | 已出库（只读） | 已出库（只读） |

置灰按钮通过 `disabled` 属性 + CSS 实现，点击不触发请求。

### returnAudit.jsp 重构

**布局**：EasyUI Layout，north（筛选栏 + 操作栏 + 危化品说明）+ center（历史记录列表）+ east（详情面板）

**筛选栏**：
- 状态下拉（全部/待审核/已通过/已驳回）
- 耗材名称输入框
- 归还人输入框
- 课程/班级输入框
- 查询 / 重置按钮

**列表列**：

| 列 | 说明 |
|----|------|
| 归还ID | `#id` |
| 危化品 | `is_dangerous=1` 显示 ⚠️ |
| 归还人 | `return_user_name` |
| 耗材名称 | `consumable_name` |
| 归还数量 | `return_quantity` |
| 课程/班级 | `course_name` / `class_name` |
| 提交时间 | `apply_time` |
| 状态 | 彩色徽章 |
| 审核人 | `check_user_name`（已审核时显示） |
| 审核时间 | `check_time` |

**驳回弹窗**：

```javascript
function doReject() {
    // 1. 校验选中行 status=0
    // 2. 弹出 EasyUI dialog，含 textarea（必填）
    // 3. 前端校验 reject_reason 非空（trim 后长度 > 0）
    // 4. POST /ServletReturn?action=audit，参数：id, pass=0, reject_reason
}
```

**操作按钮状态**：
- 「审核通过」和「驳回」仅对 `status=0` 的行可用
- 非待审核行点击时弹窗提示「只能审核待审核状态的记录」

---

## 正确性属性

*属性是在系统所有有效执行中都应成立的特征或行为——本质上是关于系统应该做什么的形式化陈述。属性是人类可读规范与机器可验证正确性保证之间的桥梁。*

### 属性 1：listPending 状态过滤一致性

*对任意* 非空 `status` 参数值，`ServletOutbound.listPending` 返回的所有记录的 `status` 字段均等于该参数值，不存在状态不匹配的记录。

**验证：需求 1.2**

---

### 属性 2：单号搜索精确匹配

*对任意* `order_id` 参数值，`ServletOutbound.listPending` 返回的所有记录的 `id` 字段均精确等于该值（结果为 0 条或 1 条）。

**验证：需求 2.3**

---

### 属性 3：申请人模糊搜索包含性

*对任意* `applicant` 关键词，`ServletOutbound.listPending` 返回的所有记录的 `apply_user_name` 字段均包含该关键词（大小写不敏感）。

**验证：需求 2.4**

---

### 属性 4：has_dangerous 字段完整性

*对任意* `listPending` 返回的记录，`has_dangerous` 字段存在且值为 `0` 或 `1`，其值与该申请的 `outbound_item` 中是否存在 `consumable.is_dangerous=1` 的明细严格一致。

**验证：需求 3.3**

---

### 属性 5：出库前置条件守卫

*对任意* `outbound_order`，若其 `status` 不满足出库条件（普通申请 `status≠1`，危化品申请 `status≠4`），则调用 `doOutbound` 必须返回错误码 `409`，且 `stock.total_quantity` 不发生变化。

**验证：需求 4.6、5.1**

---

### 属性 6：归还数量上限校验

*对任意* `return_record`，若 `return_quantity` 大于对应 `outbound_item.quantity`，则 `auditReturn(pass=1)` 必须返回错误码 `400`，且数据库状态不变。

**验证：需求 8.2**

---

### 属性 7：listAll 过滤条件包含性

*对任意* 非空的 `consumable_name`、`return_user`、`course_name`、`class_name` 参数，`ServletReturn.listAll` 返回的所有记录中对应字段均包含该关键词；当所有参数均为空时，返回本实验室全部记录。

**验证：需求 7.3、7.4、7.6、7.7**

---

### 属性 8：审核通过库存回补原子性

*对任意* 合法的 `return_record`（`return_quantity > 0` 且 `≤ outbound_item.quantity`），审核通过后：
- `stock.total_quantity` 的增量恰好等于 `return_quantity`
- `outbound_item.returned_quantity` 的增量恰好等于 `return_quantity`
- 若事务中任意步骤失败，上述两个字段均不发生变化（原子性）

**验证：需求 11.1、11.3、11.4**

---

### 属性 9：驳回理由存储 Round-Trip

*对任意* 非空字符串 `reject_reason`，驳回操作完成后，查询 `return_record.reject_reason` 得到的值与传入值完全相同（字符级别一致）。

**验证：需求 10.4**

---

### 属性 10：init() 幂等性

*对任意* 次数的 `ServletReturn.init()` 或 `ServletOutbound.init()` 调用，均不抛出异常，且目标字段在数据库中有且仅有一个（不重复添加）。

**验证：需求 12.3、12.4**

---

## 错误处理

| 场景 | HTTP 状态 | 返回码 | 提示信息 |
|------|-----------|--------|---------|
| 未登录 / Session 失效 | 200 | `401` | 未登录 |
| 参数缺失或格式错误 | 200 | `400` | 参数错误：xxx |
| 归还数量 ≤ 0 | 200 | `400` | 归还数量必须大于 0 |
| 归还数量超过原领用数量 | 200 | `400` | 归还数量不能超过原领用数量，请核对 |
| 驳回理由为空 | 200 | `400` | 请填写驳回理由 |
| 状态冲突（已被处理） | 200 | `409` | 状态已变更，请刷新后重试 |
| 出库前置条件不满足 | 200 | `409` | 审核未完成，不可出库 |
| 事务失败 / 数据库异常 | 200 | `500` | 操作失败：{异常信息} |

前端统一处理：
- `400`：`$.messager.alert('提示', res.msg, 'warning')`
- `409`：`$.messager.alert('提示', res.msg, 'warning')`
- `500`：`$.messager.alert('错误', res.msg, 'error')`
- `200`：`$.messager.show({...})` 成功提示 + `datagrid.reload()`

---

## 测试策略

### 单元测试（示例测试）

针对具体场景的确定性验证：

- `listPending` 无参数时返回 `status IN (0,1,2,4)` 的记录
- `audit2` 对 `status=1` 且含危化品的申请成功将 `status` 更新为 `4`
- `auditReturn` 驳回时 `reject_reason` 为空返回 `400`
- `doReject()` 前端函数在 `reject_reason` 为空时阻止提交
- 驳回弹窗在确认前校验必填项

### 属性测试（Property-Based Testing）

使用 [jqwik](https://jqwik.net/)（Java 属性测试库）实现，每个属性最少运行 100 次迭代。

每个属性测试用注释标注：
```java
// Feature: lab-admin-audit-optimization, Property N: {属性描述}
```

**属性 1 — listPending 状态过滤一致性**
- 生成器：随机 `status` 值（0/1/2/4）+ 随机数量的 `outbound_order` 测试数据
- 断言：返回记录的 `status` 字段全部等于传入值

**属性 2 & 3 — 搜索精确/模糊匹配**
- 生成器：随机 `order_id` 或随机姓名关键词
- 断言：返回记录满足对应匹配条件

**属性 4 — has_dangerous 字段完整性**
- 生成器：随机申请（含/不含危化品明细）
- 断言：`has_dangerous` 与实际明细一致

**属性 5 — 出库前置条件守卫**
- 生成器：随机 `status` 值（排除合法出库状态）
- 断言：`doOutbound` 返回 `409`，`stock` 不变

**属性 6 — 归还数量上限校验**
- 生成器：随机 `return_quantity > original_quantity`
- 断言：`auditReturn` 返回 `400`，数据库不变

**属性 7 — listAll 过滤包含性**
- 生成器：随机关键词 + 随机归还记录数据集
- 断言：返回记录对应字段均包含关键词

**属性 8 — 库存回补原子性**
- 生成器：随机合法 `return_quantity`
- 断言：`stock.total_quantity` 和 `returned_quantity` 增量等于 `return_quantity`；模拟失败时两者均不变

**属性 9 — 驳回理由 Round-Trip**
- 生成器：随机非空字符串（含特殊字符、中文、长字符串）
- 断言：数据库存储值与传入值完全相同

**属性 10 — init() 幂等性**
- 生成器：随机调用次数（1~10）
- 断言：不抛出异常，字段在 `information_schema` 中只存在一次

### 集成测试

- 完整审核流程（提交 → 初审 → 二审 → 出库）端到端验证
- 事务回滚：模拟库存更新失败，验证 `return_record` 状态未变更
- 并发审核：两个管理员同时审核同一条记录，验证乐观锁（`WHERE status=0`）保证只有一个成功
