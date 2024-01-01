//@version=4

study("ultimate scalping startegy", overlay=true)

src = close
len = input(15)

Length = timeframe.isintraday and timeframe.multiplier >= 1 ? 
   len / timeframe.multiplier * 7 : 
   timeframe.isintraday and timeframe.multiplier < 60 ? 
   60 / timeframe.multiplier * 24 * 7 : 7

change_1 = change(src)
nv = change(src) > 0 ? volume : change_1 < 0 ? -volume : 0 * volume
cnv = cum(nv)
cnv_tb = cnv - sma(cnv, Length)

// Conditions

longCond = bool(na)
shortCond = bool(na)
longCond := crossover(cnv_tb, 0)
shortCond := crossunder(cnv_tb, 0)

// Count your long short conditions for more control with Pyramiding

sectionLongs = 0
sectionLongs := nz(sectionLongs[1])
sectionShorts = 0
sectionShorts := nz(sectionShorts[1])

if longCond
    sectionLongs := sectionLongs + 1
    sectionShorts := 0
    sectionShorts

if shortCond
    sectionLongs := 0
    sectionShorts := sectionShorts + 1
    sectionShorts

// Pyramiding

pyrl = 1


// These check to see your signal and cross references it against the pyramiding settings above

longCondition = longCond and sectionLongs <= pyrl
shortCondition = shortCond and sectionShorts <= pyrl

// Get the price of the last opened long or short

last_open_longCondition = float(na)
last_open_shortCondition = float(na)
last_open_longCondition := longCondition ? open : nz(last_open_longCondition[1])
last_open_shortCondition := shortCondition ? open : nz(last_open_shortCondition[1])

// Check if your last postion was a long or a short

last_longCondition = float(na)
last_shortCondition = float(na)
last_longCondition := longCondition ? time : nz(last_longCondition[1])
last_shortCondition := shortCondition ? time : nz(last_shortCondition[1])

in_longCondition = last_longCondition > last_shortCondition
in_shortCondition = last_shortCondition > last_longCondition

// Take profit

isTPl = input(true, "Take Profit Long")
isTPs = input(true, "Take Profit Short")
tp = input(0.15, "Take Profit ", type=input.float)
long_tp = isTPl and crossover(high, (1 + tp / 100) * last_open_longCondition) and 
   longCondition == 0 and in_longCondition == 1
short_tp = isTPs and crossunder(low, (1 - tp / 100) * last_open_shortCondition) and 
   shortCondition == 0 and in_shortCondition == 1


// Create a single close for all the different closing conditions.

long_close = long_tp ? 1 : 0
short_close = short_tp ? 1 : 0

// Get the time of the last close

last_long_close = float(na)
last_short_close = float(na)
last_long_close := long_close ? time : nz(last_long_close[1])
last_short_close := short_close ? time : nz(last_short_close[1])


// Alerts & Signals

bton(b) =>
    b ? 1 : 0
plotshape(longCondition, title="BUY Signal", text="Buy", style=shape.triangleup, location=location.belowbar, color=color.blue, editable=false, transp=0)
plotshape(shortCondition, title="SELL Signal", text="Sell", style=shape.triangledown, location=location.abovebar, color=color.black, editable=false, transp=0)

plotshape(long_tp and last_longCondition > nz(last_long_close[1]), text="TP", title="Take Profit Long", style=shape.triangledown, location=location.abovebar, color=color.red, editable=false, transp=0)
plotshape(short_tp and last_shortCondition > nz(last_short_close[1]), text="TP", title="Take Profit Short", style=shape.triangleup, location=location.belowbar, color=color.lime, editable=false, transp=0)

alertcondition(bton(longCondition), title="Buy Alert")
alertcondition(bton(shortCondition), title="Sell Alert")
alertcondition(bton(long_tp and last_longCondition > nz(last_long_close[1])), title="Take Profit Long")
alertcondition(bton(short_tp and last_shortCondition > nz(last_short_close[1])), title="Take Profit Short")
