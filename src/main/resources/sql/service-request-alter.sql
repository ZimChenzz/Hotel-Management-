-- Service Request table: Add new columns for expanded service request flow
-- Run before deploying the new service request feature

ALTER TABLE ServiceRequest ADD
    description     NVARCHAR(500) NULL,
    priority        VARCHAR(10) DEFAULT 'Normal',
    notes           NVARCHAR(500) NULL,
    completed_time  DATETIME NULL,
    room_number     VARCHAR(10) NULL;
