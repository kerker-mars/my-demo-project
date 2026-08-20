# 需求文档

## 简介

本功能针对「计算机实验教学中心耗材管理系统」实验室管理员端的两个核心模块进行优化：

1. **领用申请审核模块**（`outboundAudit.jsp` / `ServletOutbound`）：修复筛选/搜索功能失效问题，优化危化品领用的双审核流程，明确按钮状态控制与功能边界提示。
2. **归还登记审核模块**（`returnAudit.jsp` / `ServletReturn`）：新增历史记录查看、多维度筛选搜索、业务逻辑校验（归还数量上限、危化品双人审核标识）、驳回理由填写，以及审核通过后的库存回补与领用单已归还数量更新。

技术栈：Java 17 + Servlet + JSP + jQuery EasyUI 1.9.14 + MySQL 8.0 + JDBC + DBUtils + Druid 连接池，非 Maven 项目。

---

## 词汇表

- **Lab_Admin_System**：实验室管理员端耗材管理系统整体
- **OutboundAuditPage**：领用申请审核页面（`outboundAudit.jsp`）
- **ReturnAuditPage**：归还登记审核页面（`returnAudit.jsp`）
- **ServletOutbound**：处理领用申请相关请求的后端 Servlet（`ServletOutbound.java`）
- **ServletReturn**：处理归还登记相关请求的后端 Servlet（`ServletReturn.java`）
- **OutboundOrder**：领用申请主单（对应数据库表 `outbound_order`）
- **OutboundItem**：领用申请明细（对应数据库表 `outbound_item`）
- **ReturnRecord**：归还记录（对应数据库表 `return_record`）
- **Stock**：库存记录（对应数据库表 `stock`）
- **Consumable**：耗材基础信息（对应数据库表 `consumable`，字段 `is_dangerous=1` 表示危化品）
- **Lab_Admin**：实验室管理员角色用户
- **Teacher**：教师角色用户（领用申请人/归还人）
- **危化品申请**：`outbound_item` 中存在 `consumable.is_dangerous=1` 明细的领用申请
- **普通申请**：`outbound_item` 中所有明细均为 `consumable.is_dangerous=0` 的领用申请
- **初审**：`outbound_order.status` 从 `0`（待审核）变为 `1`（初审通过）或 `2`（已驳回）的操作
- **二审**：危化品申请专属，`outbound_order.status` 从 `1`（初审通过）变为 `4`（二审通过）的操作
- **执行出库**：`outbound_order.status` 变为 `3`（已出库）并扣减 `stock.total_quantity` 的操作
- **待二审**：危化品申请初审通过后的中间状态（`outbound_order.status=1` 且含危化品明细）
- **已归还数量**：`return_record` 中 `status=1`（已通过）的归还记录对应 `return_quantity` 之和

---

## 需求

### 需求 1：领用申请审核 — 状态筛选修复

**用户故事：** 作为实验室管理员，我希望通过下拉框按状态筛选领用申请列表，以便快速定位特定状态的申请。

#### 验收标准

1. WHEN Lab_Admin 在 OutboundAuditPage 的状态下拉框中选择一个状态值并点击「查询」，THE OutboundAuditPage SHALL 向 ServletOutbound 的 `listPending` 接口传递 `status` 参数。
2. WHEN ServletOutbound 收到包含 `status` 参数的 `listPending` 请求，THE ServletOutbound SHALL 仅返回 `outbound_order.status` 等于该参数值的申请列表。
3. WHEN 筛选结果为空，THE OutboundAuditPage SHALL 在列表区域显示「暂无数据」提示。
4. WHEN Lab_Admin 选择「全部状态」（空值）并查询，THE ServletOutbound SHALL 返回本实验室所有状态的申请列表（不限状态）。

---

### 需求 2：领用申请审核 — 搜索框拆分

**用户故事：** 作为实验室管理员，我希望分别通过单号和申请人姓名进行独立搜索，以便精准定位目标申请。

