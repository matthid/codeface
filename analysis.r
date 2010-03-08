# ALWAYS keep in mind that arrays in R are 1-based!!!

# Some useful functions to do time series analysis in R
# for the commit structure analysis
# NOTE: Libraries can be installed using 
# install.packages("package_name", dependencies = TRUE)

library("zoo")
library("xts")
library("tseriesChaos")
tstamp_to_date <- function(z) as.POSIXct(as.integer(z), origin="1970-01-01")
# TODO: Is there a way to load this directly as an xts series?
series = as.xts(read.zoo(file="/home/wolfgang/main.dat", FUN=tstamp_to_date))

# Set up a multiplot with (row, col) 
par(mfcol=c(3,2))

# As you would expect it to be defined: The Shannon entropy
shannon.entropy <- function(p)
{
	if (min(p) < 0 || sum(p) <= 0)
		return(NA)
	p.norm <- p[p>0]/sum(p)
	-sum(log2(p.norm)*p.norm)
}

# Do some arima fitting
fit1 <- arima(series, c(1, 0, 0))
tsdiag(fit)

# Some tests for stationarity (this one does not work, but after
# conversion to a regular time series as described below, it does)
kpss.test(as.ts(perl_all_raw))


# NOTE: The stats package contains basic statistical functions of interest,
# for example Box.test, stepfun, acf
# NOTE: The package tseries seems to contain more functions of interest
# NOTE: Ditto for tact (ta.autocorr)
# NOTE: Ditto for fNonlinear
# TODO: Apply the usual randomness checks on the generated data series

# Ignoring the time information (and just considering a uniform series)
# might make sense for some operations:
recurr(ts(as.vector(series[1:100])),m=2,d=1)

# NOTE: Proceeding through a commit series in blocks of, say, 500
# seems to be a good indicator of merge window and stabilisation cycle:
# The structure of the plot varies markedly
recurr(coredata(series)[1500:2000],m=5,d=5)

fit1 <- arima(as.vector(series), c(1, 1, 1))
tsdiag(fit1)

peng <- as.ts(series)
djj = diff(log(perl_all_raw))
dljj = djj[djj > -Inf & djj < Inf]
hist(coredata(dljj),50) # For some reasons, all diagrams are not symmetric around 0
lines(density(coredata(dljj)))
qqnorm(coredata(dljj))


# Cool plot. The question is just what it tries to tell us... I suppose
# that there is no relation between the size of the commits.
# NOTE: There does not seem to be any correlation except a negative
# one at lag 1. Which would explain the asymmetry of the distribution,
# but only from a technical aspect - where does it originate from?
# TODO: It could well be the case that this stems from the improperly
# created ts series
# NOTE: lag.plot1 will produce a nicer variant of the graphics
lag.plot(peng[0:1000], 9, do.lines=FALSE)
lag.plot(dljj, set.lags=c(1,5,10,15,20,30,40,50,100), do.lines=FALSE)

# The same thing without using regular (as opposed to logarithmic)
# differences: Patterns are similar for perl and the kernel, and only
# lag 1 drops out of the series.
ddjj = diff(all_raw); ddjj <- ddjj[ddjj > -Inf & ddjj < Inf]
lag.plot(ddjj, 9, do.lines=FALSE)

# NOTE: Also of interest is qqnorm

# Do spectral analysis
spec.ar(peng)
# NOTE NOTE NOTE!
# This is a good way of analysing the cycle phases automatically:
par(mfrow=c(2,4))
spec.ar(coredata(series)[50:2000])
spec.ar(coredata(series)[2000:4000])
spec.ar(coredata(series)[4000:6000])
spec.ar(coredata(series)[6000:8000])
spec.ar(coredata(series)[8000:10000])
spec.ar(coredata(series)[10000:12000])
spec.ar(coredata(series)[12000:14000])
spec.ar(coredata(series)[14000:16000])


# NOTE: This changes considerably depending on whether we are in the
# merge window or before a release:
spec.ar(peng[10000:15000])
spec.ar(peng[0:5000])

> summary(peng[0:5000]); summary(peng[10001:15000])
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
   0.00    4.00   13.00   23.07   34.00   99.00
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
   1.00    5.00   14.00   24.19   36.00   99.00

# NOTE: The recurrence plot of the log diff looks much more like
# classical noise the the standard recurrence plot

# Boxplots can be used to visualise the statistical morphology
# of a repository (it would be better to use overlapping ranges, and
# also to base this on a time-interval selection of ranges.)
par(mfrow=c(2,4))
blubb <- coredata(series)[0:2000]; boxplot(blubb[blubb < 100])
blubb <- coredata(series)[2000:4000]; boxplot(blubb[blubb < 100])
blubb <- coredata(series)[4000:6000]; boxplot(blubb[blubb < 100])
blubb <- coredata(series)[6000:8000]; boxplot(blubb[blubb < 100])
blubb <- coredata(series)[8000:10000]; boxplot(blubb[blubb < 100])
blubb <- coredata(series)[10000:12000]; boxplot(blubb[blubb < 100])
blubb <- coredata(series)[12000:14000]; boxplot(blubb[blubb < 100])
blubb <- coredata(series)[14000:16000]; boxplot(blubb[blubb < 100])

