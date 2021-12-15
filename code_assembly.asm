#include <REGX52.H>
;thu vien cho AT89S52 , duoc them de dung timer 2

DT EQU P2 ;Du lieu LCD o cong P2
RS EQU P0.7 ;P0.7 noi toi chan RS
RW EQU P0.6 ;P0.6 noi toi chan R/W
EN EQU P0.5 ;P2.2 noi toi chan EN

b1 EQU P3.3 ;nut reset, key 2 o tren kit
b2 EQU P3.2 ;nut bat dau/tam dung, key 1 o tren kit
	
;Cac bien dung de luu gia tri thoi gian
ten_ms EQU R0 ;chua gia tri 10 ms da dem duoc
one_sec EQU R1 ;gia tri giay da dem duoc
one_min EQU R2 ;gia tri phut da dem duoc
one_hour EQU R3 ;gia tri gio da dem duoc

i equ 20h ; kiem tra nut bat dau da duoc an hay chua, i = 0 nghia la chua an nut bat dau hoac sau khi an reset
		  ; i = 1 co nghia la da an nut bat dau 1 lan, lan ke tiep bam se la tam dung
e equ 21h ; dung de kiem tra trang thai cua dong ho, e = 1 nghia la dong ho dang dem
x EQU 22h ; x = 1 co nghia la ISR cho timer 2 da duoc thuc hien, da dem duoc 10ms
a0 equ 50h ;cac bien phu dung cho chuong trinh con hien thi LCD
b0 equ 51h
d0 equ 52h


SS MACRO L1  ;macro dung de hien thi chuoi ky tu len LCD
MOV R5,#0  
MOV DPTR,L1  ;thanh ghi DPTR (cu the la DPL) se chua dia chi cua byte dau tien duoc dinh nghia trong L1
LCALL lcd_puts 
ENDM 

CHIA_10 MACRO L2  ;macro dung de chia 
MOV A,L2
MOV B,#10
DIV AB ;thuong o A, so du o B
ENDM 

CONG_48 MACRO L4 ;//macro cong them 48 de thanh ma ascii bieu thi so va gui den LCD
CLR CY
MOV A,L4
ADD A,#48
ACALL XUAT_DU_LIEU
ENDM

ORG 0000H
LJMP MAIN
ORG 002BH
LJMP TIMER2_ISR

;--Chuong trinh chinh--
MAIN:
	CLR i
	SETB e
	ACALL KHOI_TAO_LCD   ;khoi tao man hinh LCD
	SETB TF2 ;TF2 = 1 , co tran duoc bat
	SETB ET2 ;cho phep ngat timer 2 , ngay sau do se nhay vao ngat luon do TF2 = 1
	CLR TR2 ;tat timer 2
	SETB EA  ;EA trong thanh ghi IE, cho phep ngat
	MOV one_hour,#0
	MOV one_min,#0
	MOV one_sec,#0
	MOV ten_ms,#0
	MOV TH2,#0DCH
	MOV TL2,#00H ;timer se dem 10ms
	MAIN_LOOP: ;vong lap chinh cua chuong trinh
		JNB e,LOOP2 ;ban dau e = 1 nghia la dong ho dang dem, e = 0 co nghia la dong ho ngung dem
		LOOP1: ;ban dau thi x=1, vong lap nay chay, x co y nghia la kiem tra xem ISR da duoc thuc hien hay chua
			JNB x,LOOP2
			LCALL DISPLAY ;hien thi thoi gian len LCD, ban dau la 00:00:00
			CLR x ;chay xong thi x=0 de kiem tra 10ms tiep theo
			SJMP LOOP1
		LOOP2: 
			JB b1,LOOP3 ;kiem tra nut reset duoc nhan chua, chua thi nhay den LOOP3
			MOV one_hour,#0 ;reset cac gia tri thoi gian da luu
			MOV one_min,#0
			MOV one_sec,#0
			MOV ten_ms,#0
			CLR TR2 ;tat timer 2
			CLR i ; reset i
			MOV A, #0C0H        ; chuyen con tro xuong dau dong thu 2 cua LCD 
 			ACALL XUAT_LENH
 			SS #STRING1  ;hien thi RESET BO DEM
 			LCALL DISPLAY
 			SMALL_LOOP: JB b1,LOOP3 ;neu nut van duoc bam thi doi o day khong thi thoat ra va tiep tuc lap
				                    ;tranh hien tuong giu phim
 			SJMP SMALL_LOOP 	
 		LOOP3: ;kiem tra nut bat dau/tam dung duoc nhan chua, chua thi tiep tuc lap lai vong lap chinh
 			JB b2,NEXT3 
 			JB i,ELSE1 ;nut bat dau/tam dung duoc bam, kiem tra i, neu da bam 1 lan roi thi nhay den ELSE1
 			SETB TR2 ;bat timer 2
 			SETB e
 			SETB i ; i len 1, da bam nut bat dau duoc 1 lan
 			MOV A, #0C0H   ; chuyen con tro xuong dau dong thu 2 cua LCD
 			ACALL XUAT_LENH
 			SS #STRING2 ; hien thi BAT DAU DEM
 			SJMP NEXT 
 			ELSE1: ;tam dung
 				CLR TR2 ;dung timer 2
 				CLR e
 				CLR i ;reset i
 				MOV A, #0C0H     ; chuyen con tro xuong dau dong thu 2 cua LCD 
 				ACALL XUAT_LENH 
 				SS #STRING3 ; hien thi TAM DUNG
 			NEXT:
 				JB b2,NEXT3 ;tranh hien tuong giu phim
 				SJMP NEXT
		NEXT3: LJMP MAIN_LOOP ; tiep tuc thuc hien VONG LAP CHINH

