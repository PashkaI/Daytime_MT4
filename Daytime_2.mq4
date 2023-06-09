//+------------------------------------------------------------------+
//|                                                          Daytime |
//|                                                           Pashka |
//|                                                              ... |
//+------------------------------------------------------------------+
#property copyright "   = Pashka! =   "
#property link      "..."
#property version   "  v2.00"
#property strict
#property indicator_chart_window
enum PointOrPips
  {
   point,  // Point
   pips    // Pips
  };
//--- input parameters
input PointOrPips ATRPoint          = pips;           //Point or pips
input string Time_Open              ="08:00";         //Response time
input string Amer_Close             ="23:00";         //America's Closing Time
input string Reset_Flag             ="21:00";         //If America closes before 23:00 
input int Ile                       = 5;              //Number of days to check the trend direction
input int delay                     = 55;             //Delay in seconds while waiting for a tick
input int Datr                      = 20;             //Number of days to calculate ATR
extern string button_note1          = "------------------------------";
input int Ile_                      = 20;            //Number of days to check
input int xdis                      = 125;           //Button Distanse X 

bool flag, New_Bar                  = false;
bool trend;                                           //Показатель основного тренда по телу дневной свечки (True = Long / false = short )
bool center;                                          //Тригер для срабатывания, если цена приходит к центру свечки
double Amer, Amer21, Amer23;                          //Котировка закрытие Америки
double   point                      = MarketInfo(Symbol(),MODE_POINT);
double   Open2                      = 0;
double   Midl;                                        //Котировка центра трендовой свечи
string Time_Close                   ="22:50";         //Время для проверки дневной свечи
string name_am;                                       //Имя трендовой на закрытии америки
string name_t;                                        //Имя трендовой для сохранения на истории
datetime data_close=D'21.03.2023';                    //в это число уже работать не будет

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
      // Первоначальное создание кнопки при запуске
   ObjectCreate(0,"Buy",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"Buy",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,"Buy",OBJPROP_XDISTANCE,xdis);
   ObjectSetInteger(0,"Buy",OBJPROP_YDISTANCE,5);
   ObjectSetInteger(0,"Buy",OBJPROP_XSIZE,50);
   ObjectSetInteger(0,"Buy",OBJPROP_YSIZE,20);
   ObjectSetInteger(0,"Buy",OBJPROP_BGCOLOR,clrDarkSlateBlue);
   ObjectSetString(0,"Buy",OBJPROP_TEXT,"Dbar");
   ObjectSetInteger(0,"Buy",OBJPROP_COLOR,clrWhite);

   // if(Account() == false) return(INIT_FAILED);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(ChartID(), "Buy");
   DelObjects();

  Comment("");

   //return 0;
  }  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
     New_Bar=false;
   if(TimeCurrent()<=data_close)// Проверка на срок годности индикатора :))
     {
      New_Bar=true;
     }
     else
     {
      Comment(" === Срок действия индикатора истек! === ");
     }
  
   if(New_Bar)
     {
//---
   TrendReset();                       //Сброс имени линии тренда
   if (flag == false)   FlagReset();   //Сброс флага
   if (flag == true)   AmerClose();    //Рисование уровня закрытия америки
   ATR();                              //Расчёт АТР и вывод сообщения
//---
   if (flag == false) WorkingTime1();  // Обработка события первого времени
//---  
   if(ObjectGetInteger(0,"Buy",OBJPROP_STATE,0)!=false)
        {
         DelObjects();
         ObjectSetInteger(0,"Buy",OBJPROP_STATE,0);
         WorkingTime2();
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
bool Account()
{
   if(AccountNumber() == 770611701)
     {
      return(true);
     } else 
       {
       MessageBox("Не соответствует входным параметрам!","Ошибка",MB_OK|MB_ICONSTOP);
       return(false);
       }
}

//+=== Функция проверки дневных свечей ===================================================================================+

bool WorkingTime1()
  {
   if(Time_Open == "00:00")return(false);// Время не задано (выкл) - разрешаем торговлю
//---
   datetime time_0=TimeCurrent();
   datetime time_1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Time_Open);
   datetime time_2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Time_Open) + delay;
//---
   if( time_1 < time_0 && time_0 < time_2 )
   {
  DelObjects(); // Очистка, удаление элементов старых рассчётов

//--- Определяем направление  ---
Print ("Размер пункта " + DoubleToString(point,2));
Print(_Symbol);
string   name_rec1 = "Rec_1  " + (IntegerToString(Ile_));
string   name_rec2 = "Rec_2  " + (IntegerToString(Ile_));
string   name_rec3 = "Rec_3  " + (IntegerToString(Ile_));
string   name_rec4;
string   name_s1   = "Sh_1  " + (IntegerToString(Ile_));
string   name_s2   = "Sh_2  " + (IntegerToString(Ile_));
string   name_s3   = "Sh_3  " + (IntegerToString(Ile_));
string   go_avg_low;
string   go_avg_high;
datetime Time0;
datetime Time1;
double   Open1;
double   Close1;
double   High1;
double   Low1;
double   Telo;
double   Ten;
double   iatr;
int shift;

int index = 0;
double telko = 0;

      for (int i=1; i<Ile; i++)
           {
            Time1  = iTime(_Symbol, PERIOD_D1, i);
            Open1  = iOpen(_Symbol, PERIOD_D1, i);
            Close1 = iClose(_Symbol, PERIOD_D1, i);
            High1  = iHigh(_Symbol, PERIOD_D1, i);
            Low1   = iLow(_Symbol, PERIOD_D1, i);
            Telo   = 0;
            Ten    = 0;
            
            if (Open1 > Close1) 
               {
                  Telo = Open1 - Close1;
                  Telo = NormalizeDouble(Telo/point,_Digits);
                  Ten = (High1-Open1) + (Close1-Low1);
                  Ten = NormalizeDouble(Ten/point,_Digits);
                      
               }else
                  {
                     Telo = Close1 - Open1;
                     Telo = NormalizeDouble(Telo/point,_Digits);
                     Ten = (High1-Close1) + (Open1-Low1);
                     Ten = NormalizeDouble(Ten/point,_Digits);            
                  }       
            if (Telo > telko) 
               {
               index = i;
               telko = Telo;
               }
            Print(IntegerToString(i,0) +" Итерация   " + IntegerToString(index,0) + " тело " + DoubleToString(Telo,_Digits) + " тень " + DoubleToString(Ten,_Digits));
                        
            //--- Находим кульминацию  ---
            iatr = iATR(Symbol(), PERIOD_D1, Datr, i) / SymbolInfoDouble(Symbol(), SYMBOL_POINT) / ((ATRPoint == point) ? 10.0 : 1.0);
               //Print ("ATR " + DoubleToString(iatr,_Digits));
               iatr = NormalizeDouble(iatr*point,_Digits);
            Time1  = iTime(_Symbol, PERIOD_D1, i);
            Open1  = iOpen(_Symbol, PERIOD_D1, i);
            Close1 = iClose(_Symbol, PERIOD_D1, i);
            High1  = iHigh(_Symbol, PERIOD_D1, i);
            Low1   = iLow(_Symbol, PERIOD_D1, i);
               //Print ("High " + DoubleToString(High1,_Digits));
               //Print ("Low " + DoubleToString(Low1,_Digits));         
            Low1 = Low1 + iatr;
            High1 = High1 - iatr;
               
            go_avg_low  = "low  " + (IntegerToString(i));
            go_avg_high = "high  " + (IntegerToString(i));
            name_rec4   = "rect4  " + (IntegerToString(i));

            if (Open1 > Close1 && Open1 > Low1 && High1 > Close1) //--Рисование для SELL --
               {
               ObjectCreate(go_avg_low,OBJ_TREND,0,Time1,Low1,Time1+82800,Low1);
               ObjectSet(go_avg_low,OBJPROP_RAY,false);
               ObjectSetInteger(0,go_avg_low,OBJPROP_STYLE,STYLE_DASH);
               ObjectSetInteger(0,go_avg_low,OBJPROP_COLOR,clrRed);
               
               ObjectCreate(go_avg_high,OBJ_TREND,0,Time1,High1,Time1+248400,High1);
               ObjectSet(go_avg_high,OBJPROP_RAY,false);
               ObjectSetInteger(0,go_avg_high,OBJPROP_STYLE,STYLE_DASH);
               ObjectSetInteger(0,go_avg_high,OBJPROP_COLOR,clrRed);
               
               ObjectCreate(name_rec4,OBJ_RECTANGLE,0,Time1,Open1,Time1+86400,Close1);
               ObjectSetInteger(0,name_rec4,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,name_rec4,OBJPROP_STYLE,STYLE_DASHDOTDOT);
               ObjectSetInteger(0,name_rec4,OBJPROP_WIDTH,1);
               ObjectSet(name_rec4,OBJPROP_BACK,false);
               
               Print ("ATR " + DoubleToString(iatr,_Digits));
               Print ("Open " + DoubleToString(Open1,_Digits));
               Print ("Close " + DoubleToString(Close1,_Digits));
               Print ("High " + DoubleToString(High1,_Digits));
               Print ("Low " + DoubleToString(Low1,_Digits));
               }
            if (Open1 < Close1 && Low1 < Close1 && High1 > Open1) //--Рисование для BUY --
               {
               ObjectCreate(go_avg_low,OBJ_TREND,0,Time1,Low1,Time1+248400,Low1);
               ObjectSet(go_avg_low,OBJPROP_RAY,false);
               ObjectSetInteger(0,go_avg_low,OBJPROP_STYLE,STYLE_DASH);
               ObjectSetInteger(0,go_avg_low,OBJPROP_COLOR,clrBlue);
               ObjectCreate(go_avg_high,OBJ_TREND,0,Time1,High1,Time1+82800,High1);
               ObjectSet(go_avg_high,OBJPROP_RAY,false);
               ObjectSetInteger(0,go_avg_high,OBJPROP_STYLE,STYLE_DASH);
               ObjectSetInteger(0,go_avg_high,OBJPROP_COLOR,clrBlue);
               ObjectCreate(name_rec4,OBJ_RECTANGLE,0,Time1,Open1,Time1+86400,Close1);
               ObjectSetInteger(0,name_rec4,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,name_rec4,OBJPROP_STYLE,STYLE_DASHDOTDOT);
               ObjectSetInteger(0,name_rec4,OBJPROP_WIDTH,1);
               ObjectSet(name_rec4,OBJPROP_BACK,false);
               
               Print ("ATR " + DoubleToString(iatr,_Digits));
               Print ("Open " + DoubleToString(Open1,_Digits));
               Print ("Close " + DoubleToString(Close1,_Digits));
               Print ("High " + DoubleToString(High1,_Digits));
               Print ("Low " + DoubleToString(Low1,_Digits));
               }
                       
           }
//Print("Свечка с наибольшим телом  " + index);
//--- Определение параметров для рисования ---
Time1  = iTime(_Symbol, PERIOD_D1, index);
Time0  = iTime(_Symbol, PERIOD_D1, index-1);
Open1  = iOpen(_Symbol, PERIOD_D1, index);
Close1 = iClose(_Symbol, PERIOD_D1, index);
High1  = iHigh(_Symbol, PERIOD_D1, index);
Low1   = iLow(_Symbol, PERIOD_D1, index);
Midl = (Open1 + Close1)/2;
//--- Усоловия для рисования ---
if (Open1 != Open2)
{
   if (Open1 > Close1) 
      {
         Telo = Open1 - Close1;
         Ten = (High1-Open1) + (Close1-Low1);
         
         if (Telo > Ten)
            {
                    //--Рисование прямоугольника SELL --
               ObjectCreate(name_rec1,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec1,OBJPROP_COLOR,clrRed);
               ObjectSetInteger(0,name_rec1,OBJPROP_WIDTH,1);
               ObjectSet(name_rec1,OBJPROP_BACK,false);
               ObjectCreate(name_rec2,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec2,OBJPROP_COLOR,clrLavenderBlush);
               ObjectSet(name_rec2,OBJPROP_BACK,true);
               ObjectCreate(name_s1,OBJ_TREND,0,Time1+43200,Open1,Time1+43200,High1);
               ObjectSet(name_s1,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s1,OBJPROP_COLOR,clrRed);
               ObjectCreate(name_s2,OBJ_TREND,0,Time1+43200,Close1,Time1+43200,Low1);
               ObjectSet(name_s2,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s2,OBJPROP_COLOR,clrRed);
               ObjectCreate(name_s3,OBJ_TREND,0,Time1,Midl,Time1+604800,Midl);
               ObjectSet(name_s3,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s3,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,name_s3,OBJPROP_STYLE,STYLE_DASHDOTDOT);                                        
               shift = iBarShift(NULL,PERIOD_H1,Time1+75600); 
               //Print("index of the bar for the time ",TimeToStr(Time1+75600)," is ",shift);
               Amer21 = (iOpen(_Symbol, PERIOD_H1, shift));
               datetime Amer_time1 = (iTime(_Symbol, PERIOD_H1, shift));
               Amer23 = (iOpen(_Symbol, PERIOD_H1, shift-2));
               Print("America_21 - " + DoubleToString(Amer21,_Digits) + "  America_23 - " + DoubleToString(Amer23,_Digits));
               ObjectCreate(name_rec3,OBJ_RECTANGLE,0,Amer_time1,Amer21,Amer_time1+518400,Amer23);
               ObjectSetInteger(0,name_rec3,OBJPROP_COLOR,clrRed);
               ObjectSetInteger(0,name_rec3,OBJPROP_STYLE,STYLE_DOT);
               ObjectSet(name_rec3,OBJPROP_BACK,false);               
               //Print("        " + index + "   " + Amer_time1 + "   " + Amer21 + "   " + Amer_time1+518400 + "   " + Amer23);
               //ChartRedraw(0);            
               Open2 = Open1;
               trend = false;
            }
         
      }else
         {
            Telo = Close1 - Open1;
            Ten = (High1-Close1) + (Open1-Low1);
            
            if (Telo > Ten)
               {
                   //--Рисование прямоугольника BUY --
               ObjectCreate(name_rec1,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec1,OBJPROP_COLOR,clrBlue);
               ObjectSetInteger(0,name_rec1,OBJPROP_WIDTH,1);
               ObjectSet(name_rec1,OBJPROP_BACK,false);
               ObjectCreate(name_rec2,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec2,OBJPROP_COLOR,clrLavender);
               ObjectSet(name_rec2,OBJPROP_BACK,true);
               ObjectCreate(name_s1,OBJ_TREND,0,Time1+43200,Close1,Time1+43200,High1);
               ObjectSet(name_s1,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s1,OBJPROP_COLOR,clrBlue);
               ObjectCreate(name_s2,OBJ_TREND,0,Time1+43200,Open1,Time1+43200,Low1);
               ObjectSet(name_s2,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s2,OBJPROP_COLOR,clrBlue);
               ObjectCreate(name_s3,OBJ_TREND,0,Time1,Midl,Time1+604800,Midl);
               ObjectSet(name_s3,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s3,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,name_s3,OBJPROP_STYLE,STYLE_DASHDOTDOT);                         
               shift = iBarShift(NULL,PERIOD_H1,Time1+75600); 
               //Print("index of the bar for the time ",TimeToStr(Time1+75600)," is ",shift);
               Amer21 = (iOpen(_Symbol, PERIOD_H1, shift));
               datetime Amer_time1 = (iTime(_Symbol, PERIOD_H1, shift));
               Amer23 = (iOpen(_Symbol, PERIOD_H1, shift-2));
               Print("America_21 - " + DoubleToString(Amer21,_Digits) + "  America_23 - " + DoubleToString(Amer23,_Digits));
               ObjectCreate(name_rec3,OBJ_RECTANGLE,0,Amer_time1,Amer21,Amer_time1+518400,Amer23);
               ObjectSetInteger(0,name_rec3,OBJPROP_COLOR,clrBlue);
               ObjectSetInteger(0,name_rec3,OBJPROP_STYLE,STYLE_DOT);
               ObjectSet(name_rec3,OBJPROP_BACK,false);
               //Print("        " + index + "   " + Amer_time1 + "   " + Amer21 + "   " + Amer_time1+518400 + "   " + Amer23);
               //ChartRedraw(0);
               }
               Open2 = Open1;
               trend = true;
          }
            Time1  = iTime(_Symbol, PERIOD_D1, 1);
            shift = iBarShift(NULL,PERIOD_H1,Time1+75600);
            Amer23 = (iOpen(_Symbol, PERIOD_H1, shift-2));
         Print("==================================================================================================");           
}
                 
 flag = true;
  }    
      return (true);
  }