#### 验收标准

1. THE OutboundAuditPage SHALL 将原有的单一搜索框拆分为「单号搜索」和「申请人搜索」两个独立输入框。
2. WHEN Lab_Admin 在「单号搜索」框中输入包含 `#` 符号的字符串，THE OutboundAuditPage SHALL 在发送请求前自动去除 `#` 符号后再传递给 ServletOutbound。
3. WHEN ServletOutbound 收到 `order_id` 参数，THE ServletOutbound SHALL 按 `outbound_order.id` 精确匹配返回对应申请。
4. WHEN ServletOutbound 收到 `applicant` 参数，THE ServletOutbound SHALL 按 `sys_user.real_name` 进行模糊匹配（`LIKE %keyword%`）返回申请列表。
5. WHEN Lab_Admin 同时填写「单号搜索」和「申请人搜索」，THE ServletOutbound SHALL 将两个条件以 AND 逻辑组合后查询。
6. WHEN Lab_Admin 点击「重置」按钮，THE OutboundAuditPage SHALL 清空所有搜索框和状态筛选，并重新加载完整列表。

---

### 需求 3：领用申请审核 — 危化品申请分区展示

**用户故事：** 作为实验室管理员，我希望领用申请列表按是否含危化品分为两个板块展示，以便优先识别和处理危化品申请。

#### 验收标准

1. THE OutboundAuditPage SHALL 将领用申请列表分为「含危险品领用申请」和「普通耗材领用申请」两个独立板块展示。
2. THE OutboundAuditPage SHALL 对「含危险品领用申请」板块中的每条记录添加黄色背景高亮和 ⚠️ 标识。
3. WHEN ServletOutbound 的 `listPending` 接口返回申请列表，THE ServletOutbound SHALL 在每条记录中包含 `has_dangerous` 字段（值为 `1` 或 `0`），标识该申请是否含危化品明细。
4. THE OutboundAuditPage SHALL 根据 `has_dangerous` 字段将申请分配到对应板块，无需二次请求。

---

### 需求 4：领用申请审核 — 危化品双审核状态流转

**用户故事：** 作为实验室管理员，我希望危化品领用申请经过初审和二审两个步骤才能执行出库，以满足危化品"五双管理"合规要求。

#### 验收标准

1. WHEN Lab_Admin 对含危化品的 OutboundOrder（`status=0`）执行初审通过，THE ServletOutbound SHALL 将 `outbound_order.status` 更新为 `1`（待二审），并记录 `audit_user_id` 和 `audit_time`。
2. WHEN OutboundOrder 的 `status=1` 且 `has_dangerous=1`，THE OutboundAuditPage SHALL 在该记录的操作列显示「危险品二审通过」按钮，而非「执行出库」按钮。
3. WHEN Lab_Admin 点击「危险品二审通过」，THE ServletOutbound SHALL 将 `outbound_order.status` 更新为 `4`（二审通过），并记录 `second_audit_user_id` 和 `second_audit_time`。
4. WHEN OutboundOrder 的 `status=4`，THE OutboundAuditPage SHALL 在该记录的操作列显示可点击的「执行出库」按钮。
5. WHEN Lab_Admin 对普通申请（`has_dangerous=0`）执行初审通过后，THE OutboundAuditPage SHALL 在该记录的操作列直接显示可点击的「执行出库」按钮（`status=1` 即可出库）。
6. IF Lab_Admin 尝试对 `status` 不满足出库前置条件的 OutboundOrder 调用 `doOutbound` 接口，THEN THE ServletOutbound SHALL 返回错误码 `409` 并提示「审核未完成，不可出库」。

---

### 需求 5：领用申请审核 — 出库按钮状态控制与功能提示

**用户故事：** 作为实验室管理员，我希望未完成审核的申请「执行出库」按钮不可点击，并有明确的功能说明，以防止误操作。

#### 验收标准

