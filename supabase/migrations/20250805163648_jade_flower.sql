-- =====================================================
-- DỮ LIỆU MẪU CHO HỆ THỐNG QUẢN LÝ HỢP ĐỒNG
-- Sample Data for Contract Management System
-- =====================================================

USE contract_management;

-- =====================================================
-- NGƯỜI DÙNG MẪU (SAMPLE USERS)
-- =====================================================

-- Admin
INSERT INTO users (id, email, password_hash, name, role, department, position, is_active, is_approved, approval_level, max_contract_value) VALUES
('user-admin-001', 'admin@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Nguyễn Văn Admin', 'admin', 'IT', 'Quản trị viên hệ thống', TRUE, TRUE, 4, 999999999.99),

-- Directors
('user-director-001', 'director@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Trần Thị Minh', 'director', 'Executive', 'Giám đốc điều hành', TRUE, TRUE, 3, 5000000000.00),
('user-director-002', 'ceo@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Lê Văn Thành', 'director', 'Executive', 'Tổng giám đốc', TRUE, TRUE, 3, 10000000000.00),

-- Managers
('user-manager-001', 'manager.hr@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Phạm Thị Lan', 'manager', 'HR', 'Trưởng phòng Nhân sự', TRUE, TRUE, 2, 1000000000.00),
('user-manager-002', 'manager.it@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Hoàng Văn Đức', 'manager', 'IT', 'Trưởng phòng IT', TRUE, TRUE, 2, 2000000000.00),
('user-manager-003', 'manager.sales@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Vũ Thị Hoa', 'manager', 'Sales', 'Trưởng phòng Kinh doanh', TRUE, TRUE, 2, 3000000000.00),

-- Legal & Finance
('user-legal-001', 'legal@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Đỗ Văn Luật', 'legal', 'Legal', 'Chuyên viên pháp chế', TRUE, TRUE, 2, 5000000000.00),
('user-finance-001', 'finance@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Bùi Thị Mai', 'finance', 'Finance', 'Kế toán trưởng', TRUE, TRUE, 2, 2000000000.00),

-- Employees
('user-employee-001', 'employee1@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Nguyễn Văn An', 'employee', 'IT', 'Lập trình viên', TRUE, TRUE, 1, 100000000.00),
('user-employee-002', 'employee2@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Trần Thị Bình', 'employee', 'HR', 'Chuyên viên nhân sự', TRUE, TRUE, 1, 50000000.00),
('user-employee-003', 'employee3@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Lê Văn Cường', 'employee', 'Sales', 'Nhân viên kinh doanh', TRUE, TRUE, 1, 200000000.00),
('user-employee-004', 'employee4@company.com', '$2b$10$rOzWz8nFkrCjGKjNQqQqKOXYZ9nFkrCjGKjNQqQqKOXYZ9nFkrCjGK', 'Phạm Thị Dung', 'employee', 'Finance', 'Kế toán viên', TRUE, TRUE, 1, 100000000.00);

-- =====================================================
-- QUYỀN HẠN NGƯỜI DÙNG (USER PERMISSIONS)
-- =====================================================

INSERT INTO user_permissions (user_id, can_upload, can_approve, can_manage_users, can_view_analytics, can_sign, can_approve_users) VALUES
-- Admin
('user-admin-001', TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),

-- Directors
('user-director-001', TRUE, TRUE, FALSE, TRUE, TRUE, TRUE),
('user-director-002', TRUE, TRUE, FALSE, TRUE, TRUE, TRUE),

-- Managers
('user-manager-001', TRUE, TRUE, FALSE, TRUE, TRUE, FALSE),
('user-manager-002', TRUE, TRUE, FALSE, TRUE, TRUE, FALSE),
('user-manager-003', TRUE, TRUE, FALSE, TRUE, TRUE, FALSE),

-- Legal & Finance
('user-legal-001', TRUE, TRUE, FALSE, TRUE, TRUE, FALSE),
('user-finance-001', TRUE, TRUE, FALSE, TRUE, TRUE, FALSE),

