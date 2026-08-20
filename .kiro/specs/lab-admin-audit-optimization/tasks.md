# 实现计划：实验室管理员端领用/归还审核模块优化

## 概述

按照设计文档，分 7 个任务组逐步实现：数据库字段幂等扩展 → ServletOutbound 后端增强 → outboundAudit.jsp 前端重构 → ServletReturn 后端增强 → returnAudit.jsp 前端重构。每个任务组内先实现核心逻辑，再补充测试子任务。

## 任务

- [x] 1. 数据库字段幂等扩展（init() DDL）
  - 在 `ServletOutbound.init()` 中补充幂等 DDL：检测并添加 `outbound_item.returned_quantity INT NOT NULL DEFAULT 0`、`outbound_order.second_audit_user_id INT NULL`、`outbound_order.second_audit_time DATETIME NULL`
  - 在 `ServletReturn` 中新增 `init()` 方法，幂等添加 `return_record.reject_reason VARCHAR(200) NULL`、`outbound_item.returned_quantity`（与 ServletOutbound 共用同一字段，需先检测再添加）、`outbound_order.second_audit_user_id`、`outbound_order.second_audit_time`
  - 统一使用 `information_schema.COLUMNS` 检测字段是否存在，存在则跳过，不存在则执行 `ALTER TABLE`
  - 修改文件：`lab00/src/com/servlet/ServletOutbound.java`、`lab00/src/com/servlet/ServletReturn.java`
  - _需求：12.1、12.2、12.3、12.4_

  - [ ]* 1.1 编写属性测试：init() 幂等性
    - **属性 10：init() 幂等性**
    - 多次调用 `ServletOutbound.init()` 和 `ServletReturn.init()`，断言不抛出异常，且目标字段在 `information_schema.COLUMNS` 中有且仅有一条记录
    - **验证：需求 12.3、12.4**

- [x] 2. ServletOutbound.listPending 扩展（多参数过滤 + has_dangerous）
  - 重写 `listPending` 方法，将原硬编码 `status IN (0,1,2)` 改为动态条件构建：
    - 无 `status` 参数时默认过滤 `status IN (0,1,2,4)`（排除草稿 -1 和已出库 3）
    - 有 `status` 参数时精确匹配 `outbound_order.status=?`
    - 有 `order_id` 参数时精确匹配 `outbound_order.id=?`
    - 有 `applicant` 参数时对 `sys_user.real_name` 做 `LIKE %keyword%` 模糊匹配
    - 多条件以 AND 组合
  - 在 SELECT 中新增子查询字段 `has_dangerous`：判断该申请的 `outbound_item` 中是否存在 `consumable.is_dangerous=1` 的明细
  - 将查询结果改用 `MapListHandler` 返回（原 `BeanListHandler<OutboundOrder>` 无法携带 `has_dangerous` 扩展字段）
  - 修改文件：`lab00/src/com/servlet/ServletOutbound.java`
  - _需求：1.1、1.2、1.4、2.3、2.4、2.5、3.3_

  - [ ]* 2.1 编写属性测试：listPending 状态过滤一致性
    - **属性 1：listPending 状态过滤一致性**
    - 对随机 `status` 值（0/1/2/4），断言返回记录的 `status` 字段全部等于传入值
    - **验证：需求 1.2**

  - [ ]* 2.2 编写属性测试：单号精确匹配
    - **属性 2：单号搜索精确匹配**
    - 对随机 `order_id`，断言返回记录数 ≤ 1 且 `id` 精确等于传入值
    - **验证：需求 2.3**

  - [ ]* 2.3 编写属性测试：申请人模糊搜索包含性
    - **属性 3：申请人模糊搜索包含性**
    - 对随机 `applicant` 关键词，断言返回记录的 `apply_user_name` 均包含该关键词
    - **验证：需求 2.4**

  - [ ]* 2.4 编写属性测试：has_dangerous 字段完整性
    - **属性 4：has_dangerous 字段完整性**
    - 对任意返回记录，断言 `has_dangerous` 存在且值为 0 或 1，与实际明细中 `is_dangerous=1` 的存在性严格一致
    - **验证：需求 3.3**

