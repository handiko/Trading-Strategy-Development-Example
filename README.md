# Trading Strategy Development Example

Continuing the discussion from the previous sections, in this article, we will develop a real trading strategy inspired by the Markov Chain study results. The trading strategy presented in this article, I actually use it personally on my real trading account. There are some minor parameter differences from my personal settings, but overall, it is actually very much the same. 

## Disclaimer !!!
**I do not recommend that anybody follow my strategy, as I cannot guarantee this strategy will continue to deliver positive results in the future**. **_Alpha-decay_** (the decay of an algorithmic trading performance) is a real phenomenon, and you should know about it.

One more thing, **I ran the strategy across several forex pairs and indices, and each market has its own setting tailored to its market characteristics**. You cannot only rely on one pair/market and hope it will constantly print money. Each market has its own period of several consecutive losses, even though in the long run it still delivers positive results. By deploying the strategy on several markets, any consecutive loss period would be covered by profits from other markets.

## Basic Setup
The idea is simple: by picking one candle sequence pattern from the Markov Chain study, we will put a buy stop or sell stop order above or below yesterday's high or low, plus some "pending distance" to account for the possibility of price whipsaw or false break. I use buy and sell stop order as a self-confirmation. If the buy or sell stop is triggered, then I assume the price has already cleared the whipsaw/false break area and would continue to move further in the direction of our trade (**following the underlying major trend**). Furthermore, I set an order-expiration timer. If the order is not triggered within the order's lifetime window, then I assume the trend has failed to materialize, and the order has to be deleted and then move on to find the next buy or sell signal.