-- Employees
('user-employee-001', TRUE, FALSE, FALSE, FALSE, FALSE, FALSE),
('user-employee-002', TRUE, FALSE, FALSE, FALSE, FALSE, FALSE),
('user-employee-003', TRUE, FALSE, FALSE, FALSE, FALSE, FALSE),
('user-employee-004', TRUE, FALSE, FALSE, FALSE, FALSE, FALSE);

-- =====================================================
-- TAGS HỢP ĐỒNG (CONTRACT TAGS)
-- =====================================================

INSERT INTO contract_tags (id, name, color, category) VALUES
('tag-001', 'Hợp đồng lao động', 'blue', 'HR'),
('tag-002', 'Hợp đồng mua bán', 'green', 'Commercial'),
('tag-003', 'Hợp đồng dịch vụ', 'purple', 'Service'),
('tag-004', 'Hợp đồng thuê', 'orange', 'Rental'),
('tag-005', 'Hợp đồng bảo mật', 'red', 'Security'),
('tag-006', 'Hợp đồng IT', 'indigo', 'Technology'),
('tag-007', 'Hợp đồng tư vấn', 'yellow', 'Consulting'),
('tag-008', 'Hợp đồng xây dựng', 'gray', 'Construction'),
('tag-009', 'Hợp đồng vận chuyển', 'blue', 'Logistics'),
('tag-010', 'Hợp đồng bảo hiểm', 'purple', 'Insurance');

-- =====================================================
-- HỢP ĐỒNG MẪU (SAMPLE CONTRACTS)
-- =====================================================

INSERT INTO contracts (id, title, description, status, contract_category, upload_date, review_date, expiry_date, reviewer, comments, current_version, current_step, created_by) VALUES
-- Hợp đồng đã duyệt
('contract-001', 'Hợp đồng mua sắm thiết bị IT 2024', 'Hợp đồng mua sắm máy tính và thiết bị mạng cho công ty', 'approved', 'commercial', '2024-01-15 09:00:00', '2024-01-18 14:30:00', '2024-12-31 23:59:59', 'Hoàng Văn Đức', 'Đã kiểm tra và phê duyệt', 1, 2, 'user-employee-001'),

('contract-002', 'Hợp đồng dịch vụ bảo trì hệ thống', 'Hợp đồng bảo trì và hỗ trợ kỹ thuật hệ thống ERP', 'approved', 'commercial', '2024-01-20 10:15:00', '2024-01-25 16:45:00', '2025-01-20 23:59:59', 'Trần Thị Minh', 'Phê duyệt với điều kiện bổ sung SLA', 2, 3, 'user-employee-001'),

-- Hợp đồng chờ duyệt
('contract-003', 'Hợp đồng thuê văn phòng chi nhánh', 'Hợp đồng thuê mặt bằng văn phòng tại TP.HCM', 'pending', 'commercial', '2024-02-01 08:30:00', NULL, '2026-02-01 23:59:59', NULL, NULL, 1, 1, 'user-employee-003'),

('contract-004', 'Hợp đồng lao động nhân viên mới', 'Hợp đồng lao động cho 5 nhân viên IT mới tuyển', 'pending', 'internal', '2024-02-05 14:20:00', NULL, '2027-02-05 23:59:59', NULL, NULL, 1, 0, 'user-employee-002'),

-- Hợp đồng bị từ chối
('contract-005', 'Hợp đồng mua xe công ty', 'Hợp đồng mua 3 xe ô tô phục vụ công tác', 'rejected', 'commercial', '2024-01-25 11:00:00', '2024-01-28 09:15:00', NULL, 'Lê Văn Thành', 'Chưa đủ căn cứ pháp lý, cần bổ sung hồ sơ', 1, 1, 'user-employee-003'),

-- Hợp đồng đã ký
('contract-006', 'Hợp đồng tư vấn chiến lược', 'Hợp đồng tư vấn phát triển chiến lược kinh doanh 2024-2025', 'signed', 'commercial', '2024-01-10 16:00:00', '2024-01-12 10:30:00', '2024-06-30 23:59:59', 'Trần Thị Minh', 'Đã ký và có hiệu lực', 1, 3, 'user-employee-003'),

