//@version=4
// v10 可以使用，v11 后开始现在删减 应用在15分钟级别
strategy("Vegas-6", overlay=true,pyramiding = 20)
//-------------------------------------------
//-------------------------------------------
// Inputs
useCurrentRes = input(true, title="Use Current Chart Resolution?")
resCustom = input(title="Use Different Timeframe? Uncheck Box Above", type=input.resolution, defval="D")
tfSet = useCurrentRes ? timeframe.period : resCustom
rate = input(1,"rate")
isNotBull= input(true,"isNotBull? true yes false no")
ticker=input(10,"10 ticker")
p0=input(21,"21 ema")
p1=input(48,"48 ema")
p11=input(56,"56 ema")
p2 =input(144,"144 ema")
p21 =input(169,"169 ema")
p3=input(576,"576 ema")
f0=ema(close,p0*rate)
f1=ema(close, p1*rate)
f11=ema(close, p11*rate)
f2=ema(close, p2*rate)
f21=ema(close, p21*rate)
f3=ema(close,p3*rate)
z1=plot(f0,color=color.blue, title="ema18",transp=0)
z2=plot(f1,color=color.green, title="ema72",transp=0)
z21=plot(f11,color=color.red, title="ema85",transp=0)
z3=plot(f2,color=color.green, title="ema144",transp=0 ,linewidth=1)
z31=plot(f21,color=color.red, title="ema169",transp=0 ,linewidth=1)
z4=plot(f3,color=color.gray, title="ema576",transp=0 ,linewidth=2)
fill(z2, z21, color=color.green,transp=70)
fill(z3, z31, color=color.red,transp=70)

BBlength = input(18, title="BB Length", minval=1)
BBsrc = input(close, title="BB Source")
mult = input(2.0, minval=0.001, maxval=50, title="BB StdDev")
basis = sma(BBsrc, BBlength)
dev = mult * stdev(BBsrc, BBlength)
upper = basis + dev
lower = basis - dev
offset = input(0, "BB Offset", type = input.integer, minval = -500, maxval = 500)
//pBB1 = plot(upper, "Upper", color=color.blue, offset = offset)
//pBB2= plot(lower, "Lower", color=color.blue, offset = offset)

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


//多策略1
if (inDateRange and  crossover(f0,f3) or  (crossover(f0,f21) and f11<=f2 and f0>=f3 )  )
    strategy.entry("buy", strategy.long,ticker, comment = "开多")
if (crossunder(close,upper*0.999)) or crossunder(f0,f11) 
    strategy.close("buy", comment = "减多" ,qty=1)    
if (inDateRange and crossover(f0,f1) and f11>f2 and f2>f21 and f0>=f3 )
    strategy.entry("buy", strategy.long,ticker, comment = "加多")
buyclose1=crossunder(f0,f2) or crossunder(f0,f21)
strategy.close("buy", when = buyclose1, comment = "关多",qty_percent=100)

//if (inDateRange and f1>f2 and (crossover(f0,f1) or crossover(f1,f2) ) )
//    strategy.entry("buy1", strategy.long,1, comment = "多")
//if (crossunder(close,upper*0.999) and isNotBull)
//    strategy.close("buy1", comment = "减" ,qty_percent=50)
//buyclose1=crossunder(f0,f1) or crossunder(f0,f2)  or crossunder(f1,f2) 
//strategy.close("buy1", when = buyclose1, comment = "关",qty_percent=100)

//空策略1
if (inDateRange and crossunder(f0,f3) or  ( crossunder(f0,f21) and f11>=f2 and f0<=f3 ) )
    strategy.entry("sell1", strategy.short,ticker, comment = "开空")
if (crossunder(lower,close)   or crossover(f0,f11))
    strategy.close("sell1", comment = "减空" ,qty=1)
if (inDateRange and crossunder(f0,f1) and f11<f2 and f2<f21 and f0<=f3 )
    strategy.entry("sell1", strategy.short,ticker, comment = "加空")
sellclose1= crossover(f0,f2) or crossover(f0,f21)
strategy.close("sell1", when = sellclose1, comment = "关空" ,qty_percent=100)

//if (inDateRange and f1<f2 and (crossunder(f0,f1) or crossunder(f1,f2)   ) ) 
//    strategy.entry("sell1", strategy.short,1, comment = "空")
//if (( crossunder(lower*0.999,close)  ) and isNotBull )
//    strategy.close("sell1", comment = "减" ,qty_percent=50)
//sellclose1= crossover(f0,f1) or crossover(f0,f2) or crossover(f1,f2) 
//strategy.close("sell1", when = sellclose1, comment = "关空" ,qty_percent=100)
