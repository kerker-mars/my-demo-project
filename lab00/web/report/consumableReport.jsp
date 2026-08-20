<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>数据统计分析</title>
        <link rel="stylesheet" type="text/css"
            href="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/themes/default/easyui.css">
        <link rel="stylesheet" type="text/css"
            href="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/themes/icon.css">
        <script src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/jquery.min.js"></script>
        <script
            src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/jquery.easyui.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/echarts@5.4.2/dist/echarts.min.js"></script>
        <style>
            * {
                box-sizing: border-box;
            }

            html,
            body {
                height: 100%;
                margin: 0;
                font-family: "微软雅黑", sans-serif;
                background: #f0f4fa;
            }

            .page-wrap {
                padding: 14px 16px;
                overflow-y: auto;
                height: 100%;
            }

            .page-header {
                background: linear-gradient(90deg, #1565c0, #1976d2);
                color: #fff;
                padding: 10px 18px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 10px;
                font-size: 15px;
                font-weight: bold;
                margin-bottom: 14px;
            }

            .page-header .sub {
                font-size: 12px;
                font-weight: normal;
                opacity: .8;
            }

            .page-title {
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 15px;
                font-weight: bold;
                color: #fff;
            }

            .refresh-btn {
                background: #1976d2;
                color: #fff;
                border: none;
                border-radius: 5px;
                padding: 5px 14px;
                font-size: 12px;
                cursor: pointer;
                font-family: "微软雅黑";
            }

            .refresh-btn:hover {
                background: #1565c0;
            }

            /* KPI */
            .kpi-row {
                display: flex;
                gap: 10px;
                margin-bottom: 14px;
            }

            .kpi-card {
                flex: 1;
                background: #fff;
                border-radius: 8px;
                padding: 12px 14px;
                box-shadow: 0 1px 6px rgba(21, 101, 192, 0.10);
                border-top: 3px solid #1976d2;
                position: relative;
                overflow: hidden;
            }

            .kpi-card.warn {
                border-top-color: #f57c00;
            }

            .kpi-card.ok {
                border-top-color: #43a047;
            }

            .kpi-card.info {
                border-top-color: #8e24aa;
            }

            .kpi-label {
                font-size: 12px;
                color: #78909c;
                margin-bottom: 4px;
            }

            .kpi-value {
                font-size: 26px;
                font-weight: bold;
                color: #1565c0;
                line-height: 1;
            }

            .kpi-card.warn .kpi-value {
                color: #f57c00;
            }

            .kpi-card.ok .kpi-value {
                color: #43a047;
            }

            .kpi-card.info .kpi-value {
                color: #8e24aa;
            }

            .kpi-unit {
                font-size: 11px;
                color: #90a4ae;
                margin-top: 3px;
            }

            .kpi-icon {
                position: absolute;
                right: 12px;
                top: 12px;
                font-size: 26px;
                opacity: 0.12;
            }

            /* 待办 */
            .todo-bar {
                background: #fff8e1;
                border: 1px solid #ffe082;
                border-radius: 8px;
                padding: 10px 16px;
                margin-bottom: 14px;
                display: flex;
                align-items: flex-start;
                gap: 10px;
            }

            .todo-title {
                font-size: 13px;
                font-weight: bold;
                color: #e65100;
                margin-bottom: 6px;
            }

            .todo-items {
                display: flex;
                gap: 20px;
                flex-wrap: wrap;
            }

            .todo-item {
                font-size: 13px;
                color: #546e7a;
            }

            .badge-num {
                display: inline-block;
                background: #e53935;
                color: #fff;
                border-radius: 10px;
                padding: 0 7px;
                font-size: 11px;
                font-weight: bold;
                margin-left: 4px;
            }

            .badge-zero {
                background: #90a4ae;
            }

            /* 领用状态卡 */
            .status-row {
                display: flex;
                gap: 10px;
                margin-bottom: 14px;
            }

            .status-card {
                flex: 1;
                background: #fff;
                border-radius: 8px;
                padding: 12px 14px;
                box-shadow: 0 1px 6px rgba(21, 101, 192, 0.08);
                cursor: pointer;
                transition: box-shadow 0.2s;
                border-bottom: 3px solid #e0e0e0;
                text-align: center;
            }

            .status-card:hover {
                box-shadow: 0 4px 14px rgba(21, 101, 192, 0.18);
            }

            .status-card.s-pending {
                border-bottom-color: #f57c00;
            }

            .status-card.s-approved {
                border-bottom-color: #1976d2;
            }

            .status-card.s-rejected {
                border-bottom-color: #e53935;
            }

            .status-card.s-done {
                border-bottom-color: #43a047;
            }

            .status-num {
                font-size: 28px;
                font-weight: bold;
                margin-bottom: 4px;
            }

            .s-pending .status-num {
                color: #f57c00;
            }

            .s-approved .status-num {
                color: #1976d2;
            }

            .s-rejected .status-num {
                color: #e53935;
            }

            .s-done .status-num {
                color: #43a047;
            }

            .status-label {
                font-size: 12px;
                color: #78909c;
            }

            .status-hint {
                font-size: 11px;
                color: #b0bec5;
                margin-top: 3px;
            }

            /* 图表 */
            .chart-row {
                display: flex;
                gap: 12px;
                margin-bottom: 12px;
            }

            .chart-card {
                flex: 1;
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 1px 6px rgba(21, 101, 192, 0.08);
                overflow: hidden;
            }

            .chart-card.wide {
                flex: 1.4;
            }

            .chart-head {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 10px 14px;
                border-bottom: 1px solid #e8eef7;
            }

            .chart-head-title {
                font-size: 13px;
                font-weight: bold;
                color: #1565c0;
            }

            .chart-head-sub {
                font-size: 11px;
                color: #90a4ae;
                margin-left: 6px;
            }

            .export-btn {
                font-size: 11px;
                color: #1976d2;
                background: #e3f2fd;
                border: 1px solid #90caf9;
                border-radius: 4px;
                padding: 2px 8px;
                cursor: pointer;
                text-decoration: none;
            }

            .export-btn:hover {
                background: #1976d2;
                color: #fff;
            }

            .chart-body {
                padding: 6px 10px 10px;
            }

            /* 刷新提示居中 */
            .refresh-toast {
                display: none;
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: rgba(21, 101, 192, 0.92);
                color: #fff;
                border-radius: 8px;
                padding: 14px 28px;
                font-size: 14px;
                z-index: 9999;
            }

            /* 趋势筛选按钮 */
            .trend-btns {
                display: flex;
                gap: 4px;
            }

            .trend-btn {
                font-size: 11px;
                padding: 2px 8px;
                border: 1px solid #90caf9;
                border-radius: 4px;
                background: #e3f2fd;
                color: #1976d2;
                cursor: pointer;
            }

            .trend-btn:hover,
            .trend-btn.active {
                background: #1976d2;
                color: #fff;
                border-color: #1976d2;
            }

            /* 状态列表弹窗 */
            .status-modal {
                display: none;
                position: fixed;
                inset: 0;
                background: rgba(0, 0, 0, 0.4);
                z-index: 9000;
                align-items: center;
                justify-content: center;
            }

            .status-modal.show {
                display: flex;
            }

            .status-modal-box {
                background: #fff;
                border-radius: 10px;
                width: 680px;
                max-height: 80vh;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
                overflow: hidden;
                display: flex;
                flex-direction: column;
            }

            .status-modal-head {
                background: linear-gradient(90deg, #1565c0, #1976d2);
                color: #fff;
                padding: 12px 18px;
                font-size: 14px;
                font-weight: bold;
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-shrink: 0;
            }

            .status-modal-close {
                background: none;
                border: none;
                color: #fff;
                font-size: 18px;
                cursor: pointer;
            }

            .status-modal-body {
                padding: 14px 18px;
                overflow-y: auto;
                flex: 1;
            }

            .status-modal-foot {
                padding: 10px 18px;
                border-top: 1px solid #e8eef7;
                text-align: right;
                flex-shrink: 0;
            }

            .modal-btn {
                background: #1976d2;
                color: #fff;
                border: none;
                border-radius: 5px;
                padding: 6px 18px;
                font-size: 13px;
                cursor: pointer;
                font-family: "微软雅黑";
            }

            .modal-btn:hover {
                background: #1565c0;
            }
        </style>
        <script>
            $(function () {
                var ctx = '${pageContext.request.contextPath}';
                var chartRank = echarts.init(document.getElementById('chartRank'));
                var chartHomePie = echarts.init(document.getElementById('chartHomePie'));
                var chartTrend = echarts.init(document.getElementById('chartTrend'));

                window.addEventListener('resize', function () {
                    chartRank.resize();
                    chartHomePie.resize();
                    chartTrend.resize();
                });

                loadAll();

                function loadAll() {
                    loadKpi();
                    loadConsumptionRank(1);
                    loadHomePie(); loadPurchaseScrapTrend(12);
                }

                /* KPI */
                function loadKpi() {
                    $.getJSON(ctx + '/ReportServlet?action=coreIndicators', function (d) {
                        $('#kpiPlan').text(d.pendingPurchasePlans || 0);
                        $('#kpiWarn').text(d.warningStockItems || 0);
                        $('#kpiRate').text((d.dangerComplianceRate || 100) + '%');
                        $('#kpiToday').text(d.todayOutboundRequests || 0);
                    });
                }



                /* 1. 近 N 个月耗材消耗排行（横向柱状图，数据来自数据库） */
                function loadConsumptionRank(months) {
                    // 高亮按钮
                    $('.rank-btn').removeClass('active');
                    $('.rank-btn[data-m="' + months + '"]').addClass('active');

                    $.getJSON(ctx + '/ReportServlet?action=consumptionRank&months=' + months, function (data) {
                        if (!data || data.length === 0) {
                            chartRank.setOption({
                                graphic: [{
                                    type: 'text', left: 'center', top: 'middle',
                                    style: { text: '近' + months + '个月暂无出库记录', fill: '#b0bec5', fontSize: 14 }
                                }]
                            });
                            return;
                        }
                        // 倒序排列（ECharts 横向柱状图从下往上，倒序后最大值在顶部）
                        var names = data.map(function (x) { return x.name || '—'; }).reverse();
                        var values = data.map(function (x) { return parseInt(x.qty || 0); }).reverse();
                        var isDanger = data.map(function (x) { return parseInt(x.is_dangerous || 0); }).reverse();
                        var barColors = isDanger.map(function (d) { return d === 1 ? '#e53935' : '#1976d2'; });

                        chartRank.setOption({
                            tooltip: {
                                trigger: 'axis', axisPointer: { type: 'shadow' },
                                formatter: function (p) {
                                    var i = p[0].dataIndex;
                                    var dangerTag = isDanger[i] === 1 ? ' <span style="color:#e53935">⚠危化品</span>' : '';
                                    return names[i] + dangerTag + '<br/>消耗量：<b>' + p[0].value + '</b> 件';
                                }
                            },
                            grid: { left: 10, right: 50, top: 10, bottom: 10, containLabel: true },
                            xAxis: { type: 'value', name: '消耗(件)', nameTextStyle: { fontSize: 11 }, axisLabel: { fontSize: 11 } },
                            yAxis: { type: 'category', data: names, axisLabel: { fontSize: 11, width: 80, overflow: 'truncate' } },
                            series: [{
                                type: 'bar', data: values, barMaxWidth: 22,
                                itemStyle: {
                                    color: function (p) { return barColors[p.dataIndex]; },
                                    borderRadius: [0, 3, 3, 0]
                                },
                                label: {
                                    show: true, position: 'right', fontSize: 11,
                                    formatter: function (p) { return p.value > 0 ? p.value : ''; }
                                }
                            }]
                        });
                    }).fail(function () {
                        chartRank.setOption({
                            graphic: [{
                                type: 'text', left: 'center', top: 'middle',
                                style: { text: '数据加载失败', fill: '#e53935', fontSize: 13 }
                            }]
                        });
                    });
                }
                window.loadConsumptionRank = loadConsumptionRank;

                /* 2. 全学院耗材资产价值分布 */
                function loadHomePie() {
                    $.getJSON(ctx + '/ReportServlet?action=stockCategory', function (data) {
                        if (!data || !data.outer || data.outer.length === 0) {
                            chartHomePie.setOption({ title: { text: '暂无库存数据', left: 'center', top: 'middle', textStyle: { color: '#b0bec5', fontSize: 14 } } });
                            return;
                        }
                        var outerData = data.outer;
                        var innerData = data.inner;
                        var colors = ['#1976d2', '#43a047', '#8e24aa', '#f57c00', '#00838f', '#6d4c41'];
                        var dangerColors = ['#e53935', '#f57c00', '#c62828'];
                        outerData.forEach(function (item, i) {
                            item.itemStyle = { color: item.name.indexOf('危险') >= 0 ? dangerColors[i % 3] : colors[i % 6] };
                        });
                        chartHomePie.setOption({
                            tooltip: {
                                trigger: 'item',
                                formatter: function (p) {
                                    return p.name + '<br/>价值：<b>¥' + p.value + '</b><br/>占比：' + p.percent + '%';
                                }
                            },
                            legend: {
                                type: 'scroll',
                                bottom: '2%',
                                left: 'center',
                                textStyle: { fontSize: 11 },
                                pageTextStyle: { fontSize: 11 },
                                pageIconSize: 10
                            },
                            series: [
                                {
                                    name: '内环',
                                    type: 'pie',
                                    radius: ['0%', '30%'],
                                    center: ['50%', '42%'],
                                    label: {
                                        show: true,
                                        position: 'center',
                                        formatter: function (params) {
                                            if (params.percent === 100) {
                                                return '{a|总资产}\n{value|¥' + params.value + '}';
                                            }
                                            return '';
                                        },
                                        rich: {
                                            a: {
                                                fontSize: 12,
                                                color: '#607d8b',
                                                lineHeight: 20
                                            },
                                            value: {
                                                fontSize: 16,
                                                fontWeight: 'bold',
                                                color: '#1976d2'
                                            }
                                        }
                                    },
                                    data: innerData,
                                    itemStyle: {
                                        color: '#e3f2fd'
                                    }
                                },
                                {
                                    name: '外环',
                                    type: 'pie',
                                    radius: ['40%', '58%'],
                                    center: ['50%', '42%'],
                                    avoidLabelOverlap: true,
                                    label: { show: true, formatter: '{b}\n¥{c}', fontSize: 11 },
                                    emphasis: { itemStyle: { shadowBlur: 10, shadowColor: 'rgba(0,0,0,0.3)' } },
                                    data: outerData
                                }
                            ]
                        });
                    });
                }

                /* 3. 近 N 个月采购金额 vs 报废损耗金额 */
                function loadPurchaseScrapTrend(months) {
                    $.getJSON(ctx + '/ReportServlet?action=purchaseScrapTrend&months=' + months, function (data) {
                        if (!data || !data.months || data.months.length === 0) {
                            chartTrend.setOption({
                                graphic: [{
                                    type: 'text', left: 'center', top: 'middle',
                                    style: { text: '近' + months + '个月暂无记录', fill: '#b0bec5', fontSize: 14 }
                                }]
                            });
                            return;
                        }
                        var xAxisData = data.months;
                        var purchaseData = data.purchaseAmount;
                        var scrapData = data.scrapAmount;
                        chartTrend.setOption({
                            tooltip: {
                                trigger: 'axis',
                                axisPointer: { type: 'cross' },
                                formatter: function (params) {
                                    var html = params[0].axisValue + '<br/>';
                                    params.forEach(function (p) {
                                        html += '<span style="display:inline-block;margin-right:8px;width:10px;height:10px;background-color:' + p.color + ';"></span>';
                                        html += p.seriesName + '：<b>¥' + p.value.toFixed(2) + '</b><br/>';
                                    });
                                    return html;
                                }
                            },
                            grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
                            xAxis: { type: 'category', data: xAxisData, axisLabel: { fontSize: 11 } },
                            yAxis: { type: 'value', name: '金额(元)', nameTextStyle: { fontSize: 11 }, axisLabel: { fontSize: 11, formatter: function (value) { return value >= 10000 ? (value / 10000).toFixed(1) + '万' : value; } } },
                            series: [
                                {
                                    name: '采购金额',
                                    type: 'bar',
                                    data: purchaseData,
                                    itemStyle: { color: '#43a047', borderRadius: [4, 4, 0, 0] }
                                },
                                {
                                    name: '报废损耗金额',
                                    type: 'line',
                                    data: scrapData,
                                    smooth: true,
                                    itemStyle: { color: '#e53935' },
                                    lineStyle: { width: 3 },
                                    areaStyle: {
                                        color: {
                                            type: 'linear',
                                            x: 0, y: 0, x2: 0, y2: 1,
                                            colorStops: [
                                                { offset: 0, color: 'rgba(229, 57, 53, 0.3)' },
                                                { offset: 1, color: 'rgba(229, 57, 53, 0.05)' }
                                            ]
                                        }
                                    }
                                }
                            ]
                        });
                    }).fail(function () {
                        chartTrend.setOption({
                            graphic: [{
                                type: 'text', left: 'center', top: 'middle',
                                style: { text: '数据加载失败', fill: '#e53935', fontSize: 13 }
                            }]
                        });
                    });
                }
                window.loadPurchaseScrapTrend = loadPurchaseScrapTrend;

                /* 导出 */
                window.exportChart = function (id) {
                    var map = { chartRank: chartRank, chartHomePie: chartHomePie, chartTrend: chartTrend };
                    var c = map[id]; if (!c) return;
                    var url = c.getDataURL({ type: 'png', pixelRatio: 2, backgroundColor: '#fff' });
                    var a = document.createElement('a'); a.href = url; a.download = id + '.png'; a.click();
                };

                /* 刷新 */
                window.refreshAll = function () {
                    loadAll();
                    var t = document.getElementById('refreshToast');
                    t.style.display = 'block';
                    setTimeout(function () { t.style.display = 'none'; }, 1800);
                };
            });
        </script>
    </head>

    <body>
        <div class="page-wrap">
            <!-- 页头 -->
            <div class="page-header">
                <div class="page-title">
                    <span style="font-size:20px;">📊</span>
                    数据统计分析
                    <span class="sub">系统管理员查看耗材相关的各类统计报表</span>
                </div>
                <button class="refresh-btn" onclick="refreshAll()">↻ 刷新数据</button>
            </div>

            <!-- KPI -->
            <div class="kpi-row">
                <div class="kpi-card">
                    <div class="kpi-icon">📋</div>
                    <div class="kpi-label">待审核采购计划</div>
                    <div class="kpi-value" id="kpiPlan">—</div>
                    <div class="kpi-unit">条</div>
                </div>
                <div class="kpi-card warn">
                    <div class="kpi-icon">⚠</div>
                    <div class="kpi-label">库存预警耗材</div>
                    <div class="kpi-value" id="kpiWarn">—</div>
                    <div class="kpi-unit">种（库存 ≤ 预警值）</div>
                </div>
                <div class="kpi-card ok">
                    <div class="kpi-icon">✔</div>
                    <div class="kpi-label">危化品审批合规率</div>
                    <div class="kpi-value" id="kpiRate">—</div>
                    <div class="kpi-unit">已审核 / 全部危化品领用</div>
                </div>
                <div class="kpi-card info">
                    <div class="kpi-icon">🗑️</div>
                    <div class="kpi-label">待审核报废申请</div>
                    <div class="kpi-value" id="kpiToday">—</div>
                    <div class="kpi-unit">条</div>
                </div>
            </div>

            <!-- 危化品待办 -->
            <div class="todo-bar">
                <div style="font-size:18px;flex-shrink:0;">⚠️</div>
                <div>
                    <div class="todo-title">危化品操作需经过两次审核，全程留痕可追溯</div>
                </div>
            </div>

            <!-- 图表第一行：近一年各月采购金额 vs 报废损耗金额 + 近1个月消耗排行 -->
            <div class="chart-row">
                <div class="chart-card wide">
                    <div class="chart-head">
                        <span class="chart-head-title">近一年各月采购金额 vs 报废损耗金额
                            <span class="chart-head-sub">绿色为采购金额，红色为报废损耗金额</span>
                        </span>
                        <a class="export-btn" onclick="exportChart('chartTrend')">导出PNG</a>
                    </div>
                    <div class="chart-body">
                        <div id="chartTrend" style="height:300px;"></div>
                    </div>
                </div>
                <div class="chart-card">
                    <div class="chart-head">
                        <span class="chart-head-title">耗材消耗排行
                            <span class="chart-head-sub">按出库数量降序，红色为危化品</span>
                        </span>
                        <div style="display:flex;align-items:center;gap:8px;">
                            <div class="trend-btns">
                                <button class="rank-btn trend-btn active" data-m="1"
                                    onclick="loadConsumptionRank(1)">近1月</button>
                                <button class="rank-btn trend-btn" data-m="3"
                                    onclick="loadConsumptionRank(3)">近3月</button>
                                <button class="rank-btn trend-btn" data-m="6"
                                    onclick="loadConsumptionRank(6)">近6月</button>
                            </div>
                            <a class="export-btn" onclick="exportChart('chartRank')">导出PNG</a>
                        </div>
                    </div>
                    <div class="chart-body">
                        <div id="chartRank" style="height:300px;"></div>
                    </div>
                </div>
            </div>

            <!-- 图表第二行：全学院耗材资产价值分布 -->
            <div class="chart-row">
                <div class="chart-card">
                    <div class="chart-head">
                        <span class="chart-head-title">全学院耗材资产价值分布
                            <span class="chart-head-sub">按类别 + 危险等级，hover 显示价值</span>
                        </span>
                        <a class="export-btn" onclick="exportChart('chartHomePie')">导出PNG</a>
                    </div>
                    <div class="chart-body">
                        <div id="chartHomePie" style="height:300px;"></div>
                    </div>
                </div>
            </div>

        </div>
        <div class="refresh-toast" id="refreshToast">✔ 数据已刷新</div>
    </body>

    </html>