-- Hợp đồng nháp
('contract-007', 'Hợp đồng bảo hiểm nhân viên', 'Hợp đồng bảo hiểm sức khỏe cho toàn thể nhân viên', 'draft', 'internal', '2024-02-10 13:45:00', NULL, NULL, NULL, NULL, 1, 0, 'user-employee-002'),

('contract-008', 'Hợp đồng dịch vụ marketing', 'Hợp đồng thuê dịch vụ marketing online và truyền thông', 'approved', 'commercial', '2024-01-30 09:30:00', '2024-02-02 15:20:00', '2024-07-30 23:59:59', 'Vũ Thị Hoa', 'Phê duyệt với ngân sách đã điều chỉnh', 1, 2, 'user-employee-003');

-- =====================================================
-- THÔNG TIN TRÍCH XUẤT HỢP ĐỒNG
-- =====================================================

INSERT INTO contract_extracted_info (contract_id, contract_type, parties, value, numeric_value, duration, summary, full_text, detailed_summary) VALUES
('contract-001', 'Hợp đồng mua bán', 
 JSON_ARRAY('Công ty ABC', 'Công ty XYZ Technology'), 
 '500.000.000 VND', 500000000.00, '12 tháng',
 'Hợp đồng mua sắm thiết bị IT bao gồm máy tính, server và thiết bị mạng với tổng giá trị 500 triệu đồng',
 'HỢP ĐỒNG MUA BÁN THIẾT BỊ IT\n\nBên A: Công ty ABC\nBên B: Công ty XYZ Technology\n\nGiá trị: 500.000.000 VND\nThời hạn: 12 tháng\n\nNội dung: Cung cấp và lắp đặt hệ thống IT...',
 JSON_OBJECT(
   'generalInfo', JSON_OBJECT(
     'contractName', 'Hợp đồng mua bán thiết bị IT',
     'contractNumber', 'TM/2024/0001',
     'effectiveDate', '2024-01-15',
     'expiryDate', '2024-12-31',
     'parties', JSON_ARRAY(
       JSON_OBJECT('name', 'Công ty ABC', 'role', 'A', 'address', '123 Đường ABC, Hà Nội', 'representative', 'Nguyễn Văn A'),
       JSON_OBJECT('name', 'Công ty XYZ Technology', 'role', 'B', 'address', '456 Đường XYZ, TP.HCM', 'representative', 'Trần Thị B')
     )
   ),
   'financialInfo', JSON_OBJECT(
     'totalValue', '500.000.000 VND',
     'paymentMethod', 'Chuyển khoản',
     'paymentSchedule', 'Thanh toán 50% khi ký hợp đồng, 50% khi nghiệm thu',
     'currency', 'VND',
     'paymentTerms', '30 ngày'
   )
 )),

('contract-002', 'Hợp đồng dịch vụ',
 JSON_ARRAY('Công ty ABC', 'Công ty DEF Services'),
 '1.200.000.000 VND', 1200000000.00, '24 tháng',
 'Hợp đồng dịch vụ bảo trì và hỗ trợ kỹ thuật hệ thống ERP trong 24 tháng',
 'HỢP ĐỒNG DỊCH VỤ BẢO TRÌ\n\nBên A: Công ty ABC\nBên B: Công ty DEF Services\n\nGiá trị: 1.200.000.000 VND\nThời hạn: 24 tháng...',
 JSON_OBJECT(
   'generalInfo', JSON_OBJECT(
     'contractName', 'Hợp đồng dịch vụ bảo trì hệ thống',
     'contractNumber', 'TM/2024/0002',
     'effectiveDate', '2024-01-20',
     'expiryDate', '2025-01-20'
   ),
   'financialInfo', JSON_OBJECT(
     'totalValue', '1.200.000.000 VND',
     'paymentMethod', 'Chuyển khoản hàng tháng',
     'paymentSchedule', 'Thanh toán 50.000.000 VND/tháng',
     'currency', 'VND'
   )
 )),

