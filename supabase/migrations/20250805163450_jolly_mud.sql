-- =====================================================
-- HỆ THỐNG QUẢN LÝ VÀ PHÊ DUYỆT HỢP ĐỒNG
-- Database Schema for MariaDB
-- =====================================================

-- Tạo database
CREATE DATABASE IF NOT EXISTS contract_management 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE contract_management;

-- =====================================================
-- BẢNG NGƯỜI DÙNG (USERS)
-- =====================================================
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role ENUM('employee', 'manager', 'admin', 'legal', 'director', 'finance') NOT NULL DEFAULT 'employee',
    department VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    avatar VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_approved BOOLEAN DEFAULT FALSE,
    approval_level INT DEFAULT 1,
    max_contract_value DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_department (department),
    INDEX idx_is_active (is_active),
    INDEX idx_is_approved (is_approved)
);

-- =====================================================
-- BẢNG QUYỀN HẠN NGƯỜI DÙNG (USER_PERMISSIONS)
-- =====================================================
CREATE TABLE user_permissions (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id VARCHAR(36) NOT NULL,
    can_upload BOOLEAN DEFAULT TRUE,
    can_approve BOOLEAN DEFAULT FALSE,
    can_manage_users BOOLEAN DEFAULT FALSE,
    can_view_analytics BOOLEAN DEFAULT FALSE,
    can_sign BOOLEAN DEFAULT FALSE,
    can_approve_users BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_permission (user_id)
);

-- =====================================================
-- BẢNG TAGS HỢP ĐỒNG (CONTRACT_TAGS)
-- =====================================================
CREATE TABLE contract_tags (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(100) NOT NULL,
    color VARCHAR(20) DEFAULT 'blue',
    category VARCHAR(50) DEFAULT 'general',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_tag_name (name),
    INDEX idx_category (category)
);

-- =====================================================
-- BẢNG HỢP ĐỒNG CHÍNH (CONTRACTS)
-- =====================================================
CREATE TABLE contracts (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    status ENUM('draft', 'pending', 'approved', 'rejected', 'signed', 'expired') DEFAULT 'draft',
    is_based_on_existing BOOLEAN DEFAULT FALSE,
    parent_contract_id VARCHAR(36) NULL,
    contract_category ENUM('internal', 'commercial') DEFAULT 'internal',
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    review_date TIMESTAMP NULL,
    expiry_date TIMESTAMP NULL,
    renewal_date TIMESTAMP NULL,
    reviewer VARCHAR(255) NULL,
    comments TEXT NULL,
    current_version INT DEFAULT 1,
    current_step INT DEFAULT 0,
    final_pdf_url VARCHAR(1000) NULL,
    created_by VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (parent_contract_id) REFERENCES contracts(id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_category (contract_category),
    INDEX idx_upload_date (upload_date),
    INDEX idx_expiry_date (expiry_date),
    INDEX idx_created_by (created_by),
    INDEX idx_parent_contract (parent_contract_id)
);

-- =====================================================
-- BẢNG THÔNG TIN TRÍCH XUẤT HỢP ĐỒNG (CONTRACT_EXTRACTED_INFO)
-- =====================================================
CREATE TABLE contract_extracted_info (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    contract_id VARCHAR(36) NOT NULL,
    contract_type VARCHAR(200),
    parties JSON, -- Mảng các bên tham gia
    value VARCHAR(200),
    numeric_value DECIMAL(15,2) DEFAULT 0,
    duration VARCHAR(200),
    summary TEXT,
    full_text LONGTEXT,
    detailed_summary JSON, -- Lưu thông tin chi tiết dưới dạng JSON
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    UNIQUE KEY unique_contract_info (contract_id),
    INDEX idx_contract_type (contract_type),
    INDEX idx_numeric_value (numeric_value)
);

-- =====================================================
-- BẢNG PHIÊN BẢN HỢP ĐỒNG (CONTRACT_VERSIONS)
-- =====================================================
CREATE TABLE contract_versions (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    contract_id VARCHAR(36) NOT NULL,
    version INT NOT NULL,
    title VARCHAR(500) NOT NULL,
    content LONGTEXT,
    changes TEXT,
    created_by VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id),
    UNIQUE KEY unique_contract_version (contract_id, version),
    INDEX idx_contract_id (contract_id),
    INDEX idx_version (version)
);

