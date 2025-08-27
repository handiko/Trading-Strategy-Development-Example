# Trading Strategy Development Example

Continuing the discussion from the previous sections, in this article, we will develop a real trading strategy inspired by the Markov Chain study results. The trading strategy presented in this article, I actually use it personally on my real trading account. There are some minor parameter differences from my personal settings, but overall, it is actually very much the same. 

---

## Disclaimer !!!
**I do not recommend that anybody follow my strategy, as I cannot guarantee this strategy will continue to deliver positive results in the future**. **_Alpha-decay_** (the decay of an algorithmic trading performance) is a real phenomenon, and you should know about it.

**I ran the strategy across several forex pairs and indices, and each market has its own setting tailored to its market characteristics**. You cannot only rely on one pair/market and hope it will constantly print money. Each market has its own period of several consecutive losses, even though in the long run it still delivers positive results. By deploying the strategy on several markets, any consecutive loss period would be covered by profits from other markets.

One more thing, all of the strategy codes presented in this article are the simplified versions of what I am using right now. The simplifications are made to ease the understanding of the underlying logic behind the strategy.

---

## Basic Setup
The idea is simple: by picking one candle sequence pattern from the Markov Chain study, we will put a buy stop or sell stop order above or below yesterday's high or low, plus some "pending distance" to account for the possibility of price whipsaw or false break. I use buy and sell stop order as a self-confirmation. If the buy or sell stop is triggered, then I assume the price has already cleared the whipsaw/false break area and would continue to move further in the direction of our trade (**following the underlying major trend**). Furthermore, I set an order-expiration timer. If the order is not triggered within the order's lifetime window, then I assume the trend has failed to materialize, and the order has to be deleted and then move on to find the next buy or sell signal.
I only open one buy stop and one sell stop at a time (no multiple orders in the same direction). For simplicity, in this article, we use fixed lot risk management as much as 1% of the initial margin balance.

### Buy Stop Setup
For the buy position, the rules are as follows:
1. Runs on the Daily (D1) timeframe.
2. The most recent past three days have the same candle sequence as the picked pattern (in the picture below is UDU, meaning Up-Down-Up days)
3. Find yesterday's high.
4. Add the pending distance in points to yesterday's high. This is our entry (buy stop order) price.
5. Subtract the stop loss distance in points from the entry price. This is our stop loss price.
6. Add the stop loss distance in points times the reward-to-risk ratio to our entry price. This is our take-profit price.
7. Set an expiration timer in hours for the order.

![](./buy-stop-example.png)


### Sell Stop Setup
For the sell position, the rules are as follows (reverse of the buy stop rules):
1. Runs on the Daily (D1) timeframe.
2. The most recent past three days have the same candle sequence as the picked pattern (in the picture below is UDD, meaning Up-Down-Down days)
3. Find yesterday's low.
4. Subtract the pending distance in points from yesterday's low. This is our entry (sell stop order) price.
5. Add the stop loss distance in points to the entry price. This is our stop loss price.
6. Subtract the stop loss distance in points times the reward-to-risk ratio from our entry price. This is our take-profit price.
7. Set an expiration timer in hours for the order.

![](./sell-stop-example.png)

---

## MQL5 Code

## Parameters Optimization
There are 5 parameters to be set and optimized for each market. They are:
1. Candle Sequence Pattern: (UUU, UUD, UDU, UDD, etc..),
2. Pending (liquidity) distance in points,
3. Stop loss distance in points,
4. Reward-to-Risk ratio, and
5. Order Expiration in hours.

Parameters 1-to-4 are independently optimized for buy and sell positions, but parameter 5 is a common parameter for both buy and sell positions. It is to be optimized after the buy and sell parameters are finished from the optimization steps.
