-- sysbench_json_test.lua
-- 假设有一个表 test_json_table，其中包含一列 json_data 是JSON类型
pathtest = string.match(test, "(.*/)")

if pathtest then
   dofile(pathtest .. "common.lua")
else
   require("common")
end

function prepare(db, options)
    -- 创建表和索引（如果需要）
    db_query([[
        CREATE TABLE IF NOT EXISTS test_json_table (
            id INT AUTO_INCREMENT PRIMARY KEY,
            json_data JSON
        ) ENGINE=InnoDB;
    ]])
end

function cleanup(db, options)
    -- 清理测试数据
    db_query("TRUNCATE TABLE test_json_table;")
end

function event(db, options)
    local jsonData = '{"key": "value"}'
    -- 插入JSON数据
    db_query("INSERT INTO test_json_table (json_data) VALUES " .. string.format("('%s')",jsonData))

    -- 查询JSON数据（示例查询）
    db_query("SELECT json_data FROM test_json_table WHERE json_extract(json_data, '$.key') = 'value' limit 1000;")
end