1. WHEN OutboundOrder 的 `status` 不满足出库条件（普通申请 `status≠1`，危化品申请 `status≠4`），THE OutboundAuditPage SHALL 将该记录对应的「执行出库」按钮渲染为置灰不可点击状态。
2. THE OutboundAuditPage SHALL 在「执行出库」按钮旁显示提示文字：「仅对已审核的领用申请执行出库，自动扣减库存」。
3. WHEN Lab_Admin 点击置灰的「执行出库」按钮，THE OutboundAuditPage SHALL 不发送任何请求。

---

### 需求 6：归还登记审核 — 历史记录查看

**用户故事：** 作为实验室管理员，我希望能查看所有历史归还审核记录（包括已通过和已驳回），以便追溯和核查。

#### 验收标准

1. THE ReturnAuditPage SHALL 默认展示本实验室所有状态（待审核/已通过/已驳回）的归还记录，而非仅展示 `status=0` 的待审核记录。
2. WHEN ServletReturn 收到 `listAll` 请求，THE ServletReturn SHALL 查询 `return_record` 中 `lab_id` 匹配当前管理员所属实验室的所有记录，并支持分页返回。
3. THE ReturnAuditPage SHALL 在列表中展示每条记录的审核状态、审核人姓名（`check_user_id` 关联 `sys_user.real_name`）和审核时间（`check_time`）。

---

### 需求 7：归还登记审核 — 多维度筛选与搜索

**用户故事：** 作为实验室管理员，我希望通过状态、耗材名称、归还人、课程/班级等多个维度筛选归还记录，以便快速定位目标记录。

#### 验收标准

1. THE ReturnAuditPage SHALL 新增状态筛选下拉框，选项包含「全部」「待审核」「已通过」「已驳回」，对应 `return_record.status` 值 `null/0/1/2`。
2. THE ReturnAuditPage SHALL 将原有单一搜索框拆分为「耗材名称」和「归还人」两个独立输入框。
3. WHEN ServletReturn 收到 `consumable_name` 参数，THE ServletReturn SHALL 按 `consumable.name` 进行模糊匹配（`LIKE %keyword%`）过滤结果。
4. WHEN ServletReturn 收到 `return_user` 参数，THE ServletReturn SHALL 按 `sys_user.real_name` 进行模糊匹配（`LIKE %keyword%`）过滤结果。
5. THE ReturnAuditPage SHALL 新增课程/班级筛选下拉框或输入框，对应 `outbound_order.course_name` 和 `outbound_order.class_name`。
6. WHEN ServletReturn 收到 `course_name` 或 `class_name` 参数，THE ServletReturn SHALL 将其作为过滤条件加入查询（精确匹配或模糊匹配均可）。
7. WHEN 所有筛选条件均为空，THE ServletReturn SHALL 返回本实验室全部归还记录（不加额外过滤）。

---

### 需求 8：归还登记审核 — 归还数量业务校验

**用户故事：** 作为实验室管理员，我希望系统在审核时自动校验归还数量不超过原领用数量，以防止数据错误。

#### 验收标准

1. WHEN Lab_Admin 对 ReturnRecord 执行审核通过操作，THE ServletReturn SHALL 查询对应 `outbound_item.quantity` 作为原领用数量上限。
2. IF `return_record.return_quantity` 大于对应 `outbound_item.quantity`，THEN THE ServletReturn SHALL 拒绝审核并返回错误码 `400`，提示信息为「归还数量不能超过原领用数量，请核对」。
3. IF `return_record.return_quantity` 小于或等于 `0`，THEN THE ServletReturn SHALL 拒绝审核并返回错误码 `400`，提示信息为「归还数量必须大于 0」。
4. WHEN ReturnAuditPage 收到 `400` 错误响应，THE ReturnAuditPage SHALL 以弹窗形式展示后端返回的提示信息。

---

### 需求 9：归还登记审核 — 危化品归还双人审核标识

**用户故事：** 作为实验室管理员，我希望含危化品的归还申请在界面上有明显标识，以提醒需要双人审核。

