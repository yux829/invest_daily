//@version=4

strategy("Vegas5", overlay=true,pyramiding = 20)
//-------------------------------------------
//-------------------------------------------
// Inputs
useCurrentRes = input(true, title="Use Current Chart Resolution?")
resCustom = input(title="Use Different Timeframe? Uncheck Box Above", type=input.resolution, defval="D")
//tfSet = input(title = "Time Frame", options=["Current","120", "240", "D", "W"], defval="D")
tfSet = useCurrentRes ? timeframe.period : resCustom
maPeriods2 = input(12, "12 EMA")
maPeriods6 = input(240, "240 SMA")
BBlength = input(20, title="BB Length", minval=1)
BBsrc = input(close, title="BB Source")
mult = input(2.0, minval=0.001, maxval=50, title="BB StdDev")
sm2 = security(syminfo.tickerid, tfSet, ema(close, maPeriods2))
sm6 = security(syminfo.tickerid, tfSet, sma(close, maPeriods6))
p2 = plot(sm2, color=color.green, transp=30,  linewidth=2, title="SMA2")
p6 = plot(sm6, color=color.white, transp=30,  linewidth=2, title="SMA6")
//BB
basis = sma(BBsrc, BBlength)
dev = mult * stdev(BBsrc, BBlength)
upper = basis + dev
lower = basis - dev
offset = input(0, "BB Offset", type = input.integer, minval = -500, maxval = 500)
//plot(basis, "Basis", color=color.blue,linewidth, offset = offset)
pBB1 = plot(upper, "Upper", color=color.blue, offset = offset)
pBB2= plot(lower, "Lower", color=color.blue, offset = offset)

//MACD
fast_ma = ema(close, 36)
slow_ma = ema(close, 43)
macd = fast_ma - slow_ma

//vagas隧道
f1=ema(close, 36)
f2=ema(close, 43)
f3=ema(close, 144)
f4=ema(close, 169)
f5=ema(close, 576)
f6=ema(close, 676)
f7=ema(close,2304)
z1=plot(f1,color=color.red, title="ema36",transp=100)
z2=plot(f2,color=color.red, title="ema43",transp=100)
z3=plot(f3,color=color.green, title="ema144",transp=100)
z4=plot(f4,color=color.green, title="ema169",transp=100)
z5=plot(f5,color=color.white, title="ema576",transp=100)
z6=plot(f6,color=color.white, title="ema676",transp=100)
fill(z1, z2, color=color.red,transp=50)
fill(z3, z4, color=color.green,transp=50)
fill(z5, z6, color=color.gray,transp=50)

// Make input options that configure backtest date range
startDate = input(title="Start Date", type=input.integer,
     defval=1, minval=1, maxval=31)
startMonth = input(title="Start Month", type=input.integer,
     defval=1, minval=1, maxval=12)
startYear = input(title="Start Year", type=input.integer,
     defval=2018, minval=1800, maxval=2100)
endDate = input(title="End Date", type=input.integer,
     defval=1, minval=1, maxval=31)
endMonth = input(title="End Month", type=input.integer,
     defval=11, minval=1, maxval=12)
endYear = input(title="End Year", type=input.integer,
     defval=2030, minval=1800, maxval=2100)
// Look if the close time of the current bar
// falls inside the date range
inDateRange = (time >= timestamp(syminfo.timezone, startYear,
         startMonth, startDate, 0, 0)) and
     (time < timestamp(syminfo.timezone, endYear, endMonth, endDate, 0, 0))

//波段多
if (inDateRange and crossunder(f4,f1)  )// 
    strategy.entry("buy", strategy.long,1, when=macd>0, comment = "买L1")
buyclose=crossunder(f1,f4) 
strategy.close("buy", when = buyclose, comment = "关L1")
//多策略1
if (inDateRange and crossover(low , f3) and macd>0 and f3>f6)
    strategy.entry("buy1", strategy.long,1, comment = "买M")
buyclose1=crossunder(close,upper*0.999) 
if (macd<0 or f3<f6)
    strategy.close("buy1", comment = "关M2")
//strategy.close("buy1",when=cross(basis,close), comment = "关M",qty_percent=50)
strategy.close("buy1", when = buyclose1, comment = "关M1",qty_percent=100)
//多策略3
if (inDateRange and  (macd>0) and crossunder(low,f1) and f1>f4  and f3>f6 ) // 
    strategy.entry("buy3", strategy.long,1, comment = "买S")
buyclose3=crossunder(close,upper*0.999)
if (macd<0 or f1<f4)
    strategy.close("buy3", comment = "关S2")
strategy.close("buy3", when = buyclose3, comment = "关S1")
//多策略4
if (inDateRange and  (macd>0) and crossunder(low,f5) and f4>f5) // 
    strategy.entry("buy4", strategy.long,1, comment = "买L2")
buyclose4=crossunder(close,upper*0.999)
if (macd<0 or f4<f6)
    strategy.close("buy4", comment = "关L22")
strategy.close("buy4", when = buyclose4, comment = "关L21")
    
//空策略1
if (inDateRange and  (macd<0) and crossunder(high,f1) and f1<f3 and f3<f6) // 
    strategy.entry("sell1", strategy.short,1, comment = "空S")
sellclose1=crossunder(lower*0.999,close)
if (macd>0 or f1>f4)
    strategy.close("sell1", comment = "关空S2")
strategy.close("sell1", when = sellclose1, comment = "关空S1")
//空策略2
if (inDateRange and  (macd<0) and crossunder(high,f4) and f4<f6) // 
    strategy.entry("sell2", strategy.short,1, comment = "空M")
sellclose2=crossunder(lower,close)
if (macd>0 or f4>f6)
    strategy.close("sell2", comment = "关空M2")
strategy.close("sell2", when = sellclose2, comment = "关M1")
//空策略3
if (inDateRange and (macd<0) and crossunder(high,f6)) // 
    strategy.entry("sell3", strategy.short,1, comment = "空L")
sellclose3=crossunder(lower,close)
if (macd>0 or f6>f7)
    strategy.close("sell3", comment = "关空L2")
strategy.close("sell3", when = sellclose3, comment = "关空L1")