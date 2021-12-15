#include "LCD1602.h"

void delay (long int time)
   { 
   long int i;
      for (i=1;i<=time;i++)
	  {;}
   }

void LCDSendCommand (int cmd)
   { 	
     RS=0; //du lieu gui den la lenh
	 RW=0;
	 EN=1;
	 dt=cmd;
	 EN=0;
	 delay(1);	
	}
	 
void LCDWriteChar (char char_data[],long int time)
   {
    int i=0;
	while(char_data [i]!=0) //kiem tra xem char co rong khong
	   {
	   RS=1;
	   RW=0;
	   EN=1;
	   dt=char_data[i]; //gui den data port
	   EN=0;
	   i++; //gui thanh cong thi tang i them 1
	   delay(time); //tao tre voi khoang thoi gian time
	   }
	}
	 
void LCDWriteInt ( int int_data ,long int time)
   { 
     RS=1; //data
	   RW=0;
	   EN=1;
	   dt=int_data;
	   EN=0;
	   delay(time);
	}

void LCDInit(void)
     { 
	  int InitCommand[]={12,56,6},t; //cac lenh 0x38, 0x0C, 0x06
	  for (t=0;t<2;t++) LCDSendCommand(InitCommand[t]); //gui cac lenh tren den LCD
	  }