//=================== Обработчик события кнопки ======================================================================================
bool WorkingTime2()
  {
//--- Определяем направление  ---
Print ("Размер пункта " + DoubleToString(point,2));
string   name_rec1 = "Rec_1  " + (IntegerToString(Ile_));
string   name_rec2 = "Rec_2  " + (IntegerToString(Ile_));
string   name_rec3 = "Rec_3  " + (IntegerToString(Ile_));
string   name_rec4;
string   name_s1   = "Sh_1  " + (IntegerToString(Ile_));
string   name_s2   = "Sh_2  " + (IntegerToString(Ile_));
string   name_s3   = "Sh_3  " + (IntegerToString(Ile_));
string   go_avg_low;
string   go_avg_high;
datetime Time0;
datetime Time1;
datetime Amer_time1;
double   Open1;
double   Close1;
double   High1;
double   Low1;
double   Telo;
double   Ten;
double   iatr;
int shift;
int index = 0;
double telko = 0;

      for (int i=1; i<Ile_; i++)
           {
            Time1  = iTime(_Symbol, PERIOD_D1, i);
            Open1  = iOpen(_Symbol, PERIOD_D1, i);
            Close1 = iClose(_Symbol, PERIOD_D1, i);
            High1  = iHigh(_Symbol, PERIOD_D1, i);
            Low1   = iLow(_Symbol, PERIOD_D1, i);
            Telo   = 0;
            Ten    = 0;
            
            if (Open1 > Close1) 
               {
                  Telo = Open1 - Close1;
                  Telo = NormalizeDouble(Telo/point,_Digits);
                  Ten = (High1-Open1) + (Close1-Low1);
                  Ten = NormalizeDouble(Ten/point,_Digits);
                      
               }else
                  {
                     Telo = Close1 - Open1;
                     Telo = NormalizeDouble(Telo/point,_Digits);
                     Ten = (High1-Close1) + (Open1-Low1);
                     Ten = NormalizeDouble(Ten/point,_Digits);            
                  }       
            if (Telo > telko) 
               {
               index = i;
               telko = Telo;
               }
            Print(IntegerToString(i,0) +" Итерация   " + IntegerToString(index,0) + " тело " + DoubleToString(Telo,_Digits) + " тень " + DoubleToString(Ten,_Digits));           
            
            // Рисование уовней закрытия на заданом периоде
            shift = iBarShift(NULL,PERIOD_H1,Time1+75600);
            Amer_time1 = (iTime(_Symbol, PERIOD_H1, shift-2));
            Amer23 = (iOpen(_Symbol, PERIOD_H1, shift-2));
            name_am = "Am  " + (IntegerToString(i));
                ObjectCreate(name_am,OBJ_TREND,0,Amer_time1,Amer23,Amer_time1+86400,Amer23);
                ObjectSet(name_am,OBJPROP_RAY,false);
                ObjectSetInteger(0,name_am,OBJPROP_COLOR,clrDarkBlue);
                ObjectSetInteger(0,name_am,OBJPROP_WIDTH,2);
                    
            //--- Находим кульминацию  ---
            iatr = iATR(Symbol(), PERIOD_D1, Datr, i) / SymbolInfoDouble(Symbol(), SYMBOL_POINT) / ((ATRPoint == point) ? 10.0 : 1.0);
               //Print ("ATR " + DoubleToString(iatr,_Digits));
               iatr = NormalizeDouble(iatr*point,_Digits);
            Time1  = iTime(_Symbol, PERIOD_D1, i);
            Open1  = iOpen(_Symbol, PERIOD_D1, i);
            Close1 = iClose(_Symbol, PERIOD_D1, i);
            High1  = iHigh(_Symbol, PERIOD_D1, i);
            Low1   = iLow(_Symbol, PERIOD_D1, i);
               //Print ("High " + DoubleToString(High1,_Digits));
               //Print ("Low " + DoubleToString(Low1,_Digits));         
            Low1 = Low1 + iatr;
            High1 = High1 - iatr;
               
            go_avg_low  = "low  " + (IntegerToString(i));
            go_avg_high = "high  " + (IntegerToString(i));
            name_rec4   = "rect4  " + (IntegerToString(i));
            if (Open1 > Close1 && Open1 > Low1 && High1 > Close1) //--Рисование для SELL --
               {
               ObjectCreate(go_avg_low,OBJ_TREND,0,Time1,Low1,Time1+82800,Low1);
               ObjectSet(go_avg_low,OBJPROP_RAY,false);
               ObjectSetInteger(0,go_avg_low,OBJPROP_STYLE,STYLE_DASH);
               ObjectSetInteger(0,go_avg_low,OBJPROP_COLOR,clrRed);
               
               ObjectCreate(go_avg_high,OBJ_TREND,0,Time1,High1,Time1+248400,High1);
               ObjectSet(go_avg_high,OBJPROP_RAY,false);
               ObjectSetInteger(0,go_avg_high,OBJPROP_STYLE,STYLE_DASH);
               ObjectSetInteger(0,go_avg_high,OBJPROP_COLOR,clrRed);
               
               ObjectCreate(name_rec4,OBJ_RECTANGLE,0,Time1,Open1,Time1+86400,Close1);
               ObjectSetInteger(0,name_rec4,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,name_rec4,OBJPROP_STYLE,STYLE_DASHDOTDOT);
               ObjectSetInteger(0,name_rec4,OBJPROP_WIDTH,1);
               ObjectSet(name_rec4,OBJPROP_BACK,false);
               
               Print(_Symbol);
               Print ("ATR " + DoubleToString(iatr,_Digits));
               Print ("Open " + DoubleToString(Open1,_Digits));
               Print ("Close " + DoubleToString(Close1,_Digits));
               Print ("High " + DoubleToString(High1,_Digits));
               Print ("Low " + DoubleToString(Low1,_Digits));
               }
            if (Open1 < Close1 && Low1 < Close1 && High1 > Open1) //--Рисование для BUY --
               {
               ObjectCreate(go_avg_low,OBJ_TREND,0,Time1,Low1,Time1+248400,Low1);
               ObjectSet(go_avg_low,OBJPROP_RAY,false);
               ObjectSetInteger(0,go_avg_low,OBJPROP_STYLE,STYLE_DASH);
               ObjectSetInteger(0,go_avg_low,OBJPROP_COLOR,clrBlue);
               ObjectCreate(go_avg_high,OBJ_TREND,0,Time1,High1,Time1+82800,High1);
               ObjectSet(go_avg_high,OBJPROP_RAY,false);
               ObjectSetInteger(0,go_avg_high,OBJPROP_STYLE,STYLE_DASH);
               ObjectSetInteger(0,go_avg_high,OBJPROP_COLOR,clrBlue);
               ObjectCreate(name_rec4,OBJ_RECTANGLE,0,Time1,Open1,Time1+86400,Close1);
               ObjectSetInteger(0,name_rec4,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,name_rec4,OBJPROP_STYLE,STYLE_DASHDOTDOT);
               ObjectSetInteger(0,name_rec4,OBJPROP_WIDTH,1);
               ObjectSet(name_rec4,OBJPROP_BACK,false);
               
               Print(_Symbol);
               Print ("ATR " + DoubleToString(iatr,_Digits));
               Print ("Open " + DoubleToString(Open1,_Digits));
               Print ("Close " + DoubleToString(Close1,_Digits));
               Print ("High " + DoubleToString(High1,_Digits));
               Print ("Low " + DoubleToString(Low1,_Digits));
               }
                            
           }
//Print("Свечка с наибольшим телом  " + index);
//--- Определение параметров для рисования ---
Time1  = iTime(_Symbol, PERIOD_D1, index);
Time0  = iTime(_Symbol, PERIOD_D1, index-1);
Open1  = iOpen(_Symbol, PERIOD_D1, index);
Close1 = iClose(_Symbol, PERIOD_D1, index);
High1  = iHigh(_Symbol, PERIOD_D1, index);
Low1   = iLow(_Symbol, PERIOD_D1, index);
Midl = (Open1 + Close1)/2;
//--- Усоловия для рисования ---
if (Open1 != Open2)
{
   if (Open1 > Close1) 
      {
         Telo = Open1 - Close1;
         Ten = (High1-Open1) + (Close1-Low1);
         
         if (Telo > Ten)
            {
                    //--Рисование прямоугольника SELL --
               ObjectCreate(name_rec1,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec1,OBJPROP_COLOR,clrRed);
               ObjectSetInteger(0,name_rec1,OBJPROP_WIDTH,1);
               ObjectSet(name_rec1,OBJPROP_BACK,false);
               
               ObjectCreate(name_rec2,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec2,OBJPROP_COLOR,clrLavenderBlush);
               ObjectSet(name_rec2,OBJPROP_BACK,true);
               
               ObjectCreate(name_s1,OBJ_TREND,0,Time1+43200,Open1,Time1+43200,High1);
               ObjectSet(name_s1,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s1,OBJPROP_COLOR,clrRed);
               
               ObjectCreate(name_s2,OBJ_TREND,0,Time1+43200,Close1,Time1+43200,Low1);
               ObjectSet(name_s2,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s2,OBJPROP_COLOR,clrRed);
               
               ObjectCreate(name_s3,OBJ_TREND,0,Time1,Midl,Time1+604800,Midl);
               ObjectSet(name_s3,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s3,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,name_s3,OBJPROP_STYLE,STYLE_DASHDOTDOT);                                        
               
               // Узнаём котировку закрытия америки
               shift = iBarShift(NULL,PERIOD_H1,Time1+75600); 
               //Print("index of the bar for the time ",TimeToStr(Time1+75600)," is ",shift);
               Amer21 = (iOpen(_Symbol, PERIOD_H1, shift));
               Amer_time1 = (iTime(_Symbol, PERIOD_H1, shift));
               Amer23 = (iOpen(_Symbol, PERIOD_H1, shift-2));
               Print("America_21 - " + DoubleToString(Amer21,_Digits) + "  America_23 - " + DoubleToString(Amer23,_Digits));
               
               ObjectCreate(name_rec3,OBJ_RECTANGLE,0,Amer_time1,Amer21,Amer_time1+518400,Amer23);
               ObjectSetInteger(0,name_rec3,OBJPROP_COLOR,clrRed);
               ObjectSetInteger(0,name_rec3,OBJPROP_STYLE,STYLE_DOT);
               ObjectSet(name_rec3,OBJPROP_BACK,false);               
               //Print("        " + index + "   " + Amer_time1 + "   " + Amer21 + "   " + Amer_time1+518400 + "   " + Amer23);
               //ChartRedraw(0);            
               Open2 = Open1;
               trend = false;
            }
         
      }else
         {
            Telo = Close1 - Open1;
            Ten = (High1-Close1) + (Open1-Low1);
            
            if (Telo > Ten)
               {
                   //--Рисование прямоугольника BUY --
               ObjectCreate(name_rec1,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec1,OBJPROP_COLOR,clrBlue);
               ObjectSetInteger(0,name_rec1,OBJPROP_WIDTH,1);
               ObjectSet(name_rec1,OBJPROP_BACK,false);
               ObjectCreate(name_rec2,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec2,OBJPROP_COLOR,clrLavender);
               ObjectSet(name_rec2,OBJPROP_BACK,true);
               ObjectCreate(name_s1,OBJ_TREND,0,Time1+43200,Close1,Time1+43200,High1);
               ObjectSet(name_s1,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s1,OBJPROP_COLOR,clrBlue);
               ObjectCreate(name_s2,OBJ_TREND,0,Time1+43200,Open1,Time1+43200,Low1);
               ObjectSet(name_s2,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s2,OBJPROP_COLOR,clrBlue);
               ObjectCreate(name_s3,OBJ_TREND,0,Time1,Midl,Time1+604800,Midl);
               ObjectSet(name_s3,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s3,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,name_s3,OBJPROP_STYLE,STYLE_DASHDOTDOT);                         
               shift = iBarShift(NULL,PERIOD_H1,Time1+75600); 
               //Print("index of the bar for the time ",TimeToStr(Time1+75600)," is ",shift);
               Amer21 = (iOpen(_Symbol, PERIOD_H1, shift));
               Amer_time1 = (iTime(_Symbol, PERIOD_H1, shift));
               Amer23 = (iOpen(_Symbol, PERIOD_H1, shift-2));
               Print("America_21 - " + DoubleToString(Amer21,_Digits) + "  America_23 - " + DoubleToString(Amer23,_Digits));
               ObjectCreate(name_rec3,OBJ_RECTANGLE,0,Amer_time1,Amer21,Amer_time1+518400,Amer23);
               ObjectSetInteger(0,name_rec3,OBJPROP_COLOR,clrBlue);
               ObjectSetInteger(0,name_rec3,OBJPROP_STYLE,STYLE_DOT);
               ObjectSet(name_rec3,OBJPROP_BACK,false);
               //Print("        " + index + "   " + Amer_time1 + "   " + Amer21 + "   " + Amer_time1+518400 + "   " + Amer23);
               //ChartRedraw(0);
               }
               Open2 = Open1;
               trend = true;
          }           
}
            Time1  = iTime(_Symbol, PERIOD_D1, 1);
            shift = iBarShift(NULL,PERIOD_H1,Time1+75600);
            Amer23 = (iOpen(_Symbol, PERIOD_H1, shift-2));

  Print("==================================================================================================");               
  return (true);
  }
  
