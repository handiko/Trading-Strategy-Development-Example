//+------------------------------------------------------------------+
//|                                        CandlePatternBreakout.mqh |
//|                                   Copyright 2025, Handiko Gesang |
//|                                   https://www.github.com/handiko |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Handiko Gesang"
#property link      "https://www.github.com/handiko"

#property version   "1.00"

#include <Trade/Trade.mqh>
#include "StandardIncludes.mqh"
#include "main.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandlePatternBreakout {
private:
     int                   Magic;
     string                Pair;
     double                Lots;
     int                   LiquidityDist;
     ENUM_CANDLE_PATTERN   Pattern;
     double                RewardToRisk;
     int                   StopLoss;
     ENUM_TIMEFRAMES       Timeframe;
     int                   ExpirationHours;
     ENUM_DIRECTION_MODE   DirectionMode;

     //Global Vars
     CTrade          trade;
     int             TakeProfit;
     ulong           buyPos, sellPos;
     int             totalBars;

     double          pairPoint;
     int             pairDigits;

     void            IndicatorInit();
     void            IndicatorDeinit();
     void            processPos(ulong & posTicket);
     double          findBuySignal();
     double          findSellSignal();
     void            executeBuy(double entry);
     void            executeSell(double entry);

public:
     CandlePatternBreakout(string pair, double lot, int liquidityDist, ENUM_CANDLE_PATTERN pattern,
                           double rewardToRisk, int stopLoss, ENUM_TIMEFRAMES timeframe, int expirationHours,
                           int magic, ENUM_DIRECTION_MODE directionMode);
     ~CandlePatternBreakout();
     int             OnInitEvent();
     void            OnDeinitEvent(const int reason);
     void            OnTickEvent();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CandlePatternBreakout::CandlePatternBreakout(string pair, double lot, int liquidityDist, ENUM_CANDLE_PATTERN pattern,
          double rewardToRisk, int stopLoss, ENUM_TIMEFRAMES timeframe, int expirationHours,
          int magic, ENUM_DIRECTION_MODE directionMode) {
     Magic = magic;
     Pair = pair;
     Lots = NormalizeDouble(lot, 2);
     LiquidityDist = liquidityDist;
     Pattern = pattern;
     RewardToRisk = rewardToRisk;
     StopLoss = stopLoss;
     Timeframe = timeframe;
     ExpirationHours = expirationHours;
     DirectionMode = directionMode;

     pairPoint = SymbolInfoDouble(Pair, SYMBOL_POINT);
     pairDigits = (int)SymbolInfoInteger(Pair, SYMBOL_DIGITS);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CandlePatternBreakout::~CandlePatternBreakout() {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CandlePatternBreakout::OnInitEvent() {
     if(!SymbolSelect(Pair, true)) {
          Print(__FUNCTION__, " > EA Failed to select symbol ", Pair, " ...");
          return(INIT_FAILED);
     }

     trade.SetExpertMagicNumber(Magic);
     if(!trade.SetTypeFillingBySymbol(Pair)) {
          trade.SetTypeFilling(ORDER_FILLING_RETURN);
     }

     return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CandlePatternBreakout::OnDeinitEvent(const int reason) {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CandlePatternBreakout::processPos(ulong & posTicket) {
     if(posTicket <= 0) return;
     if(OrderSelect(posTicket)) return;

     CPositionInfo pos;
     if(!pos.SelectByTicket(posTicket)) {
          posTicket = 0;
          return;
     }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CandlePatternBreakout::findBuySignal() {
     ENUM_CANDLE_PATTERN cp;
     double high;
     bool candle[3];

     for(int i = 0; i < 3; i++) {
          candle[i] = (iClose(Pair, Timeframe, i + 1) > iOpen(Pair, Timeframe, i + 1)) ? true : false;
     }

     if(candle[2] && candle[1] && candle[0]) {
          cp = UUU;
     } else if(candle[2] && candle[1] && !candle[0]) {
          cp = UUD;
     } else if(candle[2] && !candle[1] && candle[0]) {
          cp = UDU;
     } else if(candle[2] && !candle[1] && !candle[0]) {
          cp = UDD;
     } else if(!candle[2] && candle[1] && candle[0]) {
          cp = DUU;
     } else if(!candle[2] && candle[1] && !candle[0]) {
          cp = DUD;
     } else if(!candle[2] && !candle[1] && candle[0]) {
          cp = DDU;
     } else {
          cp = DDD;
     }

     high = iHigh(Pair, Timeframe, 1);
     if(cp == Pattern) {
          return high;
     }

     return -1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CandlePatternBreakout::findSellSignal() {
     ENUM_CANDLE_PATTERN cp;
     double low;
     bool candle[3];

     for(int i = 0; i < 3; i++) {
          candle[i] = (iClose(Pair, Timeframe, i + 1) > iOpen(Pair, Timeframe, i + 1)) ? true : false;
     }

     if(candle[2] && candle[1] && candle[0]) {
          cp = UUU;
     } else if(candle[2] && candle[1] && !candle[0]) {
          cp = UUD;
     } else if(candle[2] && !candle[1] && candle[0]) {
          cp = UDU;
     } else if(candle[2] && !candle[1] && !candle[0]) {
          cp = UDD;
     } else if(!candle[2] && candle[1] && candle[0]) {
          cp = DUU;
     } else if(!candle[2] && candle[1] && !candle[0]) {
          cp = DUD;
     } else if(!candle[2] && !candle[1] && candle[0]) {
          cp = DDU;
     } else {
          cp = DDD;
     }

     low = iLow(Pair, Timeframe, 1);
     if(cp == Pattern) {
          return low;
     }

     return -1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CandlePatternBreakout::executeBuy(double entry) {
     entry = NormalizeDouble(entry + LiquidityDist * pairPoint, pairDigits);

     double ask = SymbolInfoDouble(Pair, SYMBOL_ASK);
     if(ask > entry) return;

     double tp = entry + TakeProfit * pairPoint;
     tp = NormalizeDouble(tp, pairDigits);

     double sl = entry - StopLoss * pairPoint;
     sl = NormalizeDouble(sl, pairDigits);

     double lots = Lots;

     datetime expiration = iTime(Pair, Timeframe, 0) + ExpirationHours * PeriodSeconds(PERIOD_H1) - PeriodSeconds(PERIOD_M5);

     trade.BuyStop(lots, entry, Pair, sl, tp, ORDER_TIME_SPECIFIED, expiration);

     buyPos = trade.ResultOrder();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CandlePatternBreakout::executeSell(double entry) {
     entry = NormalizeDouble(entry - LiquidityDist * pairPoint, pairDigits);

     double bid = SymbolInfoDouble(Pair, SYMBOL_BID);
     if(bid < entry) return;

     double tp = entry - TakeProfit * pairPoint;
     tp = NormalizeDouble(tp, pairDigits);

     double sl = entry + StopLoss * pairPoint;
     sl = NormalizeDouble(sl, pairDigits);

     double lots = Lots;

     datetime expiration = iTime(Pair, Timeframe, 0) + ExpirationHours * PeriodSeconds(PERIOD_H1) - PeriodSeconds(PERIOD_M5);

     trade.SellStop(lots, entry, Pair, sl, tp, ORDER_TIME_SPECIFIED, expiration);

     sellPos = trade.ResultOrder();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CandlePatternBreakout::OnTickEvent() {
     processPos(buyPos);
     processPos(sellPos);

     if(MarketOpenHours(Pair)) {
          int bars = iBars(Pair, Timeframe);
          if(totalBars != bars) {
               totalBars = bars;

               TakeProfit = (int)(StopLoss * RewardToRisk);

               if((DirectionMode == BUY_ONLY) || (DirectionMode == BUY_AND_SELL)) {
                    if(buyPos <= 0) {
                         double high = findBuySignal();
                         if(high > 0) {
                              executeBuy(high);
                         }
                    }
               }

               if((DirectionMode == SELL_ONLY) || (DirectionMode == BUY_AND_SELL)) {
                    if(sellPos <= 0) {
                         double low = findSellSignal();
                         if(low > 0) {
                              executeSell(low);
                         }
                    }
               }
          }
     }
}
//+------------------------------------------------------------------+