- [x] 3. ServletOutbound.audit2 和 doOutbound 增强
  - [x] 3.1 修改 `audit2` 方法：二审通过时将 `outbound_order.status` 更新为 `4`（而非仅记录 `second_audit_user_id`），同时记录 `second_audit_user_id` 和 `second_audit_time`；前置条件校验 `status=1` 且含危化品明细，否则返回 `409`
    - 修改文件：`lab00/src/com/servlet/ServletOutbound.java`
    - _需求：4.3_

  - [x] 3.2 修改 `doOutbound` 方法：将出库前置条件改为严格状态校验——普通申请要求 `status=1`，危化品申请要求 `status=4`；不满足时返回 `409` 并提示「审核未完成，不可出库」；同时将 `UPDATE outbound_order SET status=3` 的 WHERE 条件从 `status=1` 改为 `status IN (1,4)` 以兼容两种合法状态
    - 修改文件：`lab00/src/com/servlet/ServletOutbound.java`
    - _需求：4.6、5.1_

  - [ ]* 3.3 编写属性测试：出库前置条件守卫
    - **属性 5：出库前置条件守卫**
    - 对 `status` 不满足出库条件的申请调用 `doOutbound`，断言返回 `409` 且 `stock.total_quantity` 不变
    - **验证：需求 4.6、5.1**

- [x] 4. outboundAudit.jsp 重构（筛选栏 + 双板块 + 动态按钮）
  - [x] 4.1 重构筛选栏：将原单一搜索框拆分为「单号」和「申请人」两个独立输入框；状态下拉选项扩展为「全部/待初审/初审通过/已驳回/二审通过/已出库」；`doSearch()` 函数分别传递 `status`、`order_id`（自动去除 `#`）、`applicant` 参数；「重置」按钮清空所有输入并重新加载
    - 修改文件：`lab00/web/outbound/outboundAudit.jsp`
    - _需求：1.1、2.1、2.2、2.6_

  - [x] 4.2 实现双板块展示：在 `onLoadSuccess` 回调中根据 `has_dangerous` 字段将数据分发到 `#dgDanger`（含危险品，黄色背景高亮）和 `#dgNormal`（普通耗材）两个独立 datagrid；两个 datagrid 共用同一批数据，无需二次请求
    - 修改文件：`lab00/web/outbound/outboundAudit.jsp`
    - _需求：3.1、3.2、3.4_

  - [x] 4.3 实现行内操作列动态渲染：在两个 datagrid 的操作列 `formatter` 中根据 `status` 和 `has_dangerous` 动态渲染按钮——`status=0` 显示「初审通过/驳回」；普通申请 `status=1` 显示可点击「执行出库」；危化品申请 `status=1` 显示「危险品二审通过」和置灰「执行出库」；`status=4` 显示可点击「执行出库」；`status=2/3` 显示只读标签；置灰按钮通过 `disabled` 属性 + CSS 实现，点击不触发请求
    - 修改文件：`lab00/web/outbound/outboundAudit.jsp`
    - _需求：4.2、4.4、4.5、5.1、5.2、5.3_

- [ ] 5. 检查点 — 确保所有测试通过
  - 确保所有测试通过，如有疑问请向用户确认。

- [x] 6. ServletReturn.listAll 新增（多维过滤分页）
  - 在 `ServletReturn` 的 `doGet` switch 中新增 `case "listAll"` 分支，调用新方法 `listAll()`
  - `listAll()` 方法：查询本实验室（`o.lab_id=?`）所有 `return_record`，支持以下可选过滤参数：`status`（精确）、`consumable_name`（LIKE）、`return_user`（LIKE）、`course_name`（LIKE）、`class_name`（LIKE）；所有参数为空时返回全部记录
  - SELECT 字段在原有基础上新增：`rr.check_time`、`rr.reject_reason`、`cu.real_name AS check_user_name`（LEFT JOIN `sys_user cu ON rr.check_user_id=cu.id`）、`c.is_dangerous`
  - 支持分页（`page`/`rows` 参数）
  - 修改文件：`lab00/src/com/servlet/ServletReturn.java`
  - _需求：6.1、6.2、6.3、7.1、7.2、7.3、7.4、7.5、7.6、7.7、9.1_

  - [ ]* 6.1 编写属性测试：listAll 过滤条件包含性
    - **属性 7：listAll 过滤条件包含性**
    - 对随机非空的 `consumable_name`、`return_user`、`course_name`、`class_name` 参数，断言返回记录对应字段均包含该关键词；所有参数为空时返回全部记录
    - **验证：需求 7.3、7.4、7.6、7.7**