//==============================================================================================================  
  
//--- Сброс Флага ---
bool FlagReset()
  {
//---
   datetime time_0=TimeCurrent();
   datetime time_1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Time_Close)  - 3600;
   datetime time_2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Time_Close)  - 3500;
   //Comment ("/n" + time_1);
   if(time_1 < time_0 && time_0 < time_2) 
    {
      flag = true;
    }
      return (true);
  }  
  
//--- Сброс имени линии тренда ---
bool TrendReset()
  {
//---
   datetime time_0=TimeCurrent();
   datetime time_1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Time_Open)  - 3600;
   datetime time_2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Time_Open)  - 3500;
   if(time_1 < time_0 && time_0 < time_2) 
    {
      name_t = "Null";
    }
      return (true);
  }  
  
  //--- Узнаём котировку закрытия Америки ---
bool AmerClose()
  {
//---
   datetime time_0=TimeCurrent();
   datetime time_1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Amer_Close);
   datetime time_2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Amer_Close) + 5;
   datetime time_3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Reset_Flag);
   datetime time_4=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Reset_Flag) + 5;
//---
   if( (time_1 < time_0 && time_0 < time_2) || (time_3 < time_0 && time_0 < time_4) ) 
   {
    Amer = (iOpen(_Symbol, PERIOD_H1, 0));
    //Print("Закрытие Америки  " + DoubleToString (Amer));
    //----- Рисование уровня закрытия америки -----
    //ObjectDelete(name_am);
    name_am = "Am  " + (TimeToString(TimeCurrent()));
    //-- создание объекта --
    ObjectCreate(name_am,OBJ_TREND,0,TimeCurrent(),Amer,TimeCurrent()+86400,Amer);
    ObjectSet(name_am,OBJPROP_RAY,false);
    ObjectSetInteger(0,name_am,OBJPROP_COLOR,clrDarkBlue);
    ObjectSetInteger(0,name_am,OBJPROP_WIDTH,2);
    ObjectDelete(name_t);
    name_t = name_am;
    //------------------
    flag = false;
   }
      return (true);
  }  

  //--- Обработчик ошибок ---
