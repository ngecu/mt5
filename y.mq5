//+------------------------------------------------------------------+
//|                                                            y.mq5 |
//|                                          Copyright 2023, PipPips |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, PipPips"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade trade;


input group "EA SETTINGS" 
input double lot_size = 2;
input double stop_bot_at_max_profit = 200;
input double stop_bot_at_max_loss = 200;
input double spike_length_pips = 2;
input int run_bot_for_x_minutes = 13200;
input int number_of_trade_ = 1;

input group "TYPES OF EXECUTION" 
input bool BUY_EXECUTION = true;
input bool SELL_EXECUTION = false;


input group "ORDER POSITION INSTRUCTIONS" 
input bool EXECUTION_AT_RED_CANDLE_CLOSE = true;
input double execution_pips_from_red_close = 0;

input bool EXECUTION_AT_GREEN_CANDLE_CLOSE = true;
input double execution_pips_from_green_close = 0;

input group "TP INSTRUCTIONS" 
input bool TP_IN_PIPS = true;
input double red_take_profit_pips = 20;
input double green_take_profit_pips = 25;

input bool TP_IN_SECONDS = false;
input double red_take_profit_seconds = 0;
input double green_take_profit_seconds = 0;

input group "SL INSTRUCTIONS" 
input double red_stop_loss_pips = 25;
input double green_stop_loss_pips = 20;

double initial_deposit = AccountInfoDouble(ACCOUNT_BALANCE);
double max_equity_to_stop = initial_deposit + stop_bot_at_max_profit;
double min_equity_to_stop = initial_deposit - stop_bot_at_max_loss;


int totalBars;
bool orderTriggered = false;
bool start_trading;
datetime red_trade_started_at ;
datetime green_trade_started_at ;
datetime now, endTime,today;
long allowedLogin = 31034436;
datetime startDate = D'2023.10.23';
int trial_days = 7;

datetime tm = TimeCurrent();
MqlDateTime stm;
MqlDateTime selected_time;

bool isDate7DaysFromGivenDay(const datetime givenDay)
{
    today = TimeLocal();
    datetime endDate = startDate + (trial_days * 24 * 60 * 60);
    return endDate < startDate;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   start_trading = false;
       now = TimeTradeServer();
    today = TimeTradeServer();
    endTime = today + (1 * 1 * run_bot_for_x_minutes * 60);
    
    
        if (isDate7DaysFromGivenDay(startDate))
    {
        // Display an alert message
        Alert("Your trial has expired. Contact wamaitha@peeppips.com");

        // Remove the Expert Advisor
        ExpertRemove();
        return (INIT_FAILED);
    }
    
      if (AccountInfoInteger(ACCOUNT_LOGIN) != allowedLogin)
    {
        // Display an alert message
        Alert("Unauthorized access. This EA will be removed.");

        // Remove the Expert Advisor
        ExpertRemove();
        return (INIT_FAILED);
    }
    
//---
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
   int end_hour = (selected_time.hour + (run_bot_for_x_minutes / 60));
    // Calculate the end minutes (using modulus)
    int end_minutes = run_bot_for_x_minutes % 60;
    if (end_minutes == 0)
    {
        end_minutes = selected_time.min + end_minutes;
        if (end_minutes >= 60)
        {
            end_minutes -= 60;
            end_hour = end_hour + 1;
        }
    }
    if (end_hour >= 24)
    {
        end_hour -= 24; // Subtract 24 if it goes over 24 hours
    }



    datetime current_t = TimeTradeServer();

    TimeToStruct(current_t, stm);
    
        datetime bot_will_end_at = TimeTradeServer();
    +(1 * 1 * run_bot_for_x_minutes * 60);
    
     if (current_t >= endTime)
    {
    // Display an alert message
     Alert("Bot removed due to time elapse");
     ExpertRemove();
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
    
    int bars = iBars(_Symbol, PERIOD_CURRENT);
    
    double current_ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double tpBuy, slBuy;
    
    if(TP_IN_SECONDS){
    
      
    }
    
            if (bars > totalBars)
        {
        
                for (int i = PositionsTotal() - 1; i >= 0; i--)
        {
           ulong orderTicket = PositionGetTicket(i);
           trade.PositionClose(orderTicket);
       }
        
        orderTriggered = false;
             totalBars = bars;
             start_trading = true;
             
                 double close_previous = iClose(Symbol(), PERIOD_CURRENT, 1);
                 double open_previous = iOpen(Symbol(), PERIOD_CURRENT, 1);
                 
                 //BEAR
                             if ((open_previous - close_previous >= spike_length_pips) && BUY_EXECUTION && EXECUTION_AT_RED_CANDLE_CLOSE)
            {
            
            
             double expected_buy_price = close_previous + execution_pips_from_red_close;
             
                     Print(expected_buy_price);
        if (!orderTriggered && current_ask >= expected_buy_price && start_trading)
        {

            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            ask = NormalizeDouble(ask, _Digits);
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            bid = NormalizeDouble(bid, _Digits);
            
             double tpBuy = ask + red_take_profit_pips;
               tpBuy = NormalizeDouble(tpBuy,_Digits);
 
  double slBuy = current_ask - red_stop_loss_pips;
 slBuy = NormalizeDouble(slBuy,_Digits);

           
            if (TP_IN_PIPS)
            {
                for (int i = 0; i < number_of_trade_; i++)
                {
                    if (trade.Buy(lot_size, _Symbol,0,slBuy,tpBuy))
                    {
                       
                        orderTriggered = true;
                         expected_buy_price = 0;
                    }
                }
            }
            if (TP_IN_SECONDS)
            {
                for (int i = 0; i < number_of_trade_; i++)
                {
                    if (trade.Buy(lot_size, _Symbol, 0, 0, 0))
                    {
                        orderTriggered = true;
                        red_trade_started_at = TimeCurrent();
                    }
                }
            }
        }
 
            }
            
            //BULL
                              if ((close_previous - open_previous >= spike_length_pips) && BUY_EXECUTION && EXECUTION_AT_GREEN_CANDLE_CLOSE)
            {
                
                
            
             double expected_buy_price = close_previous + execution_pips_from_green_close;
             
                     Print(expected_buy_price);
        if (!orderTriggered && current_ask >= expected_buy_price && start_trading)
        {

            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            ask = NormalizeDouble(ask, _Digits);
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            bid = NormalizeDouble(bid, _Digits);
            
             double tpBuy = ask + green_take_profit_pips;
               tpBuy = NormalizeDouble(tpBuy,_Digits);
 
  double slBuy = current_ask - green_stop_loss_pips;
 slBuy = NormalizeDouble(slBuy,_Digits);

           
            if (TP_IN_PIPS)
            {
                for (int i = 0; i < number_of_trade_; i++)
                {
                    if (trade.Buy(lot_size, _Symbol,0,slBuy,tpBuy))
                    {
                       
                        orderTriggered = true;
                         expected_buy_price = 0;
                    }
                }
            }
            if (TP_IN_SECONDS)
            {
                for (int i = 0; i < number_of_trade_; i++)
                {
                    if (trade.Buy(lot_size, _Symbol, 0, 0, 0))
                    {
                        orderTriggered = true;
                        green_trade_started_at = TimeCurrent();
                    }
                }
            }
        }
            
            
            }
             
             
             }


   
  }
//+------------------------------------------------------------------+
