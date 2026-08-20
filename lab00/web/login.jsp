<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>计算机实验教学中心耗材管理系统</title>
    <link rel="shortcut icon" href="static/login/newPhotos/logo.jpg" type="image/x-icon">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #0d47a1 0%, #1565c0 30%, #1976d2 60%, #42a5f5 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: "微软雅黑", "Microsoft YaHei", sans-serif;
            position: relative;
            overflow: hidden;
        }

        /* 背景装饰圆 */
        body::before {
            content: '';
            position: absolute;
            width: 500px; height: 500px;
            background: rgba(255,255,255,0.05);
            border-radius: 50%;
            top: -150px; left: -150px;
        }
        body::after {
            content: '';
            position: absolute;
            width: 400px; height: 400px;
            background: rgba(255,255,255,0.05);
            border-radius: 50%;
            bottom: -100px; right: -100px;
        }

        .login-wrapper {
            display: flex;
            width: 860px;
            min-height: 480px;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 24px 60px rgba(0,0,0,0.35);
            position: relative;
            z-index: 1;
        }

        /* 左侧品牌区 */
        .login-brand {
            width: 340px;
            background: linear-gradient(160deg, #0d47a1, #1e88e5);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px 30px;
            color: #fff;
        }
        .brand-logo {
            width: 80px; height: 80px;
            border-radius: 50%;
            border: 3px solid rgba(255,255,255,0.6);
            object-fit: cover;
            margin-bottom: 20px;
        }
        .brand-title {
            font-size: 18px;
            font-weight: bold;
            text-align: center;
            line-height: 1.6;
            letter-spacing: 1px;
            margin-bottom: 16px;
        }
        .brand-subtitle {
            font-size: 12px;
            color: rgba(255,255,255,0.7);
            text-align: center;
            line-height: 1.8;
        }
        .brand-divider {
            width: 40px; height: 2px;
            background: rgba(255,255,255,0.4);
            margin: 16px auto;
            border-radius: 2px;
        }
        .brand-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            justify-content: center;
            margin-top: 10px;
        }
        .brand-tag {
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.3);
            border-radius: 20px;
            padding: 3px 10px;
            font-size: 11px;
            color: rgba(255,255,255,0.9);
        }

        /* 右侧表单区 */
        .login-form-area {
            flex: 1;
            background: #fff;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 50px 48px;
        }
        .form-title {
            font-size: 22px;
            font-weight: bold;
            color: #1565c0;
            margin-bottom: 6px;
        }
        .form-desc {
            font-size: 13px;
            color: #90a4ae;
            margin-bottom: 36px;
        }

        .form-group {
            margin-bottom: 24px;
            position: relative;
        }
        .form-group label {
            display: block;
            font-size: 13px;
            color: #546e7a;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .form-group .input-wrap {
            position: relative;
        }
        .form-group .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #90a4ae;
            font-size: 16px;
            pointer-events: none;
        }
        .form-group input {
            width: 100%;
            height: 46px;
            border: 1.5px solid #cfd8dc;
            border-radius: 8px;
            padding: 0 14px 0 42px;
            font-size: 14px;
            color: #263238;
            background: #f8fafc;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .form-group input:focus {
            border-color: #1976d2;
            box-shadow: 0 0 0 3px rgba(25,118,210,0.12);
            background: #fff;
        }
        .form-group input::placeholder {
            color: #b0bec5;
        }

        .error-message {
            color: #e53935;
            font-size: 12px;
            margin-top: 8px;
            padding: 6px 10px;
            background: #ffebee;
            border-radius: 4px;
            display: none;
        }

        .btn-login {
            width: 100%;
            height: 46px;
            background: linear-gradient(90deg, #1565c0, #1976d2);
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: bold;
            cursor: pointer;
            letter-spacing: 2px;
            transition: all 0.2s;
            margin-top: 8px;
            font-family: "微软雅黑", sans-serif;
        }
        .btn-login:hover {
            background: linear-gradient(90deg, #0d47a1, #1565c0);
            box-shadow: 0 6px 20px rgba(21,101,192,0.4);
            transform: translateY(-1px);
        }
        .btn-login:active {
            transform: translateY(0);
        }
        .btn-login:disabled {
            opacity: 0.7;
            cursor: not-allowed;
            transform: none;
        }

        .form-footer {
            text-align: center;
            margin-top: 28px;
            font-size: 12px;
            color: #b0bec5;
        }
    </style>
    <script src="static/login/js/jquery-1.9.1.min.js"></script>
    <script>
        $(function () {
            $(document).keypress(function (e) {
                if (e.which == 13) $("#btnLogin").click();
            });

            $("#btnLogin").click(function () {
                var username = $("#username").val().trim();
                var password = $("#password").val();
                if (!username || !password) {
                    showError("用户名和密码不能为空");
                    return;
                }
                $(this).text("登录中...").prop("disabled", true);
                $.ajax({
                    type: "POST",
                    url: "newServletLogin?action=login",
                    data: { username: username, password: password },
                    success: function (ret) {
                        $("#btnLogin").text("登 录").prop("disabled", false);
                        try {
                            var result = (typeof ret === 'string') ? JSON.parse(ret) : ret;
                            if (result.code == '200') {
                                window.location.href = "index.jsp";
                            } else {
                                showError(result.msg || "登录失败，请检查用户名和密码");
                            }
                        } catch (e) {
                            showError("服务器响应异常，请稍后重试");
                        }
                    },
                    error: function () {
                        $("#btnLogin").text("登 录").prop("disabled", false);
                        showError("网络连接失败，请稍后重试");
                    }
                });
            });

            function showError(msg) {
                $(".error-message").text(msg).show();
                setTimeout(function () { $(".error-message").fadeOut(); }, 3500);
            }

            $("#username, #password").on("focus", function () {
                $(".error-message").hide();
            });
        });
    </script>
</head>
<body>
    <div class="login-wrapper">
        <!-- 左侧品牌 -->
        <div class="login-brand">
            <img src="static/login/newPhotos/logo.jpg" alt="Logo" class="brand-logo">
            <div class="brand-title">计算机实验教学中心<br>耗材管理系统</div>
            <div class="brand-divider"></div>
            <div class="brand-subtitle">重庆理工大学<br>Laboratory Consumables Management</div>
            <div class="brand-tags">
                <span class="brand-tag">采购管理</span>
                <span class="brand-tag">出入库</span>
                <span class="brand-tag">库存盘点</span>
                <span class="brand-tag">危化品管控</span>
            </div>
        </div>

        <!-- 右侧表单 -->
        <div class="login-form-area">
            <div class="form-title">欢迎登录</div>
            <div class="form-desc">请使用您的账号和密码登录系统</div>

            <div class="error-message" id="errorMsg"></div>

            <div class="form-group">
                <label for="username">用户名</label>
                <div class="input-wrap">
                    <span class="input-icon">👤</span>
                    <input type="text" id="username" name="username" placeholder="请输入用户名" autocomplete="username">
                </div>
            </div>

            <div class="form-group">
                <label for="password">密码</label>
                <div class="input-wrap">
                    <span class="input-icon">🔒</span>
                    <input type="password" id="password" name="password" placeholder="请输入密码" autocomplete="current-password">
                </div>
            </div>

            <button id="btnLogin" class="btn-login" type="button">登 录</button>

            <div class="form-footer">
                <p>© 2026 重庆理工大学 · 推荐使用 Chrome / Edge 浏览器</p>
            </div>
        </div>
    </div>
</body>
</html>
