﻿CREATE DATABASE QLNH_TH
GO
USE QLNH_TH
CREATE TABLE NHANVIEN
(
	TENNGUOIDUNG VARCHAR(30) PRIMARY KEY,
	MATKHAU VARCHAR(30),
	HOTEN NVARCHAR(30),
	NGAYSINH DATE CHECK (NGAYSINH < GETDATE()),
	GIOITINH NVARCHAR(20),
	DIACHI NVARCHAR(40),
	SDT FLOAT,
	VITRI NVARCHAR(50) DEFAULT N'Nhân viên'
	
)

INSERT NHANVIEN
VALUES('duonghuy','2000', N'Dương Quang Huy', '2000-11-12', 'Nam', N'Phú Yên', '0372191172',N'Quản lý')
INSERT NHANVIEN
VALUES('anhthien','2000', N'Phạm Anh Thiên', '2000-00-00', 'Nam', N'Phú Yên', '000000000',N'Nhân viên')
INSERT NHANVIEN
VALUES('phamlong','2000', N'Phạm Hải Long', '2000-00-00', 'Nam', N'Nha Trang', '0000000000',N'Nhân viên')
GO
CREATE TABLE BAN
(
	MABAN INT IDENTITY(1, 1) PRIMARY KEY,
	TENBAN NVARCHAR(30) UNIQUE,
	TRANGTHAI NVARCHAR(20) DEFAULT N'Trống'
)
GO
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 1')
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 2')
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 3')
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 4')
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 5')
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 6')
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 7')
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 8')
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 9')
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 10')
INSERT INTO BAN(TENBAN)
VALUES(N'Bàn 11')
INSERT BAN(TENBAN)
VALUES(N'Bàn 12')
INSERT BAN(TENBAN)
VALUES(N'Bàn 13')

GO

CREATE TABLE THUCDON
(
	MAMON INT IDENTITY(1, 1) PRIMARY KEY,
	TENLOAI NVARCHAR(30) NOT NULL,
	TENMON NVARCHAR(50) UNIQUE NOT NULL,
	GIA FLOAT NOT NULL
)
GO
INSERT THUCDON
VALUES('BUN DAU',  N'BÚN ĐẬU ĐẶC BIỆT', 55000), ('BUN DAU', N'BÚN ĐẬU 2 NGƯỜI', 100000),('BUN DAU', N'BÚN ĐẬU 3 NGƯỜI', 150000),('BUN DAU', N'BÚN ĐẬU 4 NGƯỜI', 200000),('BUN DAU', N'BÚN ĐẬU 6 NGƯỜI', 300000)
GO
INSERT THUCDON
VALUES('MON THEM', N'CHẢ THÊM', 30000 ),('MON THEM', N'ĐẬU THÊM', 20000 ),('MON THEM', N'BÚN THÊM', 10000 ),('MON THEM', N'THỊT THÊM', 30000 ),('MON THEM', N'CHẢ GIÒ', 35000 )
GO

INSERT THUCDON
VALUES
	  ('SOFT DRINK', N'NƯỚC SUỐI',  20000   ), ('SOFT DRINK', N'COCACOLA',  26000   ),('SOFT DRINK', N'BEER HÀ NỘI',  30000   ),('SOFT DRINK', N'BEER SÀI GÒN', 30000),('SOFT DRINK', N'BEER HALIKEN',  40000)

GO


CREATE TABLE HOADON
(
	MAHD INT IDENTITY PRIMARY KEY,
	MABAN INT NOT NULL,
	MAMON INT NOT NULL,
	SOLUONG INT NOT NULL,
	NGAYVAO DATE DEFAULT GETDATE(),
	NGAYRA DATE CHECK(NGAYRA <= GETDATE()),
	TRANGTHAI INT DEFAULT 0 NOT NULL,
	GIAMGIA INT DEFAULT 0,
	--0 chưa thanh toán
	--1 đã thanh toán
	TONGTIEN FLOAT DEFAULT 0,
	TENNGUOIDUNG VARCHAR(30)
)
GO
ALTER TABLE HOADON
ADD CONSTRAINT FK_NV FOREIGN KEY(TENNGUOIDUNG) REFERENCES NHANVIEN(TENNGUOIDUNG)

ALTER TABLE HOADON
ADD CONSTRAINT FK_BAN FOREIGN KEY(MABAN) REFERENCES BAN(MABAN)

ALTER TABLE HOADON
ADD CONSTRAINT FK_MON FOREIGN KEY(MAMON) REFERENCES THUCDON(MAMON)
GO
CREATE PROC INSERT_HD
@maban INT, @mamon INT, @soluong INT, @tennguoidung VARCHAR(30)
AS
BEGIN
	DECLARE @check int, @soluong2 int = 1
	SELECT @check = MAHD, @soluong2 = SOLUONG
	FROM HOADON
	WHERE @maban = MABAN AND @mamon = MAMON AND TRANGTHAI = 0
	IF(@check > 0)
		BEGIN
			DECLARE @soluongmoi int = @soluong + @soluong2
			IF(@soluongmoi>0)
				BEGIN
					UPDATE HOADON
					SET SOLUONG = @soluong + @soluong2
					WHERE MAMON = @mamon AND TRANGTHAI = 0
				END
			ELSE
				BEGIN
					DELETE HOADON
					WHERE MABAN = @maban AND MAMON = @mamon AND TRANGTHAI = 0
				END			
		END
		ELSE
			BEGIN
				INSERT INTO HOADON(MABAN, MAMON, SOLUONG, TENNGUOIDUNG)
				VALUES(@maban, @mamon, @soluong, @tennguoidung)
			END
END

GO

CREATE TRIGGER TG_TT
ON HOADON FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @IDBILL INT
	SELECT @IDBILL = MAHD FROM inserted
	DECLARE @IDBAN INT
	SELECT @IDBAN = MABAN FROM HOADON WHERE MAHD = @IDBILL AND TRANGTHAI = 0
	UPDATE BAN
	SET TRANGTHAI = N'Đang phục vụ'
	WHERE MABAN = @IDBAN
END

GO

CREATE PROC THONKE
@NGAYVAO DATE, @NGAYRA DATE
AS
BEGIN
SELECT TENBAN, SUM(TONGTIEN) AS TONGTIEN, NGAYVAO, NGAYRA
FROM HOADON AS HD, BAN AS B
WHERE HD.MABAN = B.MABAN AND NGAYVAO >= @NGAYVAO AND NGAYRA <= @NGAYRA 
AND HD.TRANGTHAI = 1
GROUP BY TENBAN, NGAYVAO, NGAYRA
END

SELECT *FROM NHANVIEN
