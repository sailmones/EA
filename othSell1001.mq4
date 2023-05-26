//+------------------------------------------------------------------+
//|                                                      oth1001.mq4 |
//|                                                   opentradinghub |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "opentradinghub"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double 初始下单=0.1;
extern double 止盈金额=5.8;
extern double 加仓倍数=2;
extern int 加仓次数=5;

int magic=121312;
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
void OnTick()
  {

  }
//+------------------------------------------------------------------+
double sellprofit()
  {
   double a=0;
   int t=OrdersTotal();
   for(int i=t-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==magic)
           {
            a=a+OrderProfit()+OrderCommission()+OrderSwap();
           }
        }
     }
   return(a);
  }
//+------------------------------------------------------------------+
void tpSell()
  {
   int p = positionOpen();
   while(p>0)
     {
      int t=OrdersTotal();
      for(int i=t-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
           {
            if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==magic)
              {
               OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),300,Green);
              }
           }
        }
      Sleep(800);
     }
  }
//+------------------------------------------------------------------+
double flots(double dlots)
  {
   double fb=NormalizeDouble(dlots/MarketInfo(Symbol(),MODE_MINLOT),0);
   return(MarketInfo(Symbol(),MODE_MINLOT)*fb);
  }
//+------------------------------------------------------------------+
int positionOpen()
  {
   int a=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==magic)
           {
            a++;
           }
        }
     }
   return(a);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int sell(double lots,double sl,double tp,string com,int sellmagic)
  {
   int a=0;
   bool zhaodan=false;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         string zhushi=OrderComment();
         int ma=OrderMagicNumber();
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && zhushi==com && ma==sellmagic)
           {
            zhaodan=true;
            break;
           }
        }
     }
   if(zhaodan==false)
     {
      if(sl==0 && tp!=0)
        {
         a=OrderSend(Symbol(),OP_SELL,lots,Bid,50,0,Bid-tp*Point,com,sellmagic,0,Red);
        }
      if(sl!=0 && tp==0)
        {
         a=OrderSend(Symbol(),OP_SELL,lots,Bid,50,Bid+sl*Point,0,com,sellmagic,0,Red);
        }
      if(sl==0 && tp==0)
        {
         a=OrderSend(Symbol(),OP_SELL,lots,Bid,50,0,0,com,sellmagic,0,Red);
        }
      if(sl!=0 && tp!=0)
        {
         a=OrderSend(Symbol(),OP_SELL,lots,Bid,50,Bid+sl*Point,Bid-tp*Point,com,sellmagic,0,Red);
        }
     }
   return(a);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isSignalOpen()
  {
   double upper_band1=iBands(NULL,PERIOD_M5,20,2,0,PRICE_CLOSE,MODE_UPPER,1);
   double upper_band2=iBands(NULL,PERIOD_M5,20,2,0,PRICE_CLOSE,MODE_UPPER,2);
   double candle_close1=iClose(NULL,PERIOD_M5,1);
   double candle_close2=iClose(NULL,PERIOD_M5,2);

   if(candle_close2 > upper_band2 && candle_close1 < upper_band1)
     {
      if(positionOpen() == 0)
         return true;
     };
   return false;
  }
//+------------------------------------------------------------------+
bool isBudan()
  {
   double candle_open1=iOpen(NULL,PERIOD_M5,1);
   double candle_close1=iClose(NULL,PERIOD_M5,1);
   double candle_open2=iOpen(NULL,PERIOD_M5,2);
   double candle_close2=iClose(NULL,PERIOD_M5,2);
   if(candle_close2>candle_open2 && candle_close1<candle_open1 && candle_close1 < candle_open2)
     {
      return true;
     };
   return false;
  }
//+------------------------------------------------------------------+
bool isTakeProfit()
  {
   if(sellprofit() >= 止盈金额)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
void budan()
  {
   if(positionOpen() <= 加仓次数 && positionOpen() > 0)
      sell(flots(lastPositionOrderLots()*加仓倍数),0,0,"",magic);
  }
//+------------------------------------------------------------------+
double lastPositionOrderLots()
  {
   double a=0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==magic)
           {
            a=OrderLots();
           }
        }
     }
   return(a);
  }
//+------------------------------------------------------------------+
void engineStart()
  {
   if(isSignalOpen() == true)
      sell(初始下单, 0, 0, "", magic);
   if(isBudan() == true)
      budan();
   if(isTakeProfit() == true)
      tpSell();
  }
//+------------------------------------------------------------------+
