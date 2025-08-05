-- =====================================================
-- CÁC QUERY THƯỜNG DÙNG CHO HỆ THỐNG QUẢN LÝ HỢP ĐỒNG
-- Common Queries for Contract Management System
-- =====================================================

-- =====================================================
-- 1. DASHBOARD QUERIES
-- =====================================================

-- Thống kê tổng quan dashboard
SELECT 
    COUNT(*) as total_contracts,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_approval,
    SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
    SUM(CASE WHEN status = 'signed' THEN 1 ELSE 0 END) as signed,
    ROUND(AVG(CASE WHEN status = 'approved' AND review_date IS NOT NULL 
        THEN DATEDIFF(review_date, upload_date) ELSE NULL END), 2) as avg_processing_days,
    ROUND((SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) as approval_rate
FROM contracts
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- Hợp đồng sắp hết hạn (30 ngày tới)
SELECT 
    c.id,
    c.title,
    c.expiry_date,
    DATEDIFF(c.expiry_date, CURDATE()) as days_until_expiry,
    u.name as created_by_name,
    u.email as created_by_email,
    cei.numeric_value
FROM contracts c
LEFT JOIN users u ON c.created_by = u.id
LEFT JOIN contract_extracted_info cei ON c.id = cei.contract_id
WHERE c.expiry_date IS NOT NULL 
    AND c.expiry_date > CURDATE()
    AND c.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
    AND c.status IN ('approved', 'signed')
ORDER BY c.expiry_date ASC;

-- Thống kê theo tháng (12 tháng gần nhất)
SELECT 
    DATE_FORMAT(created_at, '%Y-%m') as month,
    COUNT(*) as total_uploads,
    SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approvals,
    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejections
FROM contracts
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month DESC;

-- =====================================================
-- 2. CONTRACT MANAGEMENT QUERIES
-- =====================================================

-- Danh sách hợp đồng với thông tin chi tiết
SELECT 
    c.id,
    c.title,
    c.description,
    c.status,
    c.contract_category,
    c.upload_date,
    c.expiry_date,
    c.current_version,
    u.name as created_by_name,
    u.department,
    cei.contract_type,
    cei.value,
    cei.numeric_value,
    GROUP_CONCAT(ct.name) as tags,
    CASE 
        WHEN c.status = 'pending' THEN CONCAT('Bước ', c.current_step + 1, '/', (SELECT COUNT(*) FROM approval_steps WHERE contract_id = c.id))
        ELSE c.status
    END as status_detail
FROM contracts c
LEFT JOIN users u ON c.created_by = u.id
LEFT JOIN contract_extracted_info cei ON c.id = cei.contract_id
LEFT JOIN contract_tag_relations ctr ON c.id = ctr.contract_id
LEFT JOIN contract_tags ct ON ctr.tag_id = ct.id
GROUP BY c.id
ORDER BY c.created_at DESC;

-- Hợp đồng cần phê duyệt cho user cụ thể
SELECT 
    c.id,
    c.title,
    c.description,
    c.upload_date,
    cei.value,
    cei.contract_type,
    as_current.step_number,
    as_current.approver_role,
    u_creator.name as created_by_name
FROM contracts c
JOIN approval_steps as_current ON c.id = as_current.contract_id 
    AND as_current.step_number = c.current_step + 1
    AND as_current.status = 'pending'
LEFT JOIN contract_extracted_info cei ON c.id = cei.contract_id
LEFT JOIN users u_creator ON c.created_by = u_creator.id
WHERE c.status = 'pending'
    AND (as_current.approver_id = ? OR 
         (as_current.approver_id IS NULL AND as_current.approver_role = ?))
ORDER BY c.upload_date ASC;

-- Chi tiết hợp đồng với luồng phê duyệt
SELECT 
    c.*,
    cei.contract_type,
    cei.parties,
    cei.value,
    cei.duration,
    cei.summary,
    cei.detailed_summary,
    u.name as created_by_name,
    u.email as created_by_email,
    u.department
FROM contracts c
LEFT JOIN contract_extracted_info cei ON c.id = cei.contract_id
LEFT JOIN users u ON c.created_by = u.id
WHERE c.id = ?;

-- Lịch sử phê duyệt của hợp đồng
SELECT 
    as_step.step_number,
    as_step.approver_role,
    as_step.approver_name,
    as_step.status,
    as_step.comments,
    as_step.approved_at,
    u.name as approver_full_name,
    u.position
FROM approval_steps as_step
LEFT JOIN users u ON as_step.approver_id = u.id
WHERE as_step.contract_id = ?
ORDER BY as_step.step_number;

-- =====================================================
-- 3. USER MANAGEMENT QUERIES
-- =====================================================

-- Danh sách người dùng với quyền hạn
SELECT 
    u.id,
    u.email,
    u.name,
    u.role,
    u.department,
    u.position,
    u.is_active,
    u.is_approved,
    u.approval_level,
    u.max_contract_value,
    u.created_at,
    u.last_login,
    up.can_upload,
    up.can_approve,
    up.can_manage_users,
    up.can_view_analytics,
    up.can_sign,
    up.can_approve_users
FROM users u
LEFT JOIN user_permissions up ON u.id = up.user_id
ORDER BY u.created_at DESC;

-- Người dùng chờ phê duyệt
SELECT 
    u.id,
    u.email,
    u.name,
    u.role,
    u.department,
    u.position,
    u.created_at
FROM users u
WHERE u.is_approved = FALSE
ORDER BY u.created_at ASC;

-- Thống kê hoạt động người dùng
SELECT 
    u.name,
    u.department,
    COUNT(c.id) as contracts_created,
    COUNT(CASE WHEN c.status = 'approved' THEN 1 END) as contracts_approved,
    COUNT(al.id) as total_activities,
    MAX(u.last_login) as last_login
FROM users u
LEFT JOIN contracts c ON u.id = c.created_by
LEFT JOIN activity_logs al ON u.id = al.user_id
WHERE u.is_active = TRUE
GROUP BY u.id, u.name, u.department
ORDER BY contracts_created DESC;

-- =====================================================
-- 4. APPROVAL WORKFLOW QUERIES
-- =====================================================

-- Tạo luồng phê duyệt tự động dựa trên giá trị hợp đồng
DELIMITER //
CREATE PROCEDURE CreateApprovalWorkflow(
    IN contract_id VARCHAR(36),
    IN contract_value DECIMAL(15,2),
    IN contract_category VARCHAR(20)
)
BEGIN
    DECLARE step_count INT DEFAULT 0;
    
    -- Xóa các bước cũ nếu có
    DELETE FROM approval_steps WHERE contract_id = contract_id;
    
    -- Bước 1: Manager approval (luôn có)
    INSERT INTO approval_steps (contract_id, step_number, approver_role, approver_level, required_value, status)
    VALUES (contract_id, 1, 'manager', 2, contract_value, 'pending');
    SET step_count = 1;
    
    -- Bước 2: Finance approval (nếu > 100M hoặc commercial)
    IF contract_value > 100000000 OR contract_category = 'commercial' THEN
        INSERT INTO approval_steps (contract_id, step_number, approver_role, approver_level, required_value, status)
        VALUES (contract_id, step_count + 1, 'finance', 2, contract_value, 'pending');
        SET step_count = step_count + 1;
    END IF;
    
    -- Bước 3: Legal approval (nếu commercial hoặc > 500M)
    IF contract_category = 'commercial' OR contract_value > 500000000 THEN
        INSERT INTO approval_steps (contract_id, step_number, approver_role, approver_level, required_value, status)
        VALUES (contract_id, step_count + 1, 'legal', 2, contract_value, 'pending');
        SET step_count = step_count + 1;
    END IF;
    
    -- Bước cuối: Director approval (nếu > 1B)
    IF contract_value > 1000000000 THEN
        INSERT INTO approval_steps (contract_id, step_number, approver_role, approver_level, required_value, status)
        VALUES (contract_id, step_count + 1, 'director', 3, contract_value, 'pending');
        SET step_count = step_count + 1;
    END IF;
    
    SELECT step_count as total_steps;
END //
DELIMITER ;

-- Phê duyệt hợp đồng
DELIMITER //
CREATE PROCEDURE ApproveContract(
    IN contract_id VARCHAR(36),
    IN approver_id VARCHAR(36),
    IN comments TEXT
)
BEGIN
    DECLARE current_step_num INT;
    DECLARE total_steps INT;
    DECLARE next_step_num INT;
    
    -- Lấy bước hiện tại
    SELECT current_step + 1 INTO current_step_num FROM contracts WHERE id = contract_id;
    
    -- Cập nhật bước phê duyệt hiện tại
    UPDATE approval_steps 
    SET status = 'approved',
        approver_id = approver_id,
        approver_name = (SELECT name FROM users WHERE id = approver_id),
        comments = comments,
        approved_at = NOW()
    WHERE contract_id = contract_id AND step_number = current_step_num;
    
    -- Đếm tổng số bước
    SELECT COUNT(*) INTO total_steps FROM approval_steps WHERE contract_id = contract_id;
    
    -- Kiểm tra xem đã hoàn thành tất cả bước chưa
    IF current_step_num >= total_steps THEN
        -- Hoàn thành phê duyệt
        UPDATE contracts 
        SET status = 'approved',
            current_step = current_step_num,
            review_date = NOW(),
            reviewer = (SELECT name FROM users WHERE id = approver_id)
        WHERE id = contract_id;
    ELSE
        -- Chuyển sang bước tiếp theo
        UPDATE contracts 
        SET current_step = current_step_num
        WHERE id = contract_id;
    END IF;
    
    -- Ghi log
    INSERT INTO activity_logs (user_id, contract_id, action, description)
    VALUES (approver_id, contract_id, 'contract_approved', 
            CONCAT('Approved step ', current_step_num, ' of ', total_steps));
END //
DELIMITER ;

-- =====================================================
-- 5. REPORTING QUERIES
-- =====================================================

-- Báo cáo hiệu suất phê duyệt theo phòng ban
SELECT 
    u.department,
    COUNT(c.id) as total_contracts,
    AVG(CASE WHEN c.status = 'approved' AND c.review_date IS NOT NULL 
        THEN DATEDIFF(c.review_date, c.upload_date) END) as avg_processing_days,
    SUM(CASE WHEN c.status = 'approved' THEN 1 ELSE 0 END) as approved_count,
    SUM(CASE WHEN c.status = 'rejected' THEN 1 ELSE 0 END) as rejected_count,
    ROUND((SUM(CASE WHEN c.status = 'approved' THEN 1 ELSE 0 END) * 100.0 / COUNT(c.id)), 2) as approval_rate
FROM contracts c
JOIN users u ON c.created_by = u.id
WHERE c.created_at >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY u.department
ORDER BY total_contracts DESC;

-- Báo cáo giá trị hợp đồng theo tháng
SELECT 
    DATE_FORMAT(c.created_at, '%Y-%m') as month,
    COUNT(c.id) as contract_count,
    SUM(cei.numeric_value) as total_value,
    AVG(cei.numeric_value) as avg_value,
    SUM(CASE WHEN c.contract_category = 'commercial' THEN cei.numeric_value ELSE 0 END) as commercial_value,
    SUM(CASE WHEN c.contract_category = 'internal' THEN cei.numeric_value ELSE 0 END) as internal_value
FROM contracts c
LEFT JOIN contract_extracted_info cei ON c.id = cei.contract_id
WHERE c.created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    AND c.status IN ('approved', 'signed')
GROUP BY DATE_FORMAT(c.created_at, '%Y-%m')
ORDER BY month DESC;

-- Top 10 lý do từ chối
SELECT 
    rr.reason,
    rr.count,
    rr.last_used,
    GROUP_CONCAT(c.title SEPARATOR '; ') as sample_contracts
FROM rejection_reasons rr
LEFT JOIN contract_rejection_relations crr ON rr.id = crr.rejection_reason_id
LEFT JOIN contracts c ON crr.contract_id = c.id
WHERE rr.count > 0
GROUP BY rr.id, rr.reason, rr.count, rr.last_used
ORDER BY rr.count DESC
LIMIT 10;

-- Báo cáo hiệu suất người phê duyệt
SELECT 
    u.name as approver_name,
    u.role,
    u.department,
    COUNT(as_step.id) as total_approvals,
    AVG(DATEDIFF(as_step.approved_at, c.upload_date)) as avg_response_days,
    SUM(CASE WHEN as_step.status = 'approved' THEN 1 ELSE 0 END) as approved_count,
    SUM(CASE WHEN as_step.status = 'rejected' THEN 1 ELSE 0 END) as rejected_count
FROM users u
JOIN approval_steps as_step ON u.id = as_step.approver_id
JOIN contracts c ON as_step.contract_id = c.id
WHERE as_step.approved_at IS NOT NULL
    AND as_step.approved_at >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY u.id, u.name, u.role, u.department
ORDER BY total_approvals DESC;

-- =====================================================
-- 6. MAINTENANCE QUERIES
-- =====================================================

-- Dọn dẹp sessions hết hạn
DELETE FROM user_sessions 
WHERE expires_at < NOW() OR is_active = FALSE;

-- Cập nhật thống kê rejection reasons
UPDATE rejection_reasons rr
SET count = (
    SELECT COUNT(*) 
    FROM contract_rejection_relations crr 
    WHERE crr.rejection_reason_id = rr.id
);

-- Tìm hợp đồng không có thông tin trích xuất
SELECT c.id, c.title, c.created_at
FROM contracts c
LEFT JOIN contract_extracted_info cei ON c.id = cei.contract_id
WHERE cei.id IS NULL;

-- Kiểm tra tính toàn vẹn dữ liệu
SELECT 
    'Contracts without versions' as issue,
    COUNT(*) as count
FROM contracts c
LEFT JOIN contract_versions cv ON c.id = cv.contract_id
WHERE cv.id IS NULL

UNION ALL

SELECT 
    'Approval steps without contracts' as issue,
    COUNT(*) as count
FROM approval_steps as_step
LEFT JOIN contracts c ON as_step.contract_id = c.id
WHERE c.id IS NULL

UNION ALL

SELECT 
    'Comments without users' as issue,
    COUNT(*) as count
FROM contract_comments cc
LEFT JOIN users u ON cc.user_id = u.id
WHERE u.id IS NULL;

-- =====================================================
-- 7. PERFORMANCE OPTIMIZATION QUERIES
-- =====================================================

-- Phân tích hiệu suất index
SELECT 
    table_name,
    index_name,
    cardinality,
    CASE 
        WHEN cardinality = 0 THEN 'Unused'
        WHEN cardinality < 100 THEN 'Low usage'
        ELSE 'Good'
    END as index_status
FROM information_schema.statistics 
WHERE table_schema = 'contract_management'
    AND index_name != 'PRIMARY'
ORDER BY cardinality DESC;

-- Tìm các bảng lớn
SELECT 
    table_name,
    table_rows,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)',
    ROUND((data_length / 1024 / 1024), 2) AS 'Data (MB)',
    ROUND((index_length / 1024 / 1024), 2) AS 'Index (MB)'