string get_Error(int error_code)
{
string error_string = "";

switch (error_code)
   {
   case 0:error_string="Нет ошибки";break;
   case 1:error_string="Нет ошибки, но результат не известен";break;
   case 2:error_string="Общая ошибка";break;
   case 3:error_string="Неправильные параметры";break;
   case 4:error_string="Торговый серсер занят";break;
   case 5:error_string="Старая версия терминала";break;
   case 6:error_string="Нет связи с сервером";break;
   case 7:error_string="Недостаточно прав";break;
   case 8:error_string="Слишком частые запросы";break;
   case 9:error_string="Операция, нарушающая функции сервера";break;
   case 64:error_string="Счёт заблокирован";break;
   case 65:error_string="Неправильный номер счёта";break;
   case 128:error_string="Истёк срок ожидания совершения сделки";break;
   case 129:error_string="Неправильная Цена";break;
   case 130:error_string="Неправильный Стоп";break;
   case 131:error_string="Неправильные Объёмы";break;
   case 132:error_string="Рынок закрыт";break;
   case 133:error_string="Торговля запрещена";break;
   case 134:error_string="Недостаточно денег";break;
   case 135:error_string="Цена изменилась";break;
   case 136:error_string="Нет цен";break;
   case 137:error_string="Брокер занят";break;
   case 138:error_string="Новые цены";break;
   case 139:error_string="Ордер заблокирован и уже обрабатывается";break;
   case 140:error_string="Разрешена только покупка";break;
   case 141:error_string="Слишком много запросов";break;
   case 145:error_string="Модификация ордера запрещена, так как ордер слишком близко к рынку";break;
   case 146:error_string="Подсистема торговли занята";break;
   case 147:error_string="Использование даты истечения ордера запрещено брокером";break;
   case 148:error_string="Количество открытых и отложенных ордеров достигло предела";break;
   }

return(error_string);
}

