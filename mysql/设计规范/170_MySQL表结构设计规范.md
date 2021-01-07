# MySQL表结构设计规范-丽迅物流科技-V20201225

## 表设计模版

### 基础资料表

```mysql
-- DROP TABLE IF EXISTS `bm_size`;
CREATE TABLE `bm_size` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '行ID(主键)',
  `company_id` bigint(20) NOT NULL default 1 COMMENT '租赁公司ID(SAAS预留字段)',
  ...
  ...业务字段
  ...
  `order_no` smallint(6) DEFAULT NULL COMMENT '排列序号',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态(0=未生效 1=启用 2=作废)',
  `creator` varchar(20) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间(不可人为调整)',
  `modifier` varchar(20) DEFAULT NULL COMMENT '修改人',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `remarks` varchar(100) DEFAULT NULL COMMENT '备注',
  `del_tag` varchar(2) NOT NULL DEFAULT '0' COMMENT '归档删除标识(0=正常归档，删除后数据同步下游 1=归档删除，删除后数据不同步下游)',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_size_no` (`业务主键字段`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_update_time` (`update_time`)
) COMMENT='尺码信息表';
```

### 单据表

```sql
-- DROP TABLE IF EXISTS `bl_po`;
CREATE TABLE `bl_po` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '行ID(主键)',
  `company_id` bigint(20) NOT NULL default 1 COMMENT '租赁公司ID(SAAS预留字段)',
  `bill_no` varchar(20) NOT NULL COMMENT '单据编号',
  ...
  ...业务字段
  ...
  `status` varchar(20) NOT NULL COMMENT '单据状态(10=制单 15=提交 20=审核 30=确认 99=取消 100=完结)',
  `partion_no` varchar(20) NOT NULL COMMENT '分库编码',
  `creator` varchar(20) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间(不可人为调整)',
  `modifier` varchar(20) DEFAULT NULL COMMENT '修改人',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `auditor` varchar(20) DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `remarks` varchar(100) DEFAULT NULL COMMENT '备注',
  `del_tag` varchar(2) NOT NULL DEFAULT '0' COMMENT '归档删除标识(0=正常归档，删除后数据同步下游 1=归档删除，删除后数据不同步下游)',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bill_no` (`bill_no`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_update_time` (`update_time`)
) COMMENT='采购订单主表';

-- DROP TABLE IF EXISTS `bl_po_dtl`;
CREATE TABLE `bl_po_dtl` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '行ID(主键)',
  `company_id` bigint(20) NOT NULL default 1 COMMENT '租赁公司ID(SAAS预留字段)',
  `bill_no` varchar(20) NOT NULL COMMENT '单据编号',
  ...
  ...业务字段
  ...
  `partion_no` varchar(20) NOT NULL COMMENT '分库编码',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间(不可人为调整)',
  `del_tag` varchar(2) NOT NULL DEFAULT '0' COMMENT '归档删除标识(0=正常归档，删除后数据同步下游 1=归档删除，删除后数据不同步下游)',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bno_mno_sno` (`bill_no`,业务主键字段),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_update_time` (`update_time`)
) COMMENT='采购订单明细表';

-- 唯一索引有多个字段组成的，取每个字段的第一位+后两位，如：uk_bno_mno_sno
```

## 无限分级表

```sql
-- DROP TABLE IF EXISTS `bm_category`;
CREATE TABLE `bm_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '行ID(主键)',
  `company_id` bigint(20) NOT NULL default 1 COMMENT '租赁公司ID(SAAS预留字段)',
  `category_no` varchar(20) NOT NULL COMMENT '类别编号',
  `category_name` varchar(30) NOT NULL COMMENT '类别名称',
  `parent_category_no` varchar(20) NOT NULL COMMENT '上级类别编号',
  `level_no` int(11) NOT NULL COMMENT '类别级别',
  `search_code` varchar(200) NOT NULL COMMENT '类别路径',
  `order_no` smallint(6) DEFAULT NULL COMMENT '排列序号',
  `status` smallint(6) NOT NULL DEFAULT '1' COMMENT '状态(0=未生效 1=启用 2=作废)',
  ...
  ...
  ...
  `creator` varchar(20) NOT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间(不可人为调整)',
  `modifier` varchar(20) DEFAULT NULL COMMENT '修改人',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `remarks` varchar(100) DEFAULT NULL COMMENT '备注',
  `del_tag` varchar(2) NOT NULL DEFAULT '0' COMMENT '归档删除标识(0=正常归档，删除后数据同步下游 1=归档删除，删除后数据不同步下游)',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_category_no` (`category_no`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_update_time` (`update_time`)
) AUTO_INCREMENT=1 COMMENT='类别信息表';
```

### 注意事项

1. 表结构定义中不允许包含以下定义(如使用工具导出的脚本在提交前需要去除)：

   `AUTO_INCREMENT=xxx`

   `ENGINE=InnoDB`

   `DEFAULT CHARSET=xxx`

   `COLLATE=xxx`

2. 每个表的 `id`、`company_id`、`create_time`、`update_time`、`del_tag` 为所有表必须包含的字段，`partion_no` 为分片表必须包含的字段，且设置为 `not null`；

3. 表结构统一提交到 `scm-sql-release` git 仓库进行管理与流转；

4. 表结构设计好以后需由组长审核并同意(邮件或钉钉通知阳磊再次进行规范审核)，建议开发前进行，防止开发完成后返工；

5. 转测后不允许提交 `DROP TABLE` 语句，只能以注释的形式存在，意味着表结构的修改必须提供增量修改脚本；

6. 同一个表的增量脚本，必须合并为一个DDL语句(减少执行次数)，如：

   ```mysql
   ALTER TABLE bl_om_more_deliver 
   ADD COLUMN power_unit_no VARCHAR (20) COMMENT '货权编号', 
   MODIFY COLUMN if_qrcode TINYINT (4) NOT NULL DEFAULT 0 COMMENT '是否二维码 0-否 1-是',
   DROP INDEX uk_bno_ino_sno,
   ADD UNIQUE INDEX uk_bno_ino_sno(`bill_no`,`item_no`,`size_no`,`box_no`);
   ```

7. 已上生产的表结构不允许删除、重命名字段；

8. 禁止开发人员通过工单系统自行修改表结构；

## 数据库设计规范要求

### 强制规范

1. 所有表必须使用自增的 ID 作为主键，且不用于与其他表进行关联使用(业务无关性)；

2. 基础表和单据表必须包含业务唯一索引确保业务数据的唯一性；

3. 不使用用户录入信息做为业务唯一索引，如物料编码等；

4. 字段类型只可以在 tinyint、smallint、int、bigint、decimal、char、varchar、date、datetime 中选择；

5. 所有的数据库对象以小写命名，单词间用下划线分割，不得使用汉字、特殊符号；

6. 所有对象必须包含 comment 注释；

7. 唯一索引命名为 `"uk_"+字段名`，普通索引命名为 `"idx_"+字段名`；

8. 索引字段都应设置为 `not null`；

9. 联合索引最左侧选择区分度最高的字段，比如 `bill_no`，索引建立的技巧请参考视频：

   [MySQL索引建立和优化策略.mp4 ](http://10.0.43.24:8066/video/MySQL%E7%B4%A2%E5%BC%95%E5%BB%BA%E7%AB%8B%E5%92%8C%E4%BC%98%E5%8C%96%E7%AD%96%E7%95%A5.mp4)

10. 不允许建立外键。

#### ID 不与其他表发生关系的示例

例如主表为：

	id | contract_no | contract_name
	---|-------------|--------------
	1  | C1001       | 合同1号
	2  | C1002       | 合同2号
	3  | C1003       | 合同3号

其中 id 是主键，contract_no 是唯一索引，那么明细表不应该定义为：

	id | contract_id | vender_no
	---|-------------|----------
	1  | 1           | 供应商A
	2  | 1           | 供应商B
	3  | 1           | 供应商C
	4  | 2           | 供应商D
	5  | 3           | 供应商E

正确的明细表应该定义为：

	id | contract_no | vender_no
	---|-------------|----------
	1  | C1001       | 供应商A
	2  | C1001       | 供应商B
	3  | C1001       | 供应商C
	4  | C1002       | 供应商D
	5  | C1003       | 供应商E

### 建议规范

1. 关联字段名称类型尽量保持一致，且不允许为空；
2. 字段类型长度需根据业务考虑清楚，尽量遵循取小不取大原则；
3. 字段建议给出默认值，且不允许为空；
4. 简单命名用英文单词，复杂命名尽量采用英文缩写；
5. 命名避免使用数据库关键字、保留字，如(desc、user、size、level、order、group等)；
6. 表名的长度尽量控制在 30 个字符以内。

### 开发要求

1. 数据字典统一在集成中心进行配置；
2. 编码规则统一在集成中心进行配置；
3. 表关联不能超过 3 个，超过 3 个的需要上报组长组织评审；
4. 单据表单号统一命名为 bill_no，方便基类统一处理，作为其他业务表的关联字段时，可以根据业务定义为 xxx_no，类型保持一致。

### 分区表设计要求

1、每个月数据量在300W以上的，建议按月建立分区表；

2、每天数据量在100W以上的，建议按日建立分区表；

### 表名设计要求

表名设计要求需在开发评审时确定，在定义表结构时严格遵循。以下清单需要大家集思广益，不断完善。

#### 表名前缀设计

| 系统 | 前缀 | 示例                                                         |
| ---- | ---- | ------------------------------------------------------------ |
| UC   | sys_ | sys_user                                                     |
| SMD  | bm_  | bm_vender                                                    |
| BMS  | bms_ | 基础表：bms_contract<br />单据表：bms_bl_receive（这里**注意**单据表都要增加 `bl` 进行标识） |
|      |      |                                                              |

#### 表名中缀设计

| 业务类型   | 中缀  | 示例 |
| ---------- | ----- | ---- |
| 出库       | so    |      |
| 入库       | si    |      |
| 收货       | rec   |      |
| 调拨       | allot |      |
| 盘点       | ck    |      |
| 发运       | ship  |      |
| 退货       | ret   |      |
| 委外       | sub   |      |
| 质检       | qc    |      |
| 采购       | pur   |      |
| 定额       | qu    |      |
| 非定额     | nqu   |      |
| 客户订单   | co    |      |
| 采购订单   | po    |      |
| 生产工单   | mo    |      |
| 生产计划单 | mop   |      |

#### 表名后缀设计

| 业务类型 | 后缀 | 示例                     |
| -------- | ---- | ------------------------ |
| 单据明细 | _dtl | bl_co、bl_co_dtl         |
| 申请单   | _req | bl_co_req、bl_co_req_dtl |
| 通知单   | _nt  | bl_co_nt、bl_co_nt_dtl   |
| 审批单   | _adt | bl_co_adt、bl_co_adt_dtl |

### 字段名设计要求

#### 关键字段命名

| 业务类型 | 后缀   | 示例          | 推荐数据类型定义 |
| -------- | ------ | ------------- | ---------------- |
| xx编号   | no     | material_no   | varchar(20)      |
| xx名称   | name   | material_name | varchar(60)      |
| xx日期   | date   | effect_date   | date             |
| xx时间   | time   | start_time    | datetime         |
| xx金额   | value  | sale_value    | decimal(12,2)    |
| xx数量   | qty    | sale_qty      | decimal(12,3)    |
| xx成本   | cost   | pur_cost      | decimal(16,6)    |
| xx价格   | price  | pur_price     | decimal(16,6)    |
| xx状态   | status | pur_status    | tinyint(4)       |

