//+------------------------------------------------------------------+
//|                                                          Daytime |
//|                                                           Pashka |
//|                                                              ... |
//+------------------------------------------------------------------+
#property copyright "   = Pashka! =   "
#property link      "without comments"
#property version   "4.00"
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
input bool FillCandle               = true;           //FillCandleWithColors
input int Ile_                      = 20;             //Number of days to check
input int xdis                      = 220;            //Button Distanse X 

bool flag, New_Bar                  = false;
bool trend;                                           //Показатель основного тренда по телу дневной свечки (True = Long / false = short )
bool center;                                          //Тригер для срабатывания, если цена приходит к центру свечки
double Amer, Amer21, Amer23;                          //Котировка закрытие Америки
double   point                      = MarketInfo(Symbol(),MODE_POINT);
double   Open2                      = 0;
double   Midl;                                        //Котировка центра трендовой свечи
string Time_Close                   ="22:50";         //Время для проверки дневной свечи
string name_am;                                       //Имя трендовой на закрытии америки
string atr_high = "high_today";                       //Имя трендовой для ATR текущего дня
string atr_low  = "low_today";                        //Имя трендовой для ATR текущего дня
string name_t;                                        //Имя трендовой для сохранения на истории
//------
string   middle_s3   = "Sh_3 "+(IntegerToString(Ile));  //Имя трендовой для центра свечки по первому событию
//------
datetime data_close=D'21.03.2024';                    //в это число уже работать не будет


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
      // Первоначальное создание кнопки при запуске
   ObjectCreate(0,"Button",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"Button",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,"Button",OBJPROP_XDISTANCE,xdis);
   ObjectSetInteger(0,"Button",OBJPROP_YDISTANCE,5);
   ObjectSetInteger(0,"Button",OBJPROP_XSIZE,50);
   ObjectSetInteger(0,"Button",OBJPROP_YSIZE,20);
   ObjectSetInteger(0,"Button",OBJPROP_BGCOLOR,clrDarkSlateBlue);
   ObjectSetString(0,"Button",OBJPROP_TEXT,"Click");
   ObjectSetInteger(0,"Button",OBJPROP_COLOR,clrWhite);
   //----------------------------------------------------------------
   ObjectCreate(0,"Button1",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"Button1",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,"Button1",OBJPROP_XDISTANCE,xdis-55);
   ObjectSetInteger(0,"Button1",OBJPROP_YDISTANCE,5);
   ObjectSetInteger(0,"Button1",OBJPROP_XSIZE,20);
   ObjectSetInteger(0,"Button1",OBJPROP_YSIZE,20);
   ObjectSetInteger(0,"Button1",OBJPROP_BGCOLOR,clrDarkBlue);
   ObjectSetString(0,"Button1",OBJPROP_TEXT,"D");
   ObjectSetInteger(0,"Button1",OBJPROP_COLOR,clrWhite);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(ChartID(), "Button");
   ObjectsDeleteAll(ChartID(), "Button1");   
   //DelObjects();

  Comment("");

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
      Comment(" --=== Срок действия индикатора истек! ===-- ");
     }
  
   if(New_Bar)
     {

     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void ButtonClicks()
{
   if(New_Bar)
     {
   if(ObjectGetInteger(0,"Button",OBJPROP_STATE,0)!=false)
        {
         //DelObjects();
         //WorkingTime2();
         Event1();
         ObjectSetInteger(0,"Button",OBJPROP_STATE,0);
        }
   if(ObjectGetInteger(0,"Button1",OBJPROP_STATE,0)!=false)
        {
         CountDayBar();
        }else {ObjectsDeleteAll(0,"Day_");}
     }
}

void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   ButtonClicks();
}
//+------------------------------------------------------------------+

//+=== Функция для рисования дневных свечей ===================================================================================+

