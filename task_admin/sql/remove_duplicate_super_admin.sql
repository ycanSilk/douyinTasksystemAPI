-- 移除重复的Super Admin角色
DELETE FROM system_roles WHERE name = 'Super Admin' AND id != (
    SELECT MIN(id) FROM system_roles WHERE name = 'Super Admin'
);

-- 查看剩余的角色
SELECT * FROM system_roles;