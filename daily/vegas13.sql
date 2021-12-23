//@version=4

strategy("Vegas13", overlay=true,pyramiding = 20)
//-------------------------------------------
//-------------------------------------------
// Inputs
useCurrentRes = input(true, title="Use Current Chart Resolution?")
resCustom = input(title="Use Different Timeframe? Uncheck Box Above", type=input.resolution, defval="D")
//tfSet = input(title = "Time Frame", options=["Current","120", "240", "D", "W"], defval="D")
tfSet = useCurrentRes ? timeframe.period : resCustom
maPeriods2 = input(12, "12 EMA")
maPeriods6 = input(240, "240 SMA")
BBlength = input(21, title="BB Length", minval=1)
BBsrc = input(close, title="BB Source")
mult = input(2.0, minval=0.001, maxval=50, title="BB StdDev")
sm2 = security(syminfo.tickerid, tfSet, ema(close, maPeriods2))
sm6 = security(syminfo.tickerid, tfSet, sma(close, maPeriods6))
p2 = plot(sm2, color=color.red, transp=30,  linewidth=1, title="SMA2")
p6 = plot(sm6, color=color.white, transp=30,  linewidth=2, title="SMA6")
//BB
basis = sma(BBsrc, BBlength)
dev = mult * stdev(BBsrc, BBlength)
upper = basis + dev
lower = basis - dev
offset = input(0, "BB Offset", type = input.integer, minval = -500, maxval = 500)
//plot(basis, "Basis", color=color.blue,linewidth, offset = offset)
//pBB1 = plot(upper, "Upper", color=color.blue, offset = offset)
//pBB2= plot(lower, "Lower", color=color.blue, offset = offset)

//MACD
fast_ma = ema(close, 48)
slow_ma = ema(close, 56)
macd = fast_ma - slow_ma

//vagas隧道
f0=ema(close,maPeriods2)
f1=ema(close, 36)
f2=ema(close, 43)
f3=ema(close, 144)
f4=ema(close, 169)
f5=ema(close, 576)
f6=ema(close, 676)
f7=ema(close,2304)
z1=plot(f1,color=color.green, title="ema36", linewidth=2,transp=0 )
z2=plot(f2,color=color.red, title="ema43", linewidth=2,transp=0)
z3=plot(f3,color=color.green, title="ema144", linewidth=2,transp=0)
z4=plot(f4,color=color.red, title="ema169", linewidth=2,transp=0)
z5=plot(f5,color=color.green, title="ema576", linewidth=2,transp=0)
z6=plot(f6,color=color.red, title="ema676", linewidth=2,transp=0)
fill(z1, z2, color=color.green,transp=50)
fill(z3, z4, color=color.red,transp=50)
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

//波段多变盘点
if (inDateRange and crossover(f0,f6)  )// 
    strategy.entry("buy", strategy.long,1,  comment = "多b")
buyclose=crossunder(f0,f2) or crossunder(f0,f4) or crossunder(f0,f6)
strategy.close("buy", when = buyclose, comment = "关多b")

//波段空变盘点
if (inDateRange and  crossunder(f0,f6)  ) // 
    strategy.entry("sell", strategy.short,1, comment = "空b")
sellclose= crossover(f0,f2) or    crossover(f0,f4)  or crossover(f0,f6)
strategy.close("sell", when = sellclose, comment = "关空b")


//多策略1
if (inDateRange and  ( crossover(close,f1) or crossover(close,f3) or crossover(f2,f3) or crossover(f0,f1)) and f0>f1   and f2>f3  and f4>f5  )
    strategy.entry("buy1", strategy.long,1, comment = "多a")
buyclose1=crossunder(f0,f2) or crossunder(f0,f4) 
strategy.close("buy1", when = buyclose1, comment = "关多a")


//空策略1
if (inDateRange and ( crossunder(close,f1)  ) and f1<f2  and f2<f3  and f4<f5) 
    strategy.entry("sell2", strategy.short,1, comment = "空a")
sellclose2=crossover(f0,f2) or    crossover(f0,f4)
strategy.close("sell2", when = sellclose2, comment = "关空a")