-- =====================================================
-- BẢNG BƯỚC PHÊ DUYỆT (APPROVAL_STEPS)
-- =====================================================
CREATE TABLE approval_steps (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    contract_id VARCHAR(36) NOT NULL,
    step_number INT NOT NULL,
    approver_role VARCHAR(50) NOT NULL,
    approver_level INT DEFAULT 1,
    required_value DECIMAL(15,2) NULL,
    approver_name VARCHAR(255) NULL,
    approver_id VARCHAR(36) NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    comments TEXT NULL,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    FOREIGN KEY (approver_id) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY unique_contract_step (contract_id, step_number),
    INDEX idx_contract_id (contract_id),
    INDEX idx_status (status),
    INDEX idx_approver_id (approver_id)
);

-- =====================================================
-- BẢNG NHẮC NHỞ HỢP ĐỒNG (CONTRACT_REMINDERS)
-- =====================================================
CREATE TABLE contract_reminders (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    contract_id VARCHAR(36) NOT NULL,
    type ENUM('expiry', 'renewal', 'review') NOT NULL,
    reminder_date TIMESTAMP NOT NULL,
    message TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    INDEX idx_contract_id (contract_id),
    INDEX idx_reminder_date (reminder_date),
    INDEX idx_type (type),
    INDEX idx_is_active (is_active)
);

-- =====================================================
-- BẢNG CHỮ KÝ ĐIỆN TỬ (E_SIGNATURE_REQUESTS)
-- =====================================================
CREATE TABLE e_signature_requests (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    contract_id VARCHAR(36) NOT NULL,
    provider ENUM('docusign', 'adobe', 'viettel') NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    external_id VARCHAR(255) NULL, -- ID từ nhà cung cấp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    UNIQUE KEY unique_contract_signature (contract_id),
    INDEX idx_status (status),
    INDEX idx_provider (provider)
);

-- =====================================================
-- BẢNG NGƯỜI KÝ (E_SIGNATURE_SIGNERS)
-- =====================================================
CREATE TABLE e_signature_signers (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    signature_request_id VARCHAR(36) NOT NULL,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL,
    sign_order INT DEFAULT 1,
    signed BOOLEAN DEFAULT FALSE,
    signed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (signature_request_id) REFERENCES e_signature_requests(id) ON DELETE CASCADE,
    INDEX idx_signature_request (signature_request_id),
    INDEX idx_email (email),
    INDEX idx_signed (signed)
);

-- =====================================================
-- BẢNG LIÊN KẾT TAGS VỚI HỢP ĐỒNG (CONTRACT_TAG_RELATIONS)
-- =====================================================
CREATE TABLE contract_tag_relations (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    contract_id VARCHAR(36) NOT NULL,
    tag_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES contract_tags(id) ON DELETE CASCADE,
    UNIQUE KEY unique_contract_tag (contract_id, tag_id),
    INDEX idx_contract_id (contract_id),
    INDEX idx_tag_id (tag_id)
);