bool CountDayBar()
{
datetime Time0;
datetime Time1;
double   Open1;
double   Close1;
double   High1;
double   Low1;

      for (int i=1; i<Ile_; i++)
           {
           string   name_rec1 = "Day_1  " + (IntegerToString(i));
           string   name_rec2 = "Day_2  " + (IntegerToString(i));
           string   name_s1   = "Day_Sh_1  " + (IntegerToString(i));
           string   name_s2   = "Day_Sh_2  " + (IntegerToString(i));
            Time0  = iTime(_Symbol, PERIOD_D1, i-1);
            Time1  = iTime(_Symbol, PERIOD_D1, i);
            Open1  = iOpen(_Symbol, PERIOD_D1, i);
            Close1 = iClose(_Symbol, PERIOD_D1, i);
            High1  = iHigh(_Symbol, PERIOD_D1, i);
            Low1   = iLow(_Symbol, PERIOD_D1, i);
            
            if (Open1 > Close1) 
               {
                    //--Рисование прямоугольника SELL --
               ObjectCreate(name_rec1,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec1,OBJPROP_COLOR,clrRed);
               ObjectSetInteger(0,name_rec1,OBJPROP_WIDTH,1);
               ObjectSet(name_rec1,OBJPROP_BACK,false);
               
                  if (FillCandle == true)
                  {
               ObjectCreate(name_rec2,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec2,OBJPROP_COLOR,clrLavenderBlush);
               ObjectSet(name_rec2,OBJPROP_BACK,true);}
               
               ObjectCreate(name_s1,OBJ_TREND,0,Time1+43200,Open1,Time1+43200,High1);
               ObjectSet(name_s1,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s1,OBJPROP_COLOR,clrRed);
               
               ObjectCreate(name_s2,OBJ_TREND,0,Time1+43200,Close1,Time1+43200,Low1);
               ObjectSet(name_s2,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s2,OBJPROP_COLOR,clrRed);
                      
               }else
                  {
                   //--Рисование прямоугольника BUY --
               ObjectCreate(name_rec1,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec1,OBJPROP_COLOR,clrBlue);
               ObjectSetInteger(0,name_rec1,OBJPROP_WIDTH,1);
               ObjectSet(name_rec1,OBJPROP_BACK,false);
               
                  if (FillCandle == true)
                  {
               ObjectCreate(name_rec2,OBJ_RECTANGLE,0,Time1,Open1,Time0,Close1);
               ObjectSetInteger(0,name_rec2,OBJPROP_COLOR,clrLavender);
               ObjectSet(name_rec2,OBJPROP_BACK,true);}
               
               ObjectCreate(name_s1,OBJ_TREND,0,Time1+43200,Close1,Time1+43200,High1);
               ObjectSet(name_s1,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s1,OBJPROP_COLOR,clrBlue);
               
               ObjectCreate(name_s2,OBJ_TREND,0,Time1+43200,Open1,Time1+43200,Low1);
               ObjectSet(name_s2,OBJPROP_RAY,false);
               ObjectSetInteger(0,name_s2,OBJPROP_COLOR,clrBlue);           
                  }       
           }

return (true);
}

//==============================================================================================================  

void OnTimer()//int start()
{
   ATR();
   ObjectSet(middle_s3,OBJPROP_PRICE1,Midl);
   ObjectSet(middle_s3,OBJPROP_PRICE2,Midl);
   
}  
//==============================================================================================================    

void Event1()
  {
//--- Определяем направление  ---
Print ("Размер пункта " + DoubleToString(point,2));
Print(_Symbol);
string   name_rec1 = "Rec_1"; 
string   name_rec2 = "Rec_2";
string   name_rec3 = "Rec_3";
string   name_s1   = "Sh_1";
string   name_s2   = "Sh_2";
datetime Time0;
datetime Time1;
double   Open1;
double   Close1;
double   High1;
double   Low1;
double   Telo;
double   Ten;
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
                                
           }
           
Print(" ---=== Свечка с наибольшим телом ===---  " + IntegerToString(index));
//--- Определение параметров для рисования ---
Time1  = iTime(_Symbol, PERIOD_D1, index);
Time0  = iTime(_Symbol, PERIOD_D1, index-1);
Open1  = iOpen(_Symbol, PERIOD_D1, index);
Close1 = iClose(_Symbol, PERIOD_D1, index);
High1  = iHigh(_Symbol, PERIOD_D1, index);
Low1   = iLow(_Symbol, PERIOD_D1, index);
Midl = (Open1 + Close1)/2;

}

