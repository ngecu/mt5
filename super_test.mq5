//+------------------------------------------------------------------+
//|                                                            x.mq5 |
//|                                          Copyright 2023, PipPips |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, PipPips"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade trade;
CPositionInfo  m_position;                   // trade position object

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
datetime today;
double high_previous;
double open_previous;
int totalBars;
bool orderTriggered = false;
input group           "EXECUTION INSTRUCTIONS"
input double lot_size = 2; 
input double candle_length = 2;
input int number_of_trade_ = 1;

input group           "EXECUTION TYPE"
input bool BUY_EXECUTION = false;
input bool SELL_EXECUTION = false;

input group           "TP INSTRUCTIONS"
input double take_profit_seconds = 0;
input double take_profit_pips = 40;      
input double stop_loss_pips = 20;     

input group           "EXIT BOT ON "
input double max_profit = 0;
input double max_loss = 0;


double initial_deposit = AccountInfoDouble(ACCOUNT_BALANCE);
double max_equity_to_stop = initial_deposit +  max_profit;
double min_equity_to_stop = initial_deposit - max_loss;


// CLIENT RESTRICTIONS
//long allowedLogin = 30523674; 
datetime startDate = D'2023.10.16';
int trial_days = 7;


bool isDate7DaysFromGivenDay(const datetime givenDay)
{
  today = TimeLocal();
  datetime endDate = startDate + (trial_days * 24 * 60 * 60);
  return endDate < startDate;
}
 

int OnInit()
  {
//---
   
       if (isDate7DaysFromGivenDay(startDate))
    {
        // Display an alert message
        Alert("Your trial has expired. Contact wamaitha@peeppips.com");

        // Remove the Expert Advisor
        ExpertRemove();
        return (INIT_FAILED);
    }
    

  //  if (AccountInfoInteger(ACCOUNT_LOGIN) != allowedLogin)
  //  {
        // Display an alert message
   //     Alert("Unauthorized access. This EA will be removed.");

        // Remove the Expert Advisor
 //       ExpertRemove();
   //     return (INIT_FAILED);
   // }
  //  else
  //  {
        // Place your code here that should only be executed for the allowed account

        // Example: Print a message for the allowed account
 //       Print("This code is executed for the allowed account: ", allowedLogin);
  //      return (INIT_SUCCEEDED);
  //  }
    
   totalBars = iBars(_Symbol, PERIOD_CURRENT);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
datetime current_time = TimeCurrent();

if(take_profit_seconds > 0){
  for(int i=PositionsTotal()-1;i>=0;i--) 
      if(m_position.SelectByIndex(i))    
         if(m_position.Symbol()==Symbol())
         {
         datetime openTime = PositionGetInteger(POSITION_TIME);  
         if(current_time >= openTime + take_profit_seconds){
                  trade.PositionClose(m_position.Ticket()); 
            }
         }
}


if (AccountInfoDouble(ACCOUNT_EQUITY) >= max_equity_to_stop || AccountInfoDouble(ACCOUNT_EQUITY) <= min_equity_to_stop)
{
    Print("Threshold reached");
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong orderTicket = PositionGetTicket(i);
        trade.PositionClose(orderTicket);
    }
    orderTriggered = false;
    // Comment("");
    Alert("Bot removed due to Profit/Loss Conditions");
    ExpertRemove();
}

 if (isDate7DaysFromGivenDay(startDate))
 {
     // Display an alert message
     Alert("Your trial period has expired. This EA will be removed.");
     ExpertRemove();
 }
 
   int bars = iBars(_Symbol,PERIOD_CURRENT);
   
   if(bars > totalBars){
   totalBars = bars;
   orderTriggered = false;
   
   
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
ask = NormalizeDouble(ask, _Digits);
double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
bid = NormalizeDouble(bid, _Digits);
double close_previous = iClose(Symbol(), PERIOD_CURRENT, 1);
open_previous = iOpen(Symbol(), PERIOD_CURRENT, 1);

if (StringFind(_Symbol, "Crash") != -1)
{

    if (open_previous - close_previous >= candle_length)
    {
        if (BUY_EXECUTION)
        {
            
            double tpBuy = ask + ((take_profit_pips));
            tpBuy = NormalizeDouble(tpBuy, _Digits);
            double slBuy = ask - ((stop_loss_pips));
            slBuy = NormalizeDouble(slBuy, _Digits);
            
            if (!orderTriggered)
            {
                
                 for (int i = 0; i < number_of_trade_; i++)
                      {
                          if (trade.Buy(lot_size, _Symbol,0,slBuy,tpBuy))
                          {
                              orderTriggered = true;
                             
                          }
                      }
             
            }
        }
    }
   
   }
   
   
if (StringFind(_Symbol, "Boom") != -1)
{
    if (close_previous - open_previous >= candle_length)
    {
        if (SELL_EXECUTION)
        {
            
            double tpSell = bid - take_profit_pips;
            tpSell = NormalizeDouble(tpSell, _Digits);
            double slSell = ask + stop_loss_pips;
            slSell = NormalizeDouble(slSell, _Digits);
            
            if (!orderTriggered)
            {
                for (int i = 0; i < number_of_trade_; i++)
                {
                    if (trade.Sell(lot_size, _Symbol, 0, slSell, tpSell))
                    {
                        orderTriggered = true;
                    }
                }
            }
        }
    }
}

   
   }
   
   
    

  }
//+------------------------------------------------------------------+