FROM information_schema.tables 
WHERE table_schema = 'contract_management'
ORDER BY (data_length + index_length) DESC;

-- Kiểm tra slow queries (cần enable slow query log)
SELECT 
    sql_text,
    exec_count,
    avg_timer_wait/1000000000 as avg_time_seconds,
    sum_timer_wait/1000000000 as total_time_seconds
FROM performance_schema.events_statements_summary_by_digest
WHERE schema_name = 'contract_management'
ORDER BY avg_timer_wait DESC
LIMIT 10;

-- =====================================================
-- 8. BACKUP & RECOVERY QUERIES
-- =====================================================

-- Tạo backup script
SELECT CONCAT(
    'mysqldump -u root -p contract_management > backup_',
    DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s'),
    '.sql'
) as backup_command;

-- Kiểm tra kích thước database
SELECT 
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Database Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'contract_management';

-- Lệnh tối ưu hóa bảng
SELECT CONCAT('OPTIMIZE TABLE ', table_name, ';') as optimize_command
FROM information_schema.tables 
WHERE table_schema = 'contract_management'
    AND table_type = 'BASE TABLE';

-- =====================================================
-- 9. SECURITY QUERIES
-- =====================================================

-- Kiểm tra quyền truy cập
SELECT 
    user,
    host,
    authentication_string,
    password_expired,
    account_locked
FROM mysql.user 
WHERE user LIKE '%contract%';

-- Audit trail - hoạt động đáng ngờ
SELECT 
    al.created_at,
    u.name,
    u.email,
    al.action,
    al.description,
    al.ip_address
FROM activity_logs al
JOIN users u ON al.user_id = u.id
WHERE al.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
    AND (al.action LIKE '%delete%' OR al.action LIKE '%admin%')
ORDER BY al.created_at DESC;

-- Phiên đăng nhập bất thường
SELECT 
    us.user_id,
    u.name,
    u.email,
    us.ip_address,
    us.created_at,
    us.expires_at
FROM user_sessions us
JOIN users u ON us.user_id = u.id
WHERE us.is_active = TRUE
    AND (us.ip_address NOT LIKE '192.168.%' 
         OR TIMESTAMPDIFF(HOUR, us.created_at, NOW()) > 24)
ORDER BY us.created_at DESC;

-- =====================================================
-- HOÀN THÀNH
-- =====================================================

SELECT 'Common queries loaded successfully!' as message;