('contract-003', 'Hợp đồng thuê',
 JSON_ARRAY('Công ty ABC', 'Công ty GHI Real Estate'),
 '2.400.000.000 VND', 2400000000.00, '24 tháng',
 'Hợp đồng thuê văn phòng 500m2 tại TP.HCM với giá thuê 100 triệu/tháng',
 'HỢP ĐỒNG THUÊ VĂN PHÒNG\n\nBên A: Công ty ABC\nBên B: Công ty GHI Real Estate\n\nDiện tích: 500m2\nGiá thuê: 100.000.000 VND/tháng...',
 JSON_OBJECT(
   'generalInfo', JSON_OBJECT(
     'contractName', 'Hợp đồng thuê văn phòng chi nhánh',
     'effectiveDate', '2024-02-01',
     'expiryDate', '2026-02-01'
   ),
   'financialInfo', JSON_OBJECT(
     'totalValue', '2.400.000.000 VND',
     'paymentMethod', 'Chuyển khoản hàng tháng',
     'paymentSchedule', '100.000.000 VND/tháng, thanh toán trước ngày 5 hàng tháng'
   )
 ));

-- =====================================================
-- PHIÊN BẢN HỢP ĐỒNG
-- =====================================================

INSERT INTO contract_versions (contract_id, version, title, content, changes, created_by) VALUES
('contract-001', 1, 'Hợp đồng mua sắm thiết bị IT 2024 - v1.0', 'Nội dung hợp đồng phiên bản 1...', 'Phiên bản đầu tiên', 'user-employee-001'),
('contract-002', 1, 'Hợp đồng dịch vụ bảo trì hệ thống - v1.0', 'Nội dung hợp đồng phiên bản 1...', 'Phiên bản đầu tiên', 'user-employee-001'),
('contract-002', 2, 'Hợp đồng dịch vụ bảo trì hệ thống - v2.0', 'Nội dung hợp đồng phiên bản 2...', 'Bổ sung điều khoản SLA', 'user-manager-002'),
('contract-003', 1, 'Hợp đồng thuê văn phòng chi nhánh - v1.0', 'Nội dung hợp đồng phiên bản 1...', 'Phiên bản đầu tiên', 'user-employee-003'),
('contract-004', 1, 'Hợp đồng lao động nhân viên mới - v1.0', 'Nội dung hợp đồng phiên bản 1...', 'Phiên bản đầu tiên', 'user-employee-002'),
('contract-005', 1, 'Hợp đồng mua xe công ty - v1.0', 'Nội dung hợp đồng phiên bản 1...', 'Phiên bản đầu tiên', 'user-employee-003'),
('contract-006', 1, 'Hợp đồng tư vấn chiến lược - v1.0', 'Nội dung hợp đồng phiên bản 1...', 'Phiên bản đầu tiên', 'user-employee-003'),
('contract-007', 1, 'Hợp đồng bảo hiểm nhân viên - v1.0', 'Nội dung hợp đồng phiên bản 1...', 'Phiên bản đầu tiên', 'user-employee-002'),
('contract-008', 1, 'Hợp đồng dịch vụ marketing - v1.0', 'Nội dung hợp đồng phiên bản 1...', 'Phiên bản đầu tiên', 'user-employee-003');

-- =====================================================
-- CÁC BƯỚC PHÊ DUYỆT
-- =====================================================

INSERT INTO approval_steps (contract_id, step_number, approver_role, approver_level, required_value, approver_name, approver_id, status, comments, approved_at) VALUES
-- Contract 001 - Đã hoàn thành
('contract-001', 1, 'manager', 2, 500000000, 'Hoàng Văn Đức', 'user-manager-002', 'approved', 'Phê duyệt về mặt kỹ thuật', '2024-01-16 10:30:00'),
('contract-001', 2, 'director', 3, 500000000, 'Trần Thị Minh', 'user-director-001', 'approved', 'Phê duyệt cuối cùng', '2024-01-18 14:30:00'),