//--- рассчитаем ATR ---
bool ATR()
   {
   datetime Time1;
   double   High1, High2, Low1, Low2, iatr2, pr;
   double   vspread = MarketInfo(Symbol(),MODE_SPREAD);
   string tr;
   
   //--------------
   Time1  = iTime(_Symbol, PERIOD_D1, 0);
   High1  = iHigh(_Symbol, PERIOD_D1, 0);
   Low1   = iLow(_Symbol, PERIOD_D1, 0);

   //---------------
      double iatr = iATR(Symbol(), PERIOD_D1, Datr, 0) /
                 SymbolInfoDouble(Symbol(), SYMBOL_POINT) / ((ATRPoint == point) ? 10.0 : 1.0);
      double catr = (iHigh(Symbol(), PERIOD_D1, 0) - iLow(Symbol(), PERIOD_D1, 0)) /
                 SymbolInfoDouble(Symbol(), SYMBOL_POINT) / ((ATRPoint == point) ? 10.0 : 1.0);
   //---------------
   iatr2 = NormalizeDouble(iatr*point,0);
   pr =  catr*100/iatr;
   High2 = High1 - iatr2;
   Low2 = Low1 + iatr2;
   //---------------
   if (trend == true) {tr = "BUY";}else tr = "SELL";  
   //---------------
   Comment (StringConcatenate("ATR  ",DoubleToString(iatr, 0), " / " ,DoubleToString(catr,0), " -- " ,DoubleToString(pr,0), " %" , "\n" ,"Amer: " ,DoubleToString(Amer23,_Digits),"\n", tr,"\n", vspread,"\n", Midl,"\n", flag)); //Отображение информации

return (true);
   }
   //--- удаление объектов ---
bool DelObjects()
   {
   for (int i=0; i<Ile_; i++) {
    ObjectDelete("Am  " + (IntegerToString(i)));
    ObjectDelete("high  " + (IntegerToString(i)));
    ObjectDelete("low  " + (IntegerToString(i)));
    ObjectDelete("rect4  " + (IntegerToString(i)));
   }
    ObjectDelete("Rec_1  " + (IntegerToString(Ile_)));
    ObjectDelete("Rec_2  " + (IntegerToString(Ile_)));
    ObjectDelete("Rec_3  " + (IntegerToString(Ile_)));
    ObjectDelete("Sh_1  " + (IntegerToString(Ile_)));
    ObjectDelete("Sh_2  " + (IntegerToString(Ile_)));
    ObjectDelete("Sh_3  " + (IntegerToString(Ile_)));


return (true);
   }