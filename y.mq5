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
datetime startDate = D'2023.10.24';
int trial_days = 2;

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
  
  ENUM_BASE_CORNER BASE_CORNER = CORNER_RIGHT_LOWER;
int FontSize = 20;
string FontName = "Times New Roman";
string NoteRedGreenBlue = "Red/Green/Blue each 0..255";
int RGBRed = 1;
int RGBGreen = 1;
int RGBBlue = 1;
int XPos = 250;

string Pair = "Symbol";
int RGB = 0;
string tf;
int YPos = 200;
  
          watermark(Pair, "Harry Vfx King , " + Period() + " , " + Symbol(), FontSize, FontName, RGB, XPos, YPos);


      ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);
    ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrGreen);
    ChartSetInteger(0, CHART_COLOR_CHART_UP, clrGreen);
    ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrRed);
    ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrRed);
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrWhite);
    
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


 // Add any deinitialization code here
    ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);
    ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrBlack);
    ChartSetInteger(0, CHART_COLOR_CHART_UP, clrGreen);
    ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrWhite);
    ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrGreen);
    ChartSetInteger(0, CHART_SHOW_GRID, true);
    ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrWhite);

      
      ObjectsDeleteAll(0,0);
   
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

 // Create and set properties for each label object
        int yDistance = 20; // Vertical distance between labels

        // Create and set properties for label "_LABEL_4"
        ObjectCreate(0, "_LABEL_4", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "_LABEL_4", OBJPROP_CORNER, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, "_LABEL_4", OBJPROP_ANCHOR, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, "_LABEL_4", OBJPROP_COLOR, clrWhite);
        ObjectSetString(0, "_LABEL_4", OBJPROP_TEXT, "Current time is " + current_t);
        ObjectSetInteger(0, "_LABEL_4", OBJPROP_YDISTANCE, yDistance * 3);
        ObjectSetInteger(0, "_LABEL_4", OBJPROP_XDISTANCE, 10);

        // Create and set properties for label "_LABEL_2"
        ObjectCreate(0, "_LABEL_2", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "_LABEL_2", OBJPROP_CORNER, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, "_LABEL_2", OBJPROP_ANCHOR, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, "_LABEL_2", OBJPROP_COLOR, clrWhite);
        string text = "Bot starts at " + now;
        ObjectSetString(0, "_LABEL_2", OBJPROP_TEXT, text);
        ObjectSetInteger(0, "_LABEL_2", OBJPROP_YDISTANCE, yDistance * 2);
        ObjectSetInteger(0, "_LABEL_2", OBJPROP_XDISTANCE, 10);

        ObjectCreate(0, "_LABEL_50", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "_LABEL_50", OBJPROP_CORNER, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, "_LABEL_50", OBJPROP_ANCHOR, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, "_LABEL_50", OBJPROP_COLOR, clrWhite);
        ObjectSetString(0, "_LABEL_50", OBJPROP_TEXT, "Bot will end at " + endTime);

        ObjectSetInteger(0, "_LABEL_50", OBJPROP_YDISTANCE, yDistance);
        ObjectSetInteger(0, "_LABEL_50", OBJPROP_XDISTANCE, 10);

        // Create and set properties for label "_LABEL_3"

        ObjectCreate(0, "_LABEL_3", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "_LABEL_3", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
        ObjectSetInteger(0, "_LABEL_3", OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0, "_LABEL_3", OBJPROP_COLOR, clrYellowGreen);
        ObjectSetString(0, "_LABEL_3", OBJPROP_TEXT, current_ask);
        ObjectSetInteger(0, "_LABEL_3", OBJPROP_YDISTANCE, yDistance * 2);
        ObjectSetInteger(0, "_LABEL_3", OBJPROP_XDISTANCE, 10);

        // Create and set properties for label "_LABEL_6"
        ObjectCreate(0, "_LABEL_6", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "_LABEL_6", OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, "_LABEL_6", OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, "_LABEL_6", OBJPROP_COLOR, clrWhite);
        ObjectSetString(0, "_LABEL_6", OBJPROP_TEXT, "Initial Balance " + DoubleToString(initial_deposit, 2) + " USD");
        ObjectSetInteger(0, "_LABEL_6", OBJPROP_YDISTANCE, yDistance);
        ObjectSetInteger(0, "_LABEL_6", OBJPROP_XDISTANCE, 10);

        // Create and set properties for label "_LABEL_7"
        ObjectCreate(0, "_LABEL_7", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "_LABEL_7", OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, "_LABEL_7", OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, "_LABEL_7", OBJPROP_COLOR, clrWhite);
        ObjectSetString(0, "_LABEL_7", OBJPROP_TEXT, "Bot will stop at balance " + DoubleToString(max_equity_to_stop, 2) + " USD or " + DoubleToString(min_equity_to_stop, 2) + " USD");
        ObjectSetInteger(0, "_LABEL_7", OBJPROP_YDISTANCE, yDistance * 2);
        ObjectSetInteger(0, "_LABEL_7", OBJPROP_XDISTANCE, 10);

        // Create and set properties for label "_LABEL_8"
        ObjectCreate(0, "_LABEL_8", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "_LABEL_8", OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, "_LABEL_8", OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, "_LABEL_8", OBJPROP_COLOR, clrWhite);
        ObjectSetString(0, "_LABEL_8", OBJPROP_TEXT, "Current Equity is " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
        ObjectSetInteger(0, "_LABEL_8", OBJPROP_YDISTANCE, yDistance * 3);
        ObjectSetInteger(0, "_LABEL_8", OBJPROP_XDISTANCE, 10);


     
  }
//+------------------------------------------------------------------+

void watermark(string obj, string text, int fontSize, string fontName, color colour, int xPos, int yPos)
{
    // Create and set properties for label "_LABEL_0"
    ObjectCreate(0, "_LABEL_0", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "_LABEL_0", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, "_LABEL_0", OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0, "_LABEL_0", OBJPROP_COLOR, clrGreenYellow);
    ObjectSetString(0, "_LABEL_0", OBJPROP_TEXT, text);
    ObjectSetString(0, "_LABEL_0", OBJPROP_FONT, fontName);
    ObjectSetInteger(0, "_LABEL_0", OBJPROP_FONTSIZE, fontSize);
    ObjectSetInteger(0, "_LABEL_0", OBJPROP_YDISTANCE, yPos);
    ObjectSetInteger(0, "_LABEL_0", OBJPROP_XDISTANCE, xPos);
}