-- Contract 002 - Đã hoàn thành
('contract-002', 1, 'manager', 2, 1200000000, 'Hoàng Văn Đức', 'user-manager-002', 'approved', 'OK về kỹ thuật', '2024-01-22 09:15:00'),
('contract-002', 2, 'legal', 2, 1200000000, 'Đỗ Văn Luật', 'user-legal-001', 'approved', 'Đã kiểm tra pháp lý', '2024-01-24 11:20:00'),
('contract-002', 3, 'director', 3, 1200000000, 'Trần Thị Minh', 'user-director-001', 'approved', 'Phê duyệt với yêu cầu bổ sung SLA', '2024-01-25 16:45:00'),

-- Contract 003 - Đang chờ duyệt
('contract-003', 1, 'manager', 2, 2400000000, 'Vũ Thị Hoa', 'user-manager-003', 'pending', NULL, NULL),
('contract-003', 2, 'finance', 2, 2400000000, 'Bùi Thị Mai', 'user-finance-001', 'pending', NULL, NULL),
('contract-003', 3, 'director', 3, 2400000000, 'Lê Văn Thành', 'user-director-002', 'pending', NULL, NULL),

-- Contract 004 - Chờ duyệt bước đầu
('contract-004', 1, 'manager', 2, 0, 'Phạm Thị Lan', 'user-manager-001', 'pending', NULL, NULL),

-- Contract 005 - Bị từ chối
('contract-005', 1, 'director', 3, 800000000, 'Lê Văn Thành', 'user-director-002', 'rejected', 'Chưa đủ căn cứ pháp lý, cần bổ sung hồ sơ đấu thầu', '2024-01-28 09:15:00'),

-- Contract 006 - Đã hoàn thành
('contract-006', 1, 'manager', 2, 300000000, 'Vũ Thị Hoa', 'user-manager-003', 'approved', 'Phê duyệt', '2024-01-11 14:20:00'),
('contract-006', 2, 'legal', 2, 300000000, 'Đỗ Văn Luật', 'user-legal-001', 'approved', 'Đã kiểm tra pháp lý', '2024-01-12 09:45:00'),
('contract-006', 3, 'director', 3, 300000000, 'Trần Thị Minh', 'user-director-001', 'approved', 'Phê duyệt cuối cùng', '2024-01-12 10:30:00'),

-- Contract 008 - Đã hoàn thành
('contract-008', 1, 'manager', 2, 180000000, 'Vũ Thị Hoa', 'user-manager-003', 'approved', 'Phê duyệt với điều chỉnh ngân sách', '2024-02-01 11:30:00'),
('contract-008', 2, 'finance', 2, 180000000, 'Bùi Thị Mai', 'user-finance-001', 'approved', 'Đã kiểm tra ngân sách', '2024-02-02 15:20:00');

-- =====================================================
-- LIÊN KẾT TAGS VỚI HỢP ĐỒNG
-- =====================================================

INSERT INTO contract_tag_relations (contract_id, tag_id) VALUES
('contract-001', 'tag-006'), -- IT
('contract-001', 'tag-002'), -- Mua bán
('contract-002', 'tag-006'), -- IT
('contract-002', 'tag-003'), -- Dịch vụ
('contract-003', 'tag-004'), -- Thuê
('contract-004', 'tag-001'), -- Lao động
('contract-005', 'tag-002'), -- Mua bán
('contract-006', 'tag-007'), -- Tư vấn
('contract-006', 'tag-003'), -- Dịch vụ
('contract-007', 'tag-010'), -- Bảo hiểm
('contract-008', 'tag-003'), -- Dịch vụ
('contract-008', 'tag-007'); -- Tư vấn

-- =====================================================
-- NHẮC NHỞ HỢP ĐỒNG
-- =====================================================

