void OnDeinit(const int reason)
{

    ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);
    ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrBlack);
    ChartSetInteger(0, CHART_COLOR_CHART_UP, clrGreen);
    ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrWhite);
    ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrGreen);
    ChartSetInteger(0, CHART_SHOW_GRID, true);
    ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrWhite);

      
      ObjectsDeleteAll(0,0);
}