# Smoothing of the time series:
sd = stl(perl_all_raw,s.window=10, t.window=10)
plot(sd) # Do a seasonal decomposition

# TODO: Try StructTs for a different kind of smoothing
# TODO: Another type of smoothing is provided by tsSmooth

# What is REALLY useful for getting a first impression of the 
# structure of the data is to use the rolling mean
# (also notice that this works directly on zoo objects):
# NOTE: Would it make sense to use the average number of commits
# per day as the resampling window? This would at lest eliminate
# the arbitrary choice.
plot(rollmean(perl_all_raw, 500))
# TODO: See also rollmax and rollmedian

# Use only each 10th point to reduce the amount of data
series <- series[seq(1,length(series),10)]
sd = stl(lim,s.window=10, t.window=10)


# ... and all of a sudden, some things _do_ work...
spec.ar(unclass(lim)) 
recurr(coredata(lim),m=3,d=1)
mutual(lim)
fit1 <- arima(unclass(lim), c(1, 1, 1))
tsdiag(fit1) # This time, it seems to give more reasonable results than
             # on the raw data
# TODO: Instead of unclassing, try options(expressions = 1000)
# before spec.ar is run. Maybe this helps.

# TODO: How is it possible to "query" the smoothed irregular time
# series as regular intervals to obtain a regular time series?
Or is as.ts just sufficient beccause the number of points won't
increase so fast?

# How to generate PDF plots (see r-cookbook.com)
pdfname<-paste("myfilename",".pdf",sep="")
pdf(pdfname, height=6.4,width=6.4)
# Plotting code
dev.off()


####################################################################
# Tasks for automated analysis
# (It is easiest to let time series start at zero, and then increment
# in second steps. The positions of the tag labels can be computed
# by considering their offset to the starting date.
# This way, we would not need consider the nature of the plots
# as time series, but could just view them as regular plots, which
# might be easier to handle in matplotlib.
- Slicing into time intervals. For each, compute recurrence
  plot, density, entropy, boxplots, lag.plot1(), spec.ar()
- Also do these calculations on a per-subsystem basis
- Analyse the ECDF on a per-subsys and per-time basis
- Compare the statistical distributions generated for different 
  components (subsystems, time) with qqplot(ts1, ts2)
- Use a stem plot to visualise the subsystem activity for various
  time intervals. Define activity as the total number of changes
  per subsystem
- Perform the tests for stationarity (kpss etc.)
- Compute the distribution of commit message lengths and the number
  of people involved in the signed-off-part for each considered subpart
- Use sarima(ts, c=(b,q,p)) to produce diagnostics about an ARIMA(b,q,p)
  model fit to the data
  This must be repeated for all diff variants; if the parameters
  extracted are similar, this is a hint that the diff algorithm as such
  is not of much importance
###################################################################
- A scatter plot as in http://matplotlib.sourceforge.net/examples/pylab_examples/scatter_hist.html
  should be apt for the msg length/commit size analysis
 (TODO: Could we also use this to check the relations between the 
  different diff size approaches?)

- Correlation analysis in R (suppose columns 1,5 and 6 contain diff size,
  commit description length, and # of signed-off-lines):
small <- as.xts(read.zoo(file="/home/wolfgang/test.dat", FUN=tstamp_to_date))
corr <- data.frame(coredata(small)[,c(1,5,6)])
names(corr) <- c("Diff size", "Commit description length", "# Signed-offs")
pairs(corr, panel = panel.smooth)

###################################################################
# TASK: Transfer an irregular time series into a smoothed regular
# representation, and generate a regular, resampled time series from
# this representation
# rawts is a irregular (zoo) timeseries, smooth denotes how many
# data points are used for the rolling mean
to.regts <- function(rawts, smooth)
{
ts <- as.xts(rollmean(rawts, smooth))
ts_reduced <- as.xts(to.period(ts, "hours")[,1])
# Average difference in seconds between two data points
tstart <- unclass(index(ts_reduced[1]))
tend <- unclass(index(ts_reduced[length(ts_reduced)]))
tdiff <- floor((tend-tstart)/length(ts_reduced))
ts(data=coredata(ts_reduced), start=tstart, deltat=tdiff)
}

# ... Using this representation, tests like kpss.test, bds.test() 
# or white.test finally work as expected. WOOHOO!
##################################################################


#### PDF plotting in R
pdf(file="/tmp/test.pdf")
plot(whatever)
dev.off()