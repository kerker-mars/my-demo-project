package com.dao;

import com.entity.SysUser;
import com.jsj.isdt.utils.DBUtils;

/**
 * sys_user 表数据访问
 */
public class SysUserDao {

    /**
     * 根据用户名和密码查询启用状态的用户
     */
    public SysUser findByUsernameAndPassword(String username, String password) throws Exception {
        String sql = "SELECT * FROM sys_user WHERE username = ? AND password = ? AND status = 1";
        return DBUtils.QueryBean(sql, SysUser.class, username, password);
    }

    public Integer findFirstLabId() throws Exception {
        Object obj = DBUtils.QueryScalar("SELECT id FROM lab ORDER BY id ASC LIMIT 1");
        return obj == null ? null : Integer.parseInt(obj.toString());
    }

    public int bindUserLab(Integer userId, Integer labId) throws Exception {
        return DBUtils.Update("UPDATE sys_user SET lab_id=? WHERE id=?", labId, userId);
    }
}