;---Chuong trinh ngat cho timer 2----
TIMER2_ISR:
	SETB x
	CLR TF2 ;reset co tran TF2
	;10ms = 10000 us, voi T = 1.085 us
	;so nhip dong ho la n = 10000/1.085 = 9216
	;=> gia tri nap cho Timer la: 65536 - 9216 = 56320 = DC00H (FFFFH - (n+1))
	MOV TH2,#0DCH
	MOV TL2,#00H
	INC ten_ms ;moi lan timer chay xong ten_ms se tang them 1, tuc la tuc la da dem duoc 10 ms
	CJNE ten_ms,#100,SKIP ;ten_ms khac 100, ket thuc
	;ten_ms = 100
	MOV ten_ms,#0
	INC one_sec
	CJNE one_sec,#60,SKIP
	MOV one_sec,#0
	INC one_min
	CJNE one_min,#60,SKIP
	MOV one_min,#0
	INC one_hour
	CJNE one_hour,#24,SKIP
	MOV one_hour,#0
	SKIP: RETI

;--Chuong trinh con de khoi tao LCD
KHOI_TAO_LCD: 
MOV A,#0CH ; Bat man hinh hien thi, tat hien thi con tro
ACALL XUAT_LENH
MOV A,#38H ; Che do LCD 2 dong, ma tran 5x7
ACALL XUAT_LENH
MOV A,#06H ; Dich con tro sang phai
ACALL XUAT_LENH
ACALL XOA_LCD
RET

;--Chuong trinh con dung de xoa LCD
XOA_LCD:
MOV A,#01H ; Xoa man hinh va tra lai con tro
ACALL XUAT_LENH
RET

;--Chuong trinh con dung de xuat lenh toi LCD
XUAT_LENH: 
ACALL KIEM_TRA ; Kiem tra xem LCD co ban khong, neu khong ban thi tiep tuc
CLR RW ; R/W = 0 , che do doc
CLR RS ; RS = 0 , thanh ghi ma lenh duoc chon, du lieu chuyen den se la lenh
MOV DT,A ; gui lenh den cong du lieu
SETB EN ;Gui toi E 1 xung cao-xuong-thap
CLR EN
RET

;--Chuong trinh con dung de xuat du lieu toi LCD
XUAT_DU_LIEU:
ACALL KIEM_TRA ; Kiem tra xem LCD co ban khong, neu khong ban thi tiep tuc
CLR RW ; R/W = 0 , che do doc
SETB RS ; RS = 1, du lieu chuyen den se duoc hien thi tren LCD
MOV DT,A ; gui du lieu de hien thi
SETB EN ; Gui toi E 1 xung H-L
CLR EN
RET

KIEM_TRA: 
SETB P2.7 ;Lay P2.7 lam cong vao
CLR RS ;RS = 0, truy cap thanh ghi lenh
SETB RW ;R/W = 1, cho phep doc thanh ghi lenh
BACK: CLR EN ;Gui toi E 1 xung cao-xuong-thap
SETB EN 
JB P2.7,BACK ;Doi cho toi khi co ban = 0
RET

;--chuong trinh con de xuat chuoi ky tu toi LCD
lcd_puts: 
 MOV A,R5 ;R5 = 0
 MOVC A,@A+DPTR   ;A se chua ky tu dau tien (gia tri o dia chi chua trong DPTR)
 LCALL XUAT_DU_LIEU  ;hien thi tung chu cai trong chuoi ky tu
 INC R5 ; R5 = R5 + 1 ; su dung R5 de khong anh huong den A
 CJNE R5,#15,lcd_puts  ;thuc hien cho den khi nao het 16 bit ky tu
 RET 

;--chuong trinh con dung de hien thi thoi gian tren LCD
DISPLAY:
MOV A, #02H    ;tra con tro ve vi tri ban dau (address 0)
ACALL XUAT_LENH    
MOV A, #" " 
ACALL XUAT_DU_LIEU

;tinh va hien thi phan gio
CHIA_10 one_hour
MOV a0,B ; a0 = one_hour % 10 , a0 la phan don vi cua gio
MOV A,one_hour
SUBB A,a0
MOV d0,A ; d0 = one_hour - a0
CHIA_10 d0
MOV b0,A ; b0 = d0/10 , b0 la phan hang chuc cua gio
CONG_48 b0 ;cong them 48 de thanh ma ASCII va hien thi
CONG_48 a0

;tinh va hien thi phan PHUT
CHIA_10 one_min
MOV a0,B
MOV A,one_min
SUBB A,a0
MOV d0,A
CHIA_10 d0
MOV b0,A
MOV A, #":" 
ACALL XUAT_DU_LIEU    
CONG_48 b0
CONG_48 a0

;tinh va hien thi phan GIAY
CHIA_10 one_sec
MOV a0,B
MOV A,one_sec
SUBB A,a0
MOV d0,A
CHIA_10 d0
MOV b0,A
MOV A, #":" 
ACALL XUAT_DU_LIEU  
CONG_48 b0
CONG_48 a0

;tinh va hien thi phan 10ms (tic tac)
CHIA_10 ten_ms
MOV a0,B
MOV A,ten_ms
SUBB A,a0
MOV d0,A
CHIA_10 d0
MOV b0,A
MOV A, #":" 
ACALL XUAT_DU_LIEU  
CONG_48 b0
CONG_48 a0
RET

STRING1: DB 'RESET BO DEM    ' 
STRING2: DB 'BAT DAU DEM     '
STRING3: DB 'TAM DUNG        ' 
 
END