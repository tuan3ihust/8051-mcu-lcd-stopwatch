#include <REGX52.H> //thu vien cho AT89S52 va AT89C52
#include <LCD1602.h> //thu vien cho LCD 16x2

int ten_ms,one_sec,one_min,one_hour,x; //cac bien toan cuc dung de luu tru gia tri thoi gian
//x de kiem tra xem ISR cho timer 2 da duoc thuc hien chua

//timer se dem 10ms
//100 ten_ms = 1 one_sec
void count (void) interrupt 5 //chuong trinh ngat cho timer 2
	{
	x=1;
	TF2=0; //reset co tran TF2
	TH2=0xD8;  //10000 us = 10ms 
	TL2=0xEF;  //FFFFH - D8EFH = 2710H = 10000D
	ten_ms++; //moi lan timer chay xong ten_ms se tang them 1, tuc la da dem duoc 10 ms
	if(ten_ms>99) 
		{
		ten_ms=0; //reset ten_ms ve 0
		one_sec++; //tang them 1s
		if(one_sec>59)
			{
			one_sec=0;
			one_min++; //tang 1 phut
			if(one_min>59)
				{
				one_min=0;
				one_hour++; //tang 1 gio
				if (one_hour>23) {one_hour=0;} //chay den 24h thi reset lai tu dau
				}
			}
		}
	}

int findRemainder (int a,int b) //tim phan du a/b
{
int c;
while (a>=b)
	{
	a=a-b;
	}
	c=a;
return (c); //tra ve phan du
}
	
void display(void) //hien thi noi dung LCD
{
int a,b,d;
LCDSendCommand(2); //tra con tro ve vi tri ban dau (home position) (address 0)
LCDWriteChar(" ",1);

//tinh va hien thi phan gio (tieng)
//1000 ms = 1s
a=findRemainder(one_hour,10); //small digit of the hour , ban dau one_hour = 0 => a = one_hour
d=one_hour-a;//ban dau d = one_hour - one_hour = 0
b=d/10;// b = 0/10 = 0 ,big digit of the hour
LCDWriteInt(b+48,1); //cong them 48 de thanh ma ascii bieu thi so
LCDWriteInt(a+48,1);

	//tinh va hien thi phan phut
a=findRemainder(one_min,10); // phan don vi
d=one_min-a;
b=d/10; // phan hang chuc
LCDWriteChar(":",1);
LCDWriteInt(b+48,1);
LCDWriteInt(a+48,1);

	//tinh va hien thi phan giay
a=findRemainder(one_sec,10); //phan don vi
d=one_sec-a;
b=d/10; //phan hang chuc
LCDWriteChar(":",1);
LCDWriteInt(b+48,1);
LCDWriteInt(a+48,1);

// tinh va hien thi phan 10ms (1 tic tac)
a=findRemainder(ten_ms,10); //phan don vi
d=ten_ms-a;
b=d/10; //phan hang chuc
LCDWriteChar(":",1);
LCDWriteInt(b+48,1);
LCDWriteInt(a+48,1);
}

//chuong trinh chinh
void main (void)
{
	int e,i;
	i=0;
	e=1; //dung de kiem tra trang thai cua dong ho, e = 1 nghia la dong ho dang dem
	LCDInit();
	LCDSendCommand(1); //xoa man hinh LCD
	TF2 = 1; //TF2 = 1 , co tran duoc bat
	ET2 = 1; //cho phep ngat timer 2 , ngay sau do se nhay vao ngat luon do TF2 = 1
	TR2 = 0; //tat timer 2
	EA = 1; // cho phep ngat 
	one_hour=0;
	one_min=0;
	one_sec=0;
	ten_ms=0;
	TH2=0xD8; //0xD8EF = 55,535 , FFFF - D8EF = 10000
	TL2=0xEF;
	
		while(1) //vong lap chinh cua chuong trinh
		{ //dong ho chay binh thuong thi e tiep tuc bang 1
		 if(e==1) //ban dau e = 1, e = 1 co nghia la dong ho dang dem, e = 0 co nghia la dong ho ngung dem
			{
			while(x) //ban dau thi x=1, vong lap nay chay, x co y nghia la kiem tra xem ISR da duoc thuc hien hay chua, tuc la khi da duoc 10ms thi x = 1
				{        
					display(); //ban dau se hien thi la 00:00:00, hien thi
				x=0; //chay xong thi x=0 de kiem tra 10ms tiep theo
				}
			}
			
			while(!b1)// nut b1 (reset duoc nhan)
			{
			one_hour=0;
			one_min=0;
			one_sec=0;
			ten_ms=0;
			TR2=0; //tat timer 2
			i=0; //de phat hien phim nao duoc bam cuoi cung
			LCDSendCommand(192);
			LCDWriteChar("RESET BO DEM",1);
			display();
			while(!b1) {}
			}
			
			while(!b2) //nut 2 (start/stop) duoc bam , b3 = 0
			{
			if(i==0) //ban dau i = 0, bat dau dem
				{
				TR2=1; //khoi dong timer2, luc nay ban dau TF2 = 0
					
				e=1;
				i=1;
					
	      LCDSendCommand(192);//0xC0 dia chi dong dau tien ben trai cua hang duoi LCD
				LCDWriteChar("BAT DAU DEM ",1); //in ra chu BAT DAU DEM va tao thoi gian tre la 1
				}
			else //neu i khac 0 thi dung dem
				{
				TR2=0;
				e=0;
				i=0;
				LCDSendCommand(192);
			    LCDWriteChar("TAM DUNG        ",1);
				}
			 while(!b2) //neu nut start/stop van duoc bam thi doi o day khong thi thoat ra va tiep tuc lap
				{} //tranh hien tuong giu phim start/stop
			}
			
					}
}