INSERT INTO contract_reminders (contract_id, type, reminder_date, message, is_active) VALUES
('contract-001', 'expiry', '2024-11-30 09:00:00', 'Hợp đồng thiết bị IT sẽ hết hạn vào cuối năm 2024', TRUE),
('contract-002', 'renewal', '2024-11-20 09:00:00', 'Cần chuẩn bị gia hạn hợp đồng bảo trì hệ thống', TRUE),
('contract-006', 'expiry', '2024-05-30 09:00:00', 'Hợp đồng tư vấn sẽ hết hạn vào cuối tháng 6', TRUE),
('contract-008', 'review', '2024-06-30 09:00:00', 'Đánh giá hiệu quả dịch vụ marketing sau 6 tháng', TRUE);

-- =====================================================
-- CHỮ KÝ ĐIỆN TỬ
-- =====================================================

INSERT INTO e_signature_requests (id, contract_id, provider, status) VALUES
('esign-001', 'contract-006', 'docusign', 'completed'),
('esign-002', 'contract-001', 'adobe', 'completed');

INSERT INTO e_signature_signers (signature_request_id, email, name, role, sign_order, signed, signed_at) VALUES
-- Contract 006 signers
('esign-001', 'director@company.com', 'Trần Thị Minh', 'Giám đốc điều hành', 1, TRUE, '2024-01-13 10:15:00'),
('esign-001', 'consultant@external.com', 'Nguyễn Văn Tư Vấn', 'Giám đốc tư vấn', 2, TRUE, '2024-01-13 14:30:00'),

-- Contract 001 signers
('esign-002', 'manager.it@company.com', 'Hoàng Văn Đức', 'Trưởng phòng IT', 1, TRUE, '2024-01-19 09:45:00'),
('esign-002', 'supplier@xyz.com', 'Trần Thị B', 'Giám đốc kinh doanh', 2, TRUE, '2024-01-19 15:20:00');

-- =====================================================
-- BÌNH LUẬN HỢP ĐỒNG
-- =====================================================

INSERT INTO contract_comments (contract_id, user_id, content, highlighted_text, is_resolved) VALUES
('contract-002', 'user-legal-001', 'Cần bổ sung điều khoản về SLA và penalty khi vi phạm', 'Điều khoản về chất lượng dịch vụ', TRUE),
('contract-002', 'user-manager-002', 'Đã thêm SLA 99.5% uptime và penalty 5% giá trị hợp đồng', NULL, TRUE),
('contract-003', 'user-manager-003', 'Giá thuê có thể thương lượng giảm 10% cho năm đầu tiên', 'Giá thuê: 100.000.000 VND/tháng', FALSE),
('contract-004', 'user-manager-001', 'Cần kiểm tra lại mức lương và phụ cấp theo quy định mới', 'Bảng lương và phụ cấp', FALSE),
('contract-008', 'user-finance-001', 'Ngân sách marketing đã được điều chỉnh từ 200M xuống 180M', 'Tổng giá trị: 200.000.000 VND', TRUE);

-- =====================================================
-- LỊCH SỬ HOẠT ĐỘNG
-- =====================================================

INSERT INTO activity_logs (user_id, contract_id, action, description, ip_address) VALUES
('user-employee-001', 'contract-001', 'contract_created', 'Tạo hợp đồng mua sắm thiết bị IT', '192.168.1.100'),
('user-employee-001', 'contract-001', 'contract_submitted', 'Gửi hợp đồng để phê duyệt', '192.168.1.100'),
('user-manager-002', 'contract-001', 'contract_approved', 'Phê duyệt hợp đồng ở bước 1', '192.168.1.101'),
('user-director-001', 'contract-001', 'contract_approved', 'Phê duyệt cuối cùng hợp đồng', '192.168.1.102'),
('user-employee-001', 'contract-002', 'contract_created', 'Tạo hợp đồng dịch vụ bảo trì', '192.168.1.100'),
('user-manager-002', 'contract-002', 'contract_updated', 'Cập nhật hợp đồng - thêm SLA', '192.168.1.101'),
('user-employee-003', 'contract-003', 'contract_created', 'Tạo hợp đồng thuê văn phòng', '192.168.1.103'),
('user-employee-002', 'contract-004', 'contract_created', 'Tạo hợp đồng lao động', '192.168.1.104'),
('user-director-002', 'contract-005', 'contract_rejected', 'Từ chối hợp đồng mua xe - thiếu hồ sơ', '192.168.1.105'),
('user-employee-003', 'contract-006', 'contract_created', 'Tạo hợp đồng tư vấn chiến lược', '192.168.1.103'),
('user-director-001', 'contract-006', 'contract_signed', 'Hoàn thành ký hợp đồng tư vấn', '192.168.1.102');

