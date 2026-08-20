package com.jsj.isdt.utils;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;

public class DBUtils {
    public static QueryRunner runner() {
        return new QueryRunner();
    }

    /**
     * 使用dbUtils测试增删改
     * 
     * @return
     * @throws SQLException
     */
    public static int Update(String sql, Object... params) {
        Connection connection = null;
        try {
            // 1.建立连接
            connection = DruidUtils.getConnection();
            // 2.创建执行sql增删改查的对象
            QueryRunner queryRunner = runner();
            // 3.执行
            int update = queryRunner.update(connection, sql, params);
            return update;
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            DruidUtils.close(null, null, connection);
        }
    }

    /**
     * 通用的，使用dbUtils测试查询单个记录
     * 
     * @param sql
     * @param params
     * @throws Exception
     */
    public static Object QueryScalar(String sql, Object... params) {
        Connection connection = null;
        try {
            // 1.建立连接
            connection = DruidUtils.getConnection();
            // 2.创建执行sql增删改查的对象
            QueryRunner queryRunner = runner();
            // 3.执行
            Object obj = queryRunner.query(connection, sql, new ScalarHandler(), params);
            return obj;
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            DruidUtils.close(null, null, connection);
        }
    }

    /**
     * 通用的使用dbUtils测试查询一条记录
     * 
     * @param <T>
     * @param sql
     * @param clazz
     * @param params
     * @return
     * @throws SQLException
     */
    public static <T> T QueryBean(String sql, Class<T> clazz, Object... params) throws SQLException {
        Connection connection = null;
        try {
            // 1.建立连接
            connection = DruidUtils.getConnection();
            // 2.创建执行sql增删改查的对象
            QueryRunner queryRunner = runner();
            // 3.执行
            return queryRunner.query(connection, sql, new BeanHandler<T>(clazz), params);
        } finally {
            DruidUtils.close(null, null, connection);
        }
    }

    public static <T> T QueryBean(Connection connection, String sql, Class<T> clazz, Object... params)
            throws SQLException {
        QueryRunner queryRunner = runner();
        return queryRunner.query(connection, sql, new BeanHandler<T>(clazz), params);
    }

    /**
     * 通用的，使用dbUtils测试查询多条条记录
     * 
     * @param sql
     * @param params
     * @throws Exception
     */
    public static <T> List<T> QueryBeanList(String sql, Class<T> clazz, Object... params) throws SQLException {
        Connection connection = null;
        try {
            // 1.建立连接
            connection = DruidUtils.getConnection();
            // 2.创建执行sql增删改查的对象
            QueryRunner queryRunner = runner();
            // 3.执行
            List<T> list = queryRunner.query(connection, sql, new BeanListHandler<T>(clazz), params);
            return list;
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            DruidUtils.close(null, null, connection);
        }
    }

    /**
     * 执行插入操作并返回自动生成的主键
     * 
     * @param sql
     * @param params
     * @return 自动生成的主键值
     */
    public static int UpdateAndGetKey(String sql, Object... params) {
        Connection connection = null;
        try {
            // 1.建立连接
            connection = DruidUtils.getConnection();
            // 2.创建执行sql增删改查的对象
            QueryRunner queryRunner = runner();
            // 3.执行插入并获取生成的主键
            Number generatedId = (Number) queryRunner.insert(connection, sql, new ScalarHandler<>(), params);
            return generatedId.intValue();
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            DruidUtils.close(null, null, connection);
        }
    }

    public static List<HashMap<String, Object>> QueryHashMapList(String sql) {
        return java.util.Collections.emptyList();
    }

    /**
     * 通用的，使用dbUtils查询多条记录，返回List<Map<String, Object>>
     * 
     * @param sql
     * @param params
     * @return
     * @throws Exception
     */
    public static List<Map<String, Object>> QueryMapList(String sql, Object... params) throws SQLException {
        Connection connection = null;
        try {
            connection = DruidUtils.getConnection();
            QueryRunner queryRunner = runner();
            return queryRunner.query(connection, sql, new org.apache.commons.dbutils.handlers.MapListHandler(), params);
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            DruidUtils.close(null, null, connection);
        }
    }

    public static int Update(Connection connection, String sql, Object... params) throws SQLException {
        QueryRunner queryRunner = runner();
        return queryRunner.update(connection, sql, params);
    }

    public static int UpdateAndGetKey(Connection connection, String sql, Object... params) throws SQLException {
        QueryRunner queryRunner = runner();
        Number generatedId = (Number) queryRunner.insert(connection, sql, new ScalarHandler<>(), params);
        return generatedId.intValue();
    }
}