void drawingprocess(datetime time1, datetime time0, double open, double close, double high, double low, double mid)
{
double   Telo;
double   Ten;
//--- Усоловия для рисования ---
if (Open1 > Close1) 
      {
         Telo = Open1 - Close1;
         Ten = (High1-Open1) + (Close1-Low1);
         
         if (Telo > Ten)
            {
                    //--Рисование прямоугольника SELL --
                    Print ("---=== Рисование cвечи с наибольшим телом на SELL ===---");
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
               
               ObjectCreate(middle_s3,OBJ_TREND,0,Time1,Midl,Time1+604800,Midl);
               ObjectSet(middle_s3,OBJPROP_RAY,false);
               ObjectSetInteger(0,middle_s3,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,middle_s3,OBJPROP_STYLE,STYLE_DASHDOTDOT);                                    
               
               // Узнаём котировку закрытия америки
               int shift = iBarShift(NULL,PERIOD_H1,Time1+75600); 
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
               trend = false;
            }
         
      }else
         {
            Telo = Close1 - Open1;
            Ten = (High1-Close1) + (Open1-Low1);
            
            if (Telo > Ten)
               {
                   //--Рисование прямоугольника BUY --
                   Print ("---=== Рисование cвечи с наибольшим телом на BUY ===---");
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
               ObjectCreate(middle_s3,OBJ_TREND,0,Time1,Midl,Time1+604800,Midl);
               ObjectSet(middle_s3,OBJPROP_RAY,false);
               ObjectSetInteger(0,middle_s3,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,middle_s3,OBJPROP_STYLE,STYLE_DASHDOTDOT);                         
               int shift = iBarShift(NULL,PERIOD_H1,Time1+75600); 
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
               trend = true;
          }           
            Time1  = iTime(_Symbol, PERIOD_D1, 1);
            int shift = iBarShift(NULL,PERIOD_H1,Time1+75600);
            Amer23 = (iOpen(_Symbol, PERIOD_H1, shift-2));
            
  //------- Создание трендовых для текущего ATR ----------------
      ObjectCreate(atr_low,OBJ_TREND,0,TimeCurrent()-82800,Low1,TimeCurrent()+82800,Low1);
      ObjectSet(atr_low,OBJPROP_RAY,false);
      ObjectSetInteger(0,atr_low,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,atr_low,OBJPROP_COLOR,clrForestGreen);
               
      ObjectCreate(atr_high,OBJ_TREND,0,TimeCurrent()-82800,High1,TimeCurrent()+82800,High1);
      ObjectSet(atr_high,OBJPROP_RAY,false);
      ObjectSetInteger(0,atr_high,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,atr_high,OBJPROP_COLOR,clrCrimson);
       
  Print("==================================================================================================");
                   
  }  
  
  //========================================================================================================


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
   //--------------- Рисование ATR --------------------
   iatr2 = NormalizeDouble(iatr*point,_Digits);
   pr =  catr*100/iatr;
   High2 = High1 - iatr2;
   Low2 = Low1 + iatr2;
   ObjectMove(atr_low,1,TimeCurrent()+82800,Low2);
   ObjectMove(atr_high,1,TimeCurrent()+82800,High2);
   ObjectMove(atr_low,0,TimeCurrent()-82800,Low2);
   ObjectMove(atr_high,0,TimeCurrent()-82800,High2);
   //---------------
   if (trend == true) {tr = "BUY";}else tr = "SELL";  
   //---------------
   Comment (StringConcatenate("ATR  ",DoubleToString(iatr, 0), " / " ,DoubleToString(catr,0), " -- " ,DoubleToString(pr,0), " %" , "\n" ,"Amer: " ,DoubleToString(Amer23,_Digits),"\n", tr,"\n", vspread,"\n", Midl,"\n", flag,"\n", High2,"\n", Low2)); //Отображение информации

return (true);
   }
   
   //--- удаление объектов ---
void DelObjects()
   {
   ObjectsDeleteAll(0,"Rec");
   ObjectsDeleteAll(0,"Sh");
   ObjectsDeleteAll(0,"Am");
   ObjectsDeleteAll(0,"high");
   ObjectsDeleteAll(0,"low");
   }