- [x] 7. ServletReturn.auditReturn 增强（数量校验 + reject_reason + 事务回补）
  - [x] 7.1 增强审核通过（`pass=1`）事务逻辑：在现有库存回补基础上，新增步骤——查询 `outbound_item.quantity` 作为上限，校验 `return_quantity > 0`（否则返回 `400`）和 `return_quantity <= outbound_item.quantity`（否则返回 `400`，提示「归还数量不能超过原领用数量，请核对」）；在同一事务中执行 `UPDATE outbound_item SET returned_quantity=returned_quantity+? WHERE id=?`
    - 修改文件：`lab00/src/com/servlet/ServletReturn.java`
    - _需求：8.1、8.2、8.3、11.1、11.2、11.3、11.4_

  - [x] 7.2 增强审核驳回（`pass=0`）逻辑：校验请求参数 `reject_reason` 非空（trim 后长度 > 0），否则返回 `400` 提示「请填写驳回理由」；将 `reject_reason` 写入 `UPDATE return_record SET status=2, check_user_id=?, check_time=NOW(), reject_reason=? WHERE id=? AND status=0`
    - 修改文件：`lab00/src/com/servlet/ServletReturn.java`
    - _需求：10.3、10.4_

  - [ ]* 7.3 编写属性测试：归还数量上限校验
    - **属性 6：归还数量上限校验**
    - 对随机 `return_quantity > outbound_item.quantity` 的场景，断言 `auditReturn(pass=1)` 返回 `400` 且数据库状态不变
    - **验证：需求 8.2**

  - [ ]* 7.4 编写属性测试：审核通过库存回补原子性
    - **属性 8：审核通过库存回补原子性**
    - 对随机合法 `return_quantity`，断言审核通过后 `stock.total_quantity` 和 `outbound_item.returned_quantity` 增量均等于 `return_quantity`；模拟事务中途失败时两者均不变
    - **验证：需求 11.1、11.3、11.4**

  - [ ]* 7.5 编写属性测试：驳回理由存储 Round-Trip
    - **属性 9：驳回理由存储 Round-Trip**
    - 对随机非空字符串（含特殊字符、中文、长字符串），驳回操作完成后查询 `return_record.reject_reason`，断言与传入值字符级别完全相同
    - **验证：需求 10.4**

- [x] 8. returnAudit.jsp 重构（历史记录 + 筛选 + 驳回弹窗 + 危化品标识）
  - [x] 8.1 将列表数据源从 `action=listPending` 改为 `action=listAll`；新增筛选栏：状态下拉（全部/待审核/已通过/已驳回）、耗材名称输入框、归还人输入框、课程/班级输入框；`doSearch()` 传递 `status`、`consumable_name`、`return_user`、`course_name`/`class_name` 参数；「重置」清空所有筛选并重新加载
    - 修改文件：`lab00/web/return/returnAudit.jsp`
    - _需求：6.1、7.1、7.2、7.5_

  - [x] 8.2 扩展列表列：新增「危化品」列（`is_dangerous=1` 显示 ⚠️）、「审核人」列（`check_user_name`）、「审核时间」列（`check_time`）；在页面顶部或操作区域添加说明文字「含危化品的归还申请需双人现场核验后再执行审核通过」
    - 修改文件：`lab00/web/return/returnAudit.jsp`
    - _需求：9.2、9.3、6.3_

  - [x] 8.3 重构驳回弹窗：将原 `doReject()` 中的 `$.messager.confirm` 替换为 EasyUI dialog，内含必填 textarea（`id="rejectReasonInput"`）；前端校验 `reject_reason` trim 后非空，否则阻止提交并提示「请填写驳回理由」；确认后 POST 参数增加 `reject_reason`；前端统一处理 `400`/`409`/`500` 响应码弹窗提示，`200` 时刷新列表并显示成功提示（含回补数量）
    - 修改文件：`lab00/web/return/returnAudit.jsp`
    - _需求：10.1、10.2、10.3、8.4、11.5_

- [x] 9. 最终检查点 — 确保所有测试通过
  - 确保所有测试通过，如有疑问请向用户确认。

## 备注

- 标有 `*` 的子任务为可选测试任务，可跳过以加快 MVP 交付
- 属性测试使用 [jqwik](https://jqwik.net/) 实现，每个属性最少运行 100 次迭代，注释格式：`// Feature: lab-admin-audit-optimization, Property N: {属性描述}`
- Task 3.2 中 `doOutbound` 的 WHERE 条件需同时兼容 `status=1`（普通申请）和 `status=4`（危化品申请），避免遗漏
- Task 6 的 `listAll` 与原有 `listPending` 并存，`listPending` 保留供教师端复用