-- =====================================================
-- THỐNG KÊ DASHBOARD
-- =====================================================

INSERT INTO dashboard_stats (date, total_contracts, pending_approval, approved, rejected, expiring_soon, approval_rate) VALUES
('2024-01-15', 1, 0, 1, 0, 0, 100.00),
('2024-01-20', 2, 1, 1, 0, 0, 50.00),
('2024-01-25', 3, 1, 1, 1, 0, 33.33),
('2024-01-30', 4, 1, 2, 1, 0, 50.00),
('2024-02-01', 5, 2, 2, 1, 0, 40.00),
('2024-02-05', 6, 3, 2, 1, 0, 33.33),
('2024-02-10', 7, 3, 3, 1, 1, 42.86);

-- =====================================================
-- LÝ DO TỪ CHỐI
-- =====================================================

INSERT INTO rejection_reasons (reason, count, last_used) VALUES
('Chưa đủ căn cứ pháp lý', 1, '2024-01-28 09:15:00'),
('Thiếu hồ sơ đấu thầu', 1, '2024-01-28 09:15:00'),
('Vượt quá ngân sách được phê duyệt', 0, NULL),
('Không phù hợp với chính sách công ty', 0, NULL),
('Thiếu chữ ký người có thẩm quyền', 0, NULL);

INSERT INTO contract_rejection_relations (contract_id, rejection_reason_id) VALUES
('contract-005', (SELECT id FROM rejection_reasons WHERE reason = 'Chưa đủ căn cứ pháp lý')),
('contract-005', (SELECT id FROM rejection_reasons WHERE reason = 'Thiếu hồ sơ đấu thầu'));

-- =====================================================
-- CẤU HÌNH HỆ THỐNG
-- =====================================================

INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('max_file_size', '10485760', 'Kích thước file tối đa (10MB)'),
('allowed_file_types', 'pdf,jpg,jpeg,png,doc,docx', 'Các loại file được phép tải lên'),
('default_approval_steps', '2', 'Số bước phê duyệt mặc định'),
('contract_expiry_warning_days', '30', 'Cảnh báo hợp đồng hết hạn trước X ngày'),
('auto_backup_enabled', 'true', 'Tự động sao lưu dữ liệu hàng ngày'),
('email_notifications_enabled', 'true', 'Gửi thông báo email'),
('company_name', 'Công ty ABC', 'Tên công ty'),
('company_address', '123 Đường ABC, Quận 1, TP.HCM', 'Địa chỉ công ty'),
('company_phone', '028-1234-5678', 'Số điện thoại công ty'),
('company_email', 'info@company.com', 'Email công ty'),
('contract_number_format', '{type}/{year}/{sequence}', 'Định dạng số hợp đồng'),
('approval_timeout_days', '7', 'Thời gian timeout cho phê duyệt (ngày)'),
('signature_provider_default', 'docusign', 'Nhà cung cấp chữ ký mặc định'),
('dashboard_refresh_interval', '300', 'Thời gian refresh dashboard (giây)');

-- =====================================================
-- HOÀN THÀNH
-- =====================================================

-- Cập nhật thống kê cuối cùng
CALL UpdateDashboardStats(CURDATE());

SELECT 'Sample data inserted successfully!' as message;
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_contracts FROM contracts;
SELECT COUNT(*) as total_tags FROM contract_tags;
SELECT COUNT(*) as total_comments FROM contract_comments;