-- =====================================================
-- BẢNG BÌNH LUẬN HỢP ĐỒNG (CONTRACT_COMMENTS)
-- =====================================================
CREATE TABLE contract_comments (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    contract_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    content TEXT NOT NULL,
    highlighted_text TEXT NULL,
    position_start INT NULL,
    position_end INT NULL,
    is_resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_contract_id (contract_id),
    INDEX idx_user_id (user_id),
    INDEX idx_is_resolved (is_resolved),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- BẢNG LỊCH SỬ HOẠT ĐỘNG (ACTIVITY_LOGS)
-- =====================================================
CREATE TABLE activity_logs (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id VARCHAR(36) NOT NULL,
    contract_id VARCHAR(36) NULL,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    metadata JSON NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_contract_id (contract_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- BẢNG THỐNG KÊ DASHBOARD (DASHBOARD_STATS)
-- =====================================================
CREATE TABLE dashboard_stats (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    date DATE NOT NULL,
    total_contracts INT DEFAULT 0,
    pending_approval INT DEFAULT 0,
    approved INT DEFAULT 0,
    rejected INT DEFAULT 0,
    expiring_soon INT DEFAULT 0,
    average_processing_time DECIMAL(5,2) DEFAULT 0,
    approval_rate DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_date_stats (date),
    INDEX idx_date (date)
);

-- =====================================================
-- BẢNG LÝ DO TỪ CHỐI (REJECTION_REASONS)
-- =====================================================
CREATE TABLE rejection_reasons (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    reason VARCHAR(500) NOT NULL,
    count INT DEFAULT 1,
    last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_reason (reason),
    INDEX idx_count (count),
    INDEX idx_last_used (last_used)
);

-- =====================================================
-- BẢNG LIÊN KẾT LÝ DO TỪ CHỐI VỚI HỢP ĐỒNG
-- =====================================================
CREATE TABLE contract_rejection_relations (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    contract_id VARCHAR(36) NOT NULL,
    rejection_reason_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    FOREIGN KEY (rejection_reason_id) REFERENCES rejection_reasons(id) ON DELETE CASCADE,
    UNIQUE KEY unique_contract_rejection (contract_id, rejection_reason_id),
    INDEX idx_contract_id (contract_id),
    INDEX idx_rejection_reason_id (rejection_reason_id)
);

-- =====================================================
-- BẢNG SESSIONS (Quản lý phiên đăng nhập)
-- =====================================================
CREATE TABLE user_sessions (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id VARCHAR(36) NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_token (token),
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_active (is_active)
);

-- =====================================================
-- BẢNG CẤU HÌNH HỆ THỐNG (SYSTEM_SETTINGS)
-- =====================================================
CREATE TABLE system_settings (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_setting_key (setting_key)
);

-- =====================================================
-- DỮ LIỆU MẪU (SAMPLE DATA)
-- =====================================================

-- Thêm admin mặc định
INSERT INTO users (id, email, password_hash, name, role, department, position, is_active, is_approved, approval_level, max_contract_value) 
VALUES 
('admin-001', 'admin@company.com', '$2b$10$example_hash', 'Quản trị viên', 'admin', 'IT', 'System Administrator', TRUE, TRUE, 4, 999999999.99);

-- Thêm quyền cho admin
INSERT INTO user_permissions (user_id, can_upload, can_approve, can_manage_users, can_view_analytics, can_sign, can_approve_users)
VALUES ('admin-001', TRUE, TRUE, TRUE, TRUE, TRUE, TRUE);

-- Thêm một số tags mặc định
INSERT INTO contract_tags (name, color, category) VALUES
('Hợp đồng lao động', 'blue', 'HR'),
('Hợp đồng mua bán', 'green', 'Commercial'),
('Hợp đồng dịch vụ', 'purple', 'Service'),
('Hợp đồng thuê', 'orange', 'Rental'),
('Hợp đồng bảo mật', 'red', 'Security'),
('Hợp đồng IT', 'indigo', 'Technology');

-- Thêm cấu hình hệ thống mặc định
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('max_file_size', '10485760', 'Kích thước file tối đa (bytes)'),
('allowed_file_types', 'pdf,jpg,jpeg,png', 'Các loại file được phép'),
('default_approval_steps', '2', 'Số bước phê duyệt mặc định'),
('contract_expiry_warning_days', '30', 'Số ngày cảnh báo trước khi hết hạn'),
('auto_backup_enabled', 'true', 'Tự động sao lưu dữ liệu'),
('email_notifications_enabled', 'true', 'Bật thông báo email');

-- =====================================================
-- STORED PROCEDURES & FUNCTIONS
-- =====================================================

DELIMITER //

-- Function tính toán thống kê dashboard
CREATE PROCEDURE UpdateDashboardStats(IN target_date DATE)
BEGIN
    DECLARE total_count INT DEFAULT 0;
    DECLARE pending_count INT DEFAULT 0;
    DECLARE approved_count INT DEFAULT 0;
    DECLARE rejected_count INT DEFAULT 0;
    DECLARE expiring_count INT DEFAULT 0;
    DECLARE avg_processing DECIMAL(5,2) DEFAULT 0;
    DECLARE approval_rate_calc DECIMAL(5,2) DEFAULT 0;
    
    -- Tính tổng số hợp đồng
    SELECT COUNT(*) INTO total_count FROM contracts WHERE DATE(created_at) = target_date;
    
    -- Tính số hợp đồng chờ duyệt
    SELECT COUNT(*) INTO pending_count FROM contracts WHERE status = 'pending' AND DATE(created_at) = target_date;
    
    -- Tính số hợp đồng đã duyệt
    SELECT COUNT(*) INTO approved_count FROM contracts WHERE status = 'approved' AND DATE(created_at) = target_date;
    
    -- Tính số hợp đồng bị từ chối
    SELECT COUNT(*) INTO rejected_count FROM contracts WHERE status = 'rejected' AND DATE(created_at) = target_date;
    
    -- Tính số hợp đồng sắp hết hạn
    SELECT COUNT(*) INTO expiring_count 
    FROM contracts 
    WHERE expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);
    
    -- Tính tỷ lệ phê duyệt
    IF total_count > 0 THEN
        SET approval_rate_calc = (approved_count / total_count) * 100;
    END IF;
    
    -- Cập nhật hoặc thêm mới thống kê
    INSERT INTO dashboard_stats (date, total_contracts, pending_approval, approved, rejected, expiring_soon, approval_rate)
    VALUES (target_date, total_count, pending_count, approved_count, rejected_count, expiring_count, approval_rate_calc)
    ON DUPLICATE KEY UPDATE
        total_contracts = total_count,
        pending_approval = pending_count,
        approved = approved_count,
        rejected = rejected_count,
        expiring_soon = expiring_count,
        approval_rate = approval_rate_calc,
        updated_at = CURRENT_TIMESTAMP;
END //

-- Function tự động tạo số hợp đồng
CREATE FUNCTION GenerateContractNumber(contract_type VARCHAR(50), year INT) 
RETURNS VARCHAR(50)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE contract_count INT DEFAULT 0;
    DECLARE contract_number VARCHAR(50);
    DECLARE type_prefix VARCHAR(10);
    
    -- Xác định prefix theo loại hợp đồng
    CASE contract_type
        WHEN 'commercial' THEN SET type_prefix = 'TM';
        WHEN 'internal' THEN SET type_prefix = 'NB';
        ELSE SET type_prefix = 'HD';
    END CASE;
    
    -- Đếm số hợp đồng trong năm
    SELECT COUNT(*) INTO contract_count 
    FROM contracts 
    WHERE YEAR(created_at) = year AND contract_category = contract_type;
    
    -- Tạo số hợp đồng
    SET contract_number = CONCAT(type_prefix, '/', year, '/', LPAD(contract_count + 1, 4, '0'));
    
    RETURN contract_number;
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS
-- =====================================================

DELIMITER //

-- Trigger tự động cập nhật thống kê khi có hợp đồng mới
CREATE TRIGGER after_contract_insert
AFTER INSERT ON contracts
FOR EACH ROW
BEGIN
    CALL UpdateDashboardStats(DATE(NEW.created_at));
END //

-- Trigger tự động cập nhật thống kê khi trạng thái hợp đồng thay đổi
CREATE TRIGGER after_contract_status_update
AFTER UPDATE ON contracts
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        CALL UpdateDashboardStats(DATE(NEW.updated_at));
    END IF;
END //

-- Trigger tự động tạo quyền mặc định cho user mới
CREATE TRIGGER after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO user_permissions (user_id, can_upload, can_approve, can_manage_users, can_view_analytics, can_sign, can_approve_users)
    VALUES (
        NEW.id,
        TRUE,
        CASE WHEN NEW.role IN ('manager', 'admin', 'legal', 'director', 'finance') THEN TRUE ELSE FALSE END,
        CASE WHEN NEW.role = 'admin' THEN TRUE ELSE FALSE END,
        CASE WHEN NEW.role IN ('manager', 'admin', 'director') THEN TRUE ELSE FALSE END,
        CASE WHEN NEW.role IN ('manager', 'admin', 'legal', 'director', 'finance') THEN TRUE ELSE FALSE END,
        CASE WHEN NEW.role IN ('admin', 'director') THEN TRUE ELSE FALSE END
    );
END //

-- Trigger ghi log hoạt động
CREATE TRIGGER after_contract_update
AFTER UPDATE ON contracts
FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (user_id, contract_id, action, description)
    VALUES (
        NEW.created_by,
        NEW.id,
        'contract_updated',
        CONCAT('Contract status changed from ', OLD.status, ' to ', NEW.status)
    );
END //

DELIMITER ;

-- =====================================================
-- INDEXES BỔ SUNG CHO HIỆU SUẤT
-- =====================================================

-- Composite indexes cho các truy vấn phức tạp
CREATE INDEX idx_contracts_status_date ON contracts(status, created_at);
CREATE INDEX idx_contracts_category_status ON contracts(contract_category, status);
CREATE INDEX idx_contracts_expiry_status ON contracts(expiry_date, status);
CREATE INDEX idx_approval_steps_contract_status ON approval_steps(contract_id, status);
CREATE INDEX idx_activity_logs_user_date ON activity_logs(user_id, created_at);
CREATE INDEX idx_comments_contract_resolved ON contract_comments(contract_id, is_resolved);

-- =====================================================
-- VIEWS CHO BÁO CÁO
-- =====================================================

-- View thống kê tổng quan
CREATE VIEW v_contract_overview AS
SELECT 
    c.id,
    c.title,
    c.status,
    c.contract_category,
    c.created_at,
    c.expiry_date,
    u.name as created_by_name,
    u.department,
    cei.numeric_value,
    cei.contract_type,
    GROUP_CONCAT(ct.name) as tags
FROM contracts c
LEFT JOIN users u ON c.created_by = u.id
LEFT JOIN contract_extracted_info cei ON c.id = cei.contract_id
LEFT JOIN contract_tag_relations ctr ON c.id = ctr.contract_id
LEFT JOIN contract_tags ct ON ctr.tag_id = ct.id
GROUP BY c.id;

-- View thống kê theo tháng
CREATE VIEW v_monthly_stats AS
SELECT 
    YEAR(created_at) as year,
    MONTH(created_at) as month,
    COUNT(*) as total_contracts,
    SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved_count,
    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_count,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_count,
    AVG(CASE WHEN status = 'approved' AND review_date IS NOT NULL 
        THEN DATEDIFF(review_date, created_at) ELSE NULL END) as avg_processing_days
FROM contracts
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year DESC, month DESC;

-- View hợp đồng sắp hết hạn
CREATE VIEW v_expiring_contracts AS
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
    AND c.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 60 DAY)
    AND c.status IN ('approved', 'signed')
ORDER BY c.expiry_date ASC;

-- =====================================================
-- BACKUP & MAINTENANCE
-- =====================================================

-- Event tự động dọn dẹp sessions hết hạn
CREATE EVENT IF NOT EXISTS cleanup_expired_sessions
ON SCHEDULE EVERY 1 HOUR
DO
  DELETE FROM user_sessions WHERE expires_at < NOW();

-- Event tự động cập nhật thống kê hàng ngày
CREATE EVENT IF NOT EXISTS daily_stats_update
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '01:00:00')
DO
  CALL UpdateDashboardStats(CURDATE() - INTERVAL 1 DAY);

-- Bật event scheduler
SET GLOBAL event_scheduler = ON;

-- =====================================================
-- SECURITY & PERMISSIONS
-- =====================================================

-- Tạo user cho ứng dụng (thay đổi password trong production)
CREATE USER IF NOT EXISTS 'contract_app'@'localhost' IDENTIFIED BY 'secure_password_here';
GRANT SELECT, INSERT, UPDATE, DELETE ON contract_management.* TO 'contract_app'@'localhost';
GRANT EXECUTE ON contract_management.* TO 'contract_app'@'localhost';
FLUSH PRIVILEGES;

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================
SELECT 'Database schema created successfully!' as message;
SELECT 'Remember to:' as reminder;
SELECT '1. Change default passwords' as step1;
SELECT '2. Configure backup strategy' as step2;
SELECT '3. Set up monitoring' as step3;
SELECT '4. Review and adjust indexes based on usage patterns' as step4;