#ifndef __LCD1602_H__
#define __LCD1602_H__

#include <REGX52.H>

#define dt P2
#define RS P0_7
#define RW P0_6
#define EN P0_5
#define b1 P3_3 // nut bam 1, nut reset, key 2
#define b2 P3_2 // nut bam 2, nut bat dau/tam dung, key 1

void delay (long int time); //ham tao thoi gian tre voi khoang tre la time (us)
void LCDSendCommand (int cmd); //dung de gui lenh den LCD
void LCDWriteChar (char char_data[],long int time);  //ham dung de gui du lieu char den LCD
void LCDWriteInt ( int int_data ,long int time);  //gui du lieu int den LCD
void LCDInit(void); //khoi tao LCD de hien thi

#endif