#### 验收标准

1. WHEN ServletReturn 返回归还记录列表，THE ServletReturn SHALL 在每条记录中包含 `is_dangerous` 字段，标识该归还记录对应的耗材是否为危化品（通过 `outbound_item` → `consumable.is_dangerous` 关联获取）。
2. WHEN ReturnRecord 的 `is_dangerous=1`，THE ReturnAuditPage SHALL 在该记录行显示 ⚠️ 标识，提示需要双人审核。
3. THE ReturnAuditPage SHALL 在页面顶部或操作区域显示说明文字：「含危化品的归还申请需双人现场核验后再执行审核通过」。

---

### 需求 10：归还登记审核 — 驳回理由填写与展示

**用户故事：** 作为实验室管理员，我希望驳回归还申请时必须填写驳回理由，以便归还人了解被驳回的原因。

#### 验收标准

1. WHEN Lab_Admin 点击「驳回」按钮，THE ReturnAuditPage SHALL 弹出对话框，要求填写驳回理由（必填，不可为空）。
2. IF Lab_Admin 未填写驳回理由直接确认，THEN THE ReturnAuditPage SHALL 阻止提交并提示「请填写驳回理由」。
3. WHEN Lab_Admin 填写驳回理由并确认，THE ReturnAuditPage SHALL 将驳回理由作为 `reject_reason` 参数传递给 ServletReturn。
4. WHEN ServletReturn 收到驳回请求，THE ServletReturn SHALL 将 `reject_reason` 存入 `return_record` 表的对应字段（需新增 `reject_reason VARCHAR(200)` 字段）。
5. WHEN Teacher 在归还申请列表中查看已驳回的记录，THE Lab_Admin_System SHALL 展示对应的驳回理由。

---

### 需求 11：归还登记审核 — 审核通过后库存回补与领用单更新

**用户故事：** 作为实验室管理员，我希望审核通过归还申请后系统自动回补库存并更新领用单的已归还数量，以保证数据一致性。

#### 验收标准

1. WHEN Lab_Admin 审核通过 ReturnRecord，THE ServletReturn SHALL 在同一数据库事务中执行：将 `stock.total_quantity` 增加 `return_record.return_quantity`（按 `lab_id` 和 `consumable_id` 定位库存行）。
2. IF 对应 `stock` 行不存在，THEN THE ServletReturn SHALL 在同一事务中插入新的 `stock` 行，`total_quantity` 初始值为 `return_record.return_quantity`。
3. WHEN 库存回补完成，THE ServletReturn SHALL 在同一事务中更新 `outbound_item` 的已归还数量（通过 `return_record.outbound_item_id` 定位，累加 `return_quantity` 到 `outbound_item.returned_quantity` 字段，需新增该字段）。
4. IF 事务中任意步骤失败，THEN THE ServletReturn SHALL 回滚整个事务，返回错误码 `500`，并保持数据库状态不变。
5. WHEN 审核通过操作成功，THE ReturnAuditPage SHALL 刷新列表并显示成功提示，提示内容包含回补的库存数量。

---

### 需求 12：数据库结构扩展

**用户故事：** 作为系统开发者，我希望在不破坏现有数据的前提下扩展数据库字段，以支持新增业务功能。

#### 验收标准

1. THE Lab_Admin_System SHALL 在 `return_record` 表中新增 `reject_reason VARCHAR(200) NULL` 字段，用于存储驳回理由。
2. THE Lab_Admin_System SHALL 在 `outbound_item` 表中新增 `returned_quantity INT NOT NULL DEFAULT 0` 字段，用于记录已归还数量。
3. WHEN ServletOutbound 或 ServletReturn 初始化时，THE Lab_Admin_System SHALL 通过 `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` 语句自动检测并添加缺失字段，避免手动执行 SQL。
4. THE Lab_Admin_System SHALL 确保上述字段新增操作幂等，即字段已存在时不报错、不重复添加。
