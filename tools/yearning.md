# yearning

Yearning MYSQL SQL语句审核平台。提供查询审计，SQL审核，SQL回滚，自定义工作流等多种功能。

[官网](https://yearning.io/)

[github](https://github.com/cookieY/Yearning)

[常见问题](https://next.yearning.io/feeback.html)

[docker安装](https://github.com/cookieY/Yearning/tree/next/docker)

[Yearning Guide](https://next.yearning.io/guide/install.html)

```sh
docker exec -it yearning bash
# 初始化(先把已有表全部删除)
./Yearning install
# 升级
# ./Yearning migrate
# 重置admin密码 
# ./Yearning reset_super

# 默认账号：admin，默认密码：Yearning_admin
```
