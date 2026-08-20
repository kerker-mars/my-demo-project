<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>报废登记</title>
        <link rel="stylesheet" type="text/css"
            href="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/themes/default/easyui.css">
        <link rel="stylesheet" type="text/css"
            href="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/themes/icon.css">
        <script src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/jquery.min.js"></script>
        <script
            src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/jquery.easyui.min.js"></script>
        <script
            src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/locale/easyui-lang-zh_CN.js"></script>
        <style>
            html,
            body {
                height: 100%;
                margin: 0;
                font-family: "微软雅黑", sans-serif;
                overflow: hidden;
            }

            .page-header {
                background: linear-gradient(90deg, #1565c0, #1976d2);
                color: #fff;
                padding: 10px 18px;
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 15px;
                font-weight: bold;
            }

            .page-header .sub {
                font-size: 12px;
                font-weight: normal;
                opacity: .8;
            }

            /* 上下分区 */
            .top-section {
                padding: 16px 20px 12px;
                background: #f8fafc;
                border-bottom: 2px solid #e3eaf5;
                flex-shrink: 0;
            }

            .section-title {
                font-size: 13px;
                font-weight: bold;
                color: #1565c0;
                margin-bottom: 12px;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            .form-grid {
                display: flex;
                flex-wrap: wrap;
                gap: 12px 24px;
            }

            .form-item {
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .form-item .lbl {
                font-size: 12px;
                color: #546e7a;
                font-weight: 600;
                white-space: nowrap;
            }

            .stock-badge {
                display: inline-block;
                padding: 2px 10px;
                border-radius: 10px;
                font-size: 12px;
                font-weight: bold;
                background: #e3f2fd;
                color: #1565c0;
            }

            .stock-badge.low {
                background: #fff3e0;
                color: #e65100;
            }

            .danger-warn {
                background: #fff3e0;
                border: 1px solid #ffcc80;
                border-radius: 6px;
                padding: 8px 14px;
                font-size: 12px;
                color: #e65100;
                display: none;
                margin-top: 10px;
            }

            .btn-submit {
                background: linear-gradient(90deg, #e53935, #c62828);
                color: #fff;
                border: none;
                border-radius: 5px;
                padding: 7px 24px;
                font-size: 13px;
                cursor: pointer;
                font-family: "微软雅黑";
                font-weight: bold;
                margin-top: 12px;
            }

            .btn-submit:hover {
                background: #b71c1c;
            }

            /* 状态徽章 */
            .s0 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #FF9800;
                color: #fff;
            }

            .s1 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #43a047;
                color: #fff;
            }

            .s2 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #e53935;
                color: #fff;
            }

            .bottom-section {
                flex: 1;
                overflow: hidden;
                display: flex;
                flex-direction: column;
            }

            .bottom-title {
                font-size: 13px;
                font-weight: bold;
                color: #1565c0;
                padding: 8px 16px;
                border-bottom: 1px solid #e3eaf5;
                background: #fff;
                flex-shrink: 0;
            }

            #root {
                display: flex;
                flex-direction: column;
                height: calc(100vh - 44px);
            }
        </style>
        <script>
            var ctx = '${pageContext.request.contextPath}';
            // 缓存当前选中耗材信息，避免 onSelect 里调 setValue 触发递归
            var _selConsumable = null;

            $(function () {
                /* ===== 耗材下拉 =====
                 * 关键：textField 用 'name'（纯耗材名称），不含单位/库存后缀
                 * 不在 onSelect 里再调 combobox('setValue')，避免栈溢出
                 */
                $('#consumable_id').combobox({
                    url: ctx + '/ServletScrap?action=stockOptions',
                    method: 'get',
                    valueField: 'id',
                    textField: 'name',
                    editable: false,
                    panelHeight: 260,
                    loadFilter: function (rows) {
                        return $.map(rows || [], function (r) {
                            return $.extend({}, r, { id: r.id != null ? String(r.id) : '' });
                        });
                    },
                    formatter: function (row) {
                        var s = '<span style="display:inline-block;min-width:180px;">' + row.name + '</span>';
                        if (row.is_dangerous == 1) {
                            s += '<span style="display:inline-block;background:#ffebee;color:#c62828;padding:1px 6px;border-radius:3px;font-size:10px;font-weight:bold;margin-left:6px;">危化品</span>';
                        }
                        return s;
                    },
                    onSelect: function (rec) {
                        // 缓存选中记录，不在此处调 setValue（会触发递归）
                        _selConsumable = rec;

                        var sq = parseInt(rec.stock_qty || 0);
                        var cls = sq <= 5 ? 'low' : '';
                        $('#stockBadge').attr('class', 'stock-badge ' + cls)
                            .text('当前库存：' + sq + (rec.unit || ''))
                            .show();

                        // 更新数量上限，清空旧值让用户重新输入
                        $('#qtyInput').val('').attr('max', sq);
                        $('#qtyErr').text('');

                        // 危化品提示
                        if (rec.is_dangerous == 1) {
                            $('#dangerWarn').show();
                        } else {
                            $('#dangerWarn').hide();
                        }
                    }
                });

                /* ===== 我的报废记录 ===== */
                $('#dgMy').datagrid({
                    url: ctx + '/ServletScrap?action=listMy',
                    fit: true, pagination: true, singleSelect: true, rownumbers: true, striped: true,
                    pageSize: 10, pageList: [10, 20, 50],
                    columns: [[
                        {
                            field: 'id', title: '报废ID', width: 70, align: 'center',
                            formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; }
                        },
                        { field: 'lab_name', title: '实验室', width: 120, formatter: function (v) { return v || '—'; } },
                        { field: 'consumable_name', title: '耗材名称', minWidth: 160 },
                        { field: 'unit', title: '单位', width: 55, align: 'center' },
                        {
                            field: 'quantity', title: '报废数量', width: 80, align: 'center',
                            formatter: function (v) { return '<b style="color:#e53935;">' + v + '</b>'; }
                        },
                        {
                            field: 'status', title: '状态', width: 90, align: 'center',
                            formatter: function (v) {
                                if (v == 0) return '<span class="s0">待审核</span>';
                                if (v == 1) return '<span class="s1">已通过</span>';
                                if (v == 2) return '<span class="s2">已驳回</span>';
                                return v;
                            }
                        },
                        {
                            field: 'apply_time', title: '申请时间', width: 140,
                            formatter: function (v) { return v ? String(v).substring(0, 16).replace('T', ' ') : '—'; }
                        },
                        {
                            field: 'audit_time', title: '审核时间', width: 140,
                            formatter: function (v) { return v ? String(v).substring(0, 16).replace('T', ' ') : '—'; }
                        },
                        {
                            field: 'reason', title: '报废原因', minWidth: 160, formatter: function (v) {
                                if (!v) return '—';
                                var safe = v.replace(/"/g, '&quot;').replace(/</g, '&lt;');
                                return '<span title="' + safe + '">' + (v.length > 20 ? v.substring(0, 20) + '…' : v) + '</span>';
                            }
                        },
                        {
                            field: 'audit_comment', title: '驳回原因', minWidth: 140, formatter: function (v, row) {
                                if (row.status != 2) return '—';
                                if (!v) return '—';
                                var safe = v.replace(/"/g, '&quot;').replace(/</g, '&lt;');
                                return '<span style="color:#e53935;" title="' + safe + '">' + (v.length > 16 ? v.substring(0, 16) + '…' : v) + '</span>';
                            }
                        }
                    ]],
                    onLoadSuccess: function (data) {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                /* ===== 数量输入实时校验 ===== */
                $('#qtyInput').on('input', function () {
                    validateQty();
                });

                /* ===== 提交 ===== */
                $('#btnCreate').click(function () {
                    var consumableId = $('#consumable_id').combobox('getValue');
                    if (!consumableId) {
                        $.messager.alert('提示', '请选择耗材', 'warning'); return;
                    }

                    if (!validateQty()) return;
                    var qty = parseInt($('#qtyInput').val());

                    var reason = $('#reason').val().trim();
                    if (!reason) {
                        $.messager.alert('提示', '报废原因不能为空', 'warning'); return;
                    }

                    // 危化品合规提示
                    var doSubmit = function () {
                        $.messager.confirm('确认提交', '确认提交报废申请？提交后等待系统管理员审核。', function (r) {
                            if (!r) return;
                            $.messager.progress();
                            $.post(ctx + '/ServletScrap?action=create', {
                                consumable_id: consumableId, quantity: qty, reason: reason
                            }, function (ret) {
                                $.messager.progress('close');
                                var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                                if (res.code == '200') {
                                    $.messager.show({ title: '✔ 提交成功', msg: res.msg, timeout: 2000, showType: 'slide' });
                                    $('#consumable_id').combobox('clear');
                                    $('#stockBadge').hide();
                                    $('#dangerWarn').hide();
                                    $('#qtyInput').val('');
                                    $('#qtyErr').text('');
                                    $('#reason').val('');
                                    _selConsumable = null;
                                    $('#dgMy').datagrid('reload');
                                } else { $.messager.alert('提示', res.msg, 'warning'); }
                            });
                        });
                    };

                    if (_selConsumable && _selConsumable.is_dangerous == 1) {
                        showDangerConfirm(function (confirmed) {
                            if (confirmed) {
                                doSubmit();
                            }
                        });
                    } else {
                        doSubmit();
                    }
                });
            });

            function showDangerConfirm(callback) {
                var content = '<div style="text-align:center;padding:12px 20px;">' +
                    '<div style="display:inline-block;width:56px;height:56px;line-height:56px;text-align:center;background:#fff3e0;border-radius:50%;border:2px solid #ffb74d;">' +
                    '<span style="font-size:32px;">⚠</span>' +
                    '</div>' +
                    '<div style="margin-top:12px;font-size:14px;font-weight:bold;color:#e65100;">该耗材为危险化学品，报废须满足以下要求：</div>' +
                    '<div style="margin-top:12px;text-align:left;padding:0 30px;">' +
                    '<div style="font-size:13px;color:#546e7a;line-height:1.6;margin:4px 0;">1、双人在场并签字记录</div>' +
                    '<div style="font-size:13px;color:#546e7a;line-height:1.6;margin:4px 0;">2、按危化品处置规范执行</div>' +
                    '<div style="font-size:13px;color:#546e7a;line-height:1.6;margin:4px 0;">3、处置记录存档备查</div>' +
                    '</div>' +
                    '</div>';

                var $dlg = $('<div>' + content + '</div>');
                $dlg.dialog({
                    title: '⚠ 危化品报废合规确认',
                    width: 450,
                    height: 260,
                    closed: false,
                    cache: false,
                    modal: true,
                    closable: false,
                    buttons: [{
                        text: '我已合规，继续提交',
                        iconCls: 'icon-ok',
                        handler: function () {
                            $dlg.dialog('close');
                            if (callback) callback(true);
                        }
                    }, {
                        text: '取消',
                        handler: function () {
                            $dlg.dialog('close');
                            if (callback) callback(false);
                        }
                    }]
                });
            }

            function validateQty() {
                var val = $('#qtyInput').val().trim();
                var $err = $('#qtyErr');
                var $input = $('#qtyInput');

                if (!val) {
                    $input.css('border-color', '#e53935');
                    $err.text('报废数量不能为空');
                    return false;
                }
                var n = parseInt(val);
                if (isNaN(n) || n <= 0 || String(n) !== val) {
                    $input.css('border-color', '#e53935');
                    $err.text('请输入正整数');
                    return false;
                }
                var maxQty = parseInt($('#qtyInput').attr('max') || 0);
                if (maxQty > 0 && n > maxQty) {
                    $input.css('border-color', '#e53935');
                    $err.text('不能超过当前库存 ' + maxQty);
                    return false;
                }
                $input.css('border-color', '#cfd8dc');
                $err.text('');
                return true;
            }
        </script>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">🗑️</span>
            报废登记
            <span class="sub">申请耗材报废，提交后由系统管理员审核</span>
        </div>

        <div id="root">
            <!-- 上：申请表单 -->
            <div class="top-section">
                <div class="section-title">📝 填写报废申请</div>
                <div class="form-grid">
                    <div class="form-item" style="flex-direction:column;align-items:flex-start;gap:4px;">
                        <span class="lbl">选择耗材 <span style="color:#e53935;">*</span></span>
                        <div style="display:flex;align-items:center;gap:8px;">
                            <input id="consumable_id" style="width:320px;">
                            <span id="stockBadge" class="stock-badge" style="display:none;"></span>
                        </div>
                    </div>
                    <div class="form-item" style="flex-direction:column;align-items:flex-start;gap:4px;">
                        <span class="lbl">报废数量 <span style="color:#e53935;">*</span></span>
                        <input id="qtyInput" type="number" min="1" placeholder="请输入正整数" style="width:120px;height:26px;border:1px solid #cfd8dc;border-radius:4px;
                              padding:0 8px;font-size:13px;font-family:'微软雅黑';outline:none;">
                        <span id="qtyErr" style="font-size:11px;color:#e53935;min-height:14px;"></span>
                    </div>
                </div>
                <div style="margin-top:12px;">
                    <div class="lbl" style="font-size:12px;color:#546e7a;font-weight:600;margin-bottom:4px;">
                        报废原因 <span style="color:#e53935;">*</span>
                        <span style="font-size:11px;color:#90a4ae;font-weight:normal;">（如：过期、损坏、规定报废等）</span>
                    </div>
                    <textarea id="reason" placeholder="请填写报废原因..." style="width:600px;height:72px;border:1px solid #cfd8dc;border-radius:4px;
                             padding:6px 8px;font-size:13px;font-family:'微软雅黑';
                             outline:none;resize:vertical;box-sizing:border-box;"></textarea>
                </div>
                <div id="dangerWarn" class="danger-warn">
                    ⚠ 该耗材为危险化学品，报废须严格按照危化品处置规范执行，并确保双人在场记录。
                </div>
                <button id="btnCreate" class="btn-submit">提交报废申请</button>
            </div>

            <!-- 下：我的报废记录 -->
            <div class="bottom-section">
                <div class="bottom-title">📋 我的报废申请记录</div>
                <div style="flex:1;overflow:hidden;">
                    <table id="dgMy" style="width:100%;height:100%;"></table>
                </div>
            </div>
        </div>

    </body>

    </html>