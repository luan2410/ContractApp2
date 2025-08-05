# Database Schema - Hệ thống Quản lý và Phê duyệt Hợp đồng

## Tổng quan

Database được thiết kế cho hệ thống quản lý và phê duyệt hợp đồng với MariaDB, bao gồm đầy đủ các tính năng:

- Quản lý người dùng và phân quyền
- Quản lý hợp đồng và phiên bản
- Luồng phê duyệt nhiều bước
- Chữ ký điện tử
- Thống kê và báo cáo
- Nhắc nhở và thông báo

## Cấu trúc Database

### Bảng chính

1. **users** - Quản lý người dùng
2. **contracts** - Thông tin hợp đồng chính
3. **contract_extracted_info** - Thông tin trích xuất từ OCR
4. **contract_versions** - Lịch sử phiên bản
5. **approval_steps** - Các bước phê duyệt
6. **e_signature_requests** - Yêu cầu chữ ký điện tử

### Bảng hỗ trợ

- **user_permissions** - Quyền hạn chi tiết
- **contract_tags** - Tags phân loại
- **contract_comments** - Bình luận và trao đổi
- **contract_reminders** - Nhắc nhở
- **activity_logs** - Lịch sử hoạt động
- **dashboard_stats** - Thống kê dashboard

## Cài đặt

### 1. Tạo Database

```sql
mysql -u root -p < database/schema.sql
```

### 2. Cấu hình User

Thay đổi password mặc định:

```sql
ALTER USER 'contract_app'@'localhost' IDENTIFIED BY 'your_secure_password';
```

### 3. Cấu hình ứng dụng

Tạo file `.env`:

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=contract_management
DB_USER=contract_app
DB_PASSWORD=your_secure_password
```

## Tính năng đặc biệt

### 1. Stored Procedures

- `UpdateDashboardStats(date)` - Cập nhật thống kê
- `GenerateContractNumber(type, year)` - Tạo số hợp đồng tự động

### 2. Triggers

- Tự động cập nhật thống kê khi có thay đổi
- Tự động tạo quyền cho user mới
- Ghi log hoạt động

### 3. Views

- `v_contract_overview` - Tổng quan hợp đồng
- `v_monthly_stats` - Thống kê theo tháng
- `v_expiring_contracts` - Hợp đồng sắp hết hạn

### 4. Events

- Tự động dọn dẹp sessions hết hạn
- Cập nhật thống kê hàng ngày

## Indexes

Database được tối ưu với các indexes:

- Primary keys và foreign keys
- Composite indexes cho truy vấn phức tạp
- Indexes cho các trường thường xuyên filter/sort

## Bảo mật

- Phân quyền user riêng biệt cho ứng dụng
- Mã hóa password với bcrypt
- Session management
- Activity logging

## Backup & Maintenance

### Backup hàng ngày

```bash
mysqldump -u root -p contract_management > backup_$(date +%Y%m%d).sql
```

### Maintenance

```sql
-- Kiểm tra và sửa chữa bảng
CHECK TABLE contracts;
REPAIR TABLE contracts;

-- Tối ưu bảng
OPTIMIZE TABLE contracts;

-- Phân tích và cập nhật statistics
ANALYZE TABLE contracts;
```

## Monitoring

### Queries quan trọng cần monitor

```sql
-- Top slow queries
SELECT * FROM information_schema.PROCESSLIST WHERE Time > 10;

-- Table sizes
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'contract_management'
ORDER BY (data_length + index_length) DESC;

-- Index usage
SELECT 
    table_name,
    index_name,
    cardinality
FROM information_schema.statistics 
WHERE table_schema = 'contract_management';
```

## Scaling

### Khi cần scale

1. **Read Replicas** - Tách read/write operations
2. **Partitioning** - Phân vùng bảng lớn theo thời gian
3. **Archiving** - Lưu trữ dữ liệu cũ
4. **Caching** - Redis/Memcached cho queries thường xuyên

### Partition example

```sql
-- Partition bảng contracts theo năm
ALTER TABLE contracts 
PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

## Troubleshooting

### Các vấn đề thường gặp

1. **Slow queries** - Kiểm tra indexes và query plans
2. **Lock timeouts** - Tối ưu transaction size
3. **Storage full** - Implement archiving strategy
4. **Connection limits** - Tăng max_connections

### Debug queries

```sql
-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;

-- Check current connections
SHOW PROCESSLIST;

-- Check table locks
SHOW OPEN TABLES WHERE In_use > 0;
```

## Migration Scripts

Khi cần update schema, tạo migration scripts:

```sql
-- migration_001_add_new_field.sql
ALTER TABLE contracts ADD COLUMN new_field VARCHAR(255) NULL;

-- migration_002_create_index.sql
CREATE INDEX idx_new_field ON contracts(new_field);
```

## Performance Tips

1. **Sử dụng prepared statements**
2. **Batch operations** cho insert/update nhiều records
3. **Connection pooling**
4. **Query optimization** với EXPLAIN
5. **Regular maintenance** (OPTIMIZE, ANALYZE)

## Support

Để được hỗ trợ, vui lòng cung cấp:

1. MariaDB version
2. Error logs
3. Query execution plans
4. System resources (CPU, RAM, Disk)