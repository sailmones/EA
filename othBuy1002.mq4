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

int magic=121314;
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
   engineStart();
  }
//+------------------------------------------------------------------+
double buyprofit()
  {
   double a=0;
   int t=OrdersTotal();
   for(int i=t-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magic)
           {
            a=a+OrderProfit()+OrderCommission()+OrderSwap();
           }
        }
     }
   return(a);
  }
//+------------------------------------------------------------------+
void tpBuy()
  {
   int p = positionOpen();
   while(p>0)
     {
      int t=OrdersTotal();
      for(int i=t-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
           {
            if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magic)
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
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magic)
           {
            a++;
           }
        }
     }
   return(a);
  }
//+------------------------------------------------------------------+
int buy(double lots,double sl,double tp,string com,int buymagic)
  {
   int a=0;
   bool zhaodan=false;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         string zhushi=OrderComment();
         int ma=OrderMagicNumber();
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && zhushi==com && ma==buymagic)
           {
            zhaodan=true;
            break;
           }
        }
     }
   if(zhaodan==false)
     {
      if(sl!=0 && tp==0)
        {
         a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,Ask-sl*Point,0,com,buymagic,0,White);
        }
      if(sl==0 && tp!=0)
        {
         a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,0,Ask+tp*Point,com,buymagic,0,White);
        }
      if(sl==0 && tp==0)
        {
         a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,0,0,com,buymagic,0,White);
        }
      if(sl!=0 && tp!=0)
        {
         a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,Ask-sl*Point,Ask+tp*Point,com,buymagic,0,White);
        }
     }
   return(a);
  }
//+------------------------------------------------------------------+
bool isSignalOpen()
  {
   double lower_band1=iBands(NULL,PERIOD_M5,20,2,0,PRICE_CLOSE,MODE_LOWER,1);
   double lower_band2=iBands(NULL,PERIOD_M5,20,2,0,PRICE_CLOSE,MODE_LOWER,2);
   double candle_close1=iClose(NULL,PERIOD_M5,1);
   double candle_close2=iClose(NULL,PERIOD_M5,2);

   if(candle_close2 < lower_band2 && candle_close1 > lower_band1)
      if(positionOpen() == 0)
         return true;
   return false;
  }
//+------------------------------------------------------------------+
bool isBudan()
  {
   double candle_open1=iOpen(NULL,PERIOD_M5,1);
   double candle_close1=iClose(NULL,PERIOD_M5,1);
   double candle_open2=iOpen(NULL,PERIOD_M5,2);
   double candle_close2=iClose(NULL,PERIOD_M5,2);
   if(candle_close2<candle_open2 && candle_close1>candle_open1 && candle_close1 > candle_open2)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
bool isTakeProfit()
  {
   if(buyprofit() >= 止盈金额)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
void budan()
  {
   if(positionOpen() <= 加仓次数 && positionOpen() > 0)
      buy(flots(lastPositionOrderLots()*加仓倍数),0,0,"",magic);
  }
//+------------------------------------------------------------------+
double lastPositionOrderLots()
  {
   double a=0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magic)
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
      buy(初始下单, 0, 0, "", magic);
   if(isBudan() == true)
      budan();
   if(isTakeProfit() == true)
      tpBuy();
  }
//+------------------------------------------------------------------+
