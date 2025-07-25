*Set libraries and species to index (graph titles set to species name);
* libname sta "C:\NMFS\Main data builds\Reef Fish\Data\main\Video\Analysis_Distribution";
PROC IMPORT OUT= WORK.rfvmad_sm_sta
  DATAFILE= "../mock_data/mock_rfvmad_sm_sta.csv"
  DBMS=CSV REPLACE;
  GETNAMES=YES;
RUN;

libname viame "C:\Users\matthew.d.campbell\Desktop\Active\GFISHER\FY24\VIAME index";

*******************************************************************************************************
*Bring in data and modify as needed for specified model runs
*******************************************************************************************************;
data stations19_22;
* set sta.rfvmad_sm_sta;
set WORK.rfvmad_sm_sta;
if year = 2019 or year = 2021 or year = 2022;
keep stationkey survey year region sta_time sta_lat sta_lon xmiss xmiss_sur region blk reefname sta_dpth LUTJANUS_CAMPECHANUS SERIOLA_DUMERILI;
proc sort; by stationkey; run;
run;

PROC IMPORT OUT= WORK.viame_full 
            DATAFILE= "../mock_data/mock_combined_species_Master.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data viame_MSfull;
set viame_full;
if stationkey ne '####################';
stationkey = '00000000000'||substr(station,1,9);
if SumTot gt 0;
if Lab = 'MSL';
run;

data viame_MSsdum;
set viame_MSfull;
if species = 'S_dume';
rename m24s_c10=S_dume10;
rename m24s_c20=S_dume20;
rename m24s_c30=S_dume30;
rename m24s_c40=S_dume40;
rename m24s_c50=S_dume50;
rename m24s_c60=S_dume60;
rename m24s_c70=S_dume70;
rename m24s_c80=S_dume80;
rename m24s_c90=S_dume90;
rename m24s_c95=S_dume95;
drop SumTot station;
proc sort; by stationkey;
run;

data sdum_MS0;
merge stations19_22 viame_MSsdum;
by stationkey;
if Lab = '' then Lab = 'MS';
if Rtracks24s = '.' then Rtracks24s = 0;
if species = '' then species = 'S_dum';
if S_dume10 = '' then S_dume10 = 0;
if S_dume20 = '' then S_dume20 = 0;
if S_dume30 = '' then S_dume30 = 0;
if S_dume40 = '' then S_dume40 = 0;
if S_dume50 = '' then S_dume50 = 0;
if S_dume60 = '' then S_dume60 = 0;
if S_dume70 = '' then S_dume70 = 0;
if S_dume80 = '' then S_dume80 = 0;
if S_dume90 = '' then S_dume90 = 0;
if S_dume95 = '' then S_dume95 = 0;
run;

data sdum_MS5;
set sdum_MS0;
if S_dume10 = '5' then S_dume10 = SERIOLA_DUMERILI;
if S_dume20 = '5' then S_dume20 = SERIOLA_DUMERILI;
if S_dume30 = '5' then S_dume30 = SERIOLA_DUMERILI;
if S_dume40 = '5' then S_dume40 = SERIOLA_DUMERILI;
if S_dume50 = '5' then S_dume50 = SERIOLA_DUMERILI;
if S_dume60 = '5' then S_dume60 = SERIOLA_DUMERILI;
if S_dume70 = '5' then S_dume70 = SERIOLA_DUMERILI;
if S_dume80 = '5' then S_dume80 = SERIOLA_DUMERILI;
if S_dume90 = '5' then S_dume90 = SERIOLA_DUMERILI;
if S_dume95 = '5' then S_dume95 = SERIOLA_DUMERILI;
run;

data sdum_MS10;
set sdum_MS0;
if S_dume10 = '10' then S_dume10 = SERIOLA_DUMERILI;
if S_dume20 = '10' then S_dume20 = SERIOLA_DUMERILI;
if S_dume30 = '10' then S_dume30 = SERIOLA_DUMERILI;
if S_dume40 = '10' then S_dume40 = SERIOLA_DUMERILI;
if S_dume50 = '10' then S_dume50 = SERIOLA_DUMERILI;
if S_dume60 = '10' then S_dume60 = SERIOLA_DUMERILI;
if S_dume70 = '10' then S_dume70 = SERIOLA_DUMERILI;
if S_dume80 = '10' then S_dume80 = SERIOLA_DUMERILI;
if S_dume90 = '10' then S_dume90 = SERIOLA_DUMERILI;
if S_dume95 = '10' then S_dume95 = SERIOLA_DUMERILI;
run;

data sdum_MS15;
set sdum_MS0;
if S_dume10 = '15' then S_dume10 = SERIOLA_DUMERILI;
if S_dume20 = '15' then S_dume20 = SERIOLA_DUMERILI;
if S_dume30 = '15' then S_dume30 = SERIOLA_DUMERILI;
if S_dume40 = '15' then S_dume40 = SERIOLA_DUMERILI;
if S_dume50 = '15' then S_dume50 = SERIOLA_DUMERILI;
if S_dume60 = '15' then S_dume60 = SERIOLA_DUMERILI;
if S_dume70 = '15' then S_dume70 = SERIOLA_DUMERILI;
if S_dume80 = '15' then S_dume80 = SERIOLA_DUMERILI;
if S_dume90 = '15' then S_dume90 = SERIOLA_DUMERILI;
if S_dume95 = '15' then S_dume95 = SERIOLA_DUMERILI;
run;

*******************************************************************************************************
*Index work
*******************************************************************************************************;

****************************************************************************************
Relative Abundance Index Code - M. Campbell - 30 April 2020

*------------------------------------------------------------------------------------------------------------------------------------------------
Combined the original Delta Log-Normal model code from Lo with the code developed by Mary Christman for Poisson and Negative Binomial model fits.
Code produces three model fits using Delta Log-Normal, Poison and Negative Binomial error distributions
Parameters are set using global parameters (%LET variable = variable) set in the first few lines of code.
Because of the different model formulation between DLN and the Poisson and NB models, two sets have to be initialized


*------------------------------------------------------------------------------------------------------------------------------------------------
Delta Log-Normal code did not come with any documentation

*------------------------------------------------------------------------------------------------------------------------------------------------
Original documentation from M. Christman for the Poissona and Negative Binomial Models
SAS code for fitting GLMMs to non-normal data and then checking the residuals against the assumed distribution in a QQ plot. 
Uses Method 1 of Augustin et al. (2012).

Model: 	generalized linear mixed model with fixed and random effects

		Let 	DATASET = input data set used in the analyses
Y = response, 
X1, �, Xp = set of explanatory fixed effects variables, 
			Z1, �, Zt = set of random effects variables
			DIST = distribution assumed (Poi or Negbin in this example code) conditional on
  the random effects
			LINK = link function chosen for the distribution
			predM = marginal predicted values (the BLUES in statistical parlance)
			predS = conditional predicted values (the BLUPS in statistical parlance)
			residM = marginal raw residual (= Y - predM)
			residS = conditional raw residual (= Y � predS)

NOTES:		if the model has no random effects use predM for the QQ plot, else if there are
random effects use predS
			


EXAMPLE1: Y ~ Poi, 1 fixed categorical effect X1=year, one random effect Z1=array 
	   Count data (Y) were collected annually at a set of fixed locations (array sites)


In the Poisson model you must insert the sample size into PPREDS1 and PPREDS3
In the Negative Binomial you must insert the sample size into NBPREDS1 and NBPREDS3, as well as the scale parameter

*-----------------------------------------------------------------------------------------------------------------------------------------------;

%LET species = SERIOLA_DUMERILI;

*Set graph title name;
%LET Title1 = "Greater Amberjack";

*Pull data from 'Oracle Video' master build (M.Campbell)
*Reef Fish Video Mincount (RFVM)- SEAMAP (SM) - Station Flatfile (STA);
data a;
set sdum_MS15;
*mincount = &species;
mincount = S_dume70;
run;

data poscatch;
set a;
*if &species gt 0;
if S_Dume70 gt 0;
run;

/*proc univariate data = poscatch;
histogram mincount  /normal
                     ctext     = blue;
RUN;
*/

data outliers;
set a;
if &species ge 15;
diff = SERIOLA_DUMERILI-mincount;
run;
proc univariate data=outliers noprint;
   histogram diff ;
run;

PROC EXPORT DATA= outliers 
            OUTFILE= "../test_outputs/original_code/SD Diff Out 2.xlsx" 
            DBMS=EXCEL LABEL REPLACE;
     SHEET="rfvm_comp"; 
RUN;

*Corrections, additions and data fills from backup data feeds (e.g. depth);
*Common deletions due to data limited years, poorly represented strata, and videos with visibility issues;
data a2;
set a;
*In case we need to ditch outliers etc;
run;

proc contents data=a2;
run;

*-----------------------------------------------------------------------------------------------------------------------------------------------
Model parameterization;

*Abiotic Variables: year season zone region sta_lat sta_lon stratum blk blkyr reef depth temp fluoro xmiss oxy_mg salinity;
*Habitat Variables: siltsandclay shellgravel rock attached_epifauna sponge algae hardcoral softcoral seawhips relief_maximum relief_average;
*Standardized Variables: DPTH SSCLAY SHGRAV RCK SPGE ALG HCOR SCOR SWHIP MREL AREL;

*Set binomial and poisson class variables and model parameterization;
%let factorsclass= year;
%let modelpars= year; 

*Set DLN binomial and continuous model parameters;
%let factorsb=  ;*(1) Select the fixed factors for the binomial proportion positives;
%let factorsbcon=  year   ; 
%let factorsc=  ; *(2) Select the fixed factors for the positive mincounts GLM model;
%let factorsccon= year  ; 

%let yrstart=2019;                        *(5)  Select year start and end (Assuming that year in data is 2 digits);
%let   yrend=2022;                        *(if NOT, need to change these to 4 digits and also in a do loop (5);

*Final data set settings;
data dataset;
set a2;
*if region = 'E';
*if region = 'W';
count=mincount+0;
run;

*Modify file name to reflect model runs and variables;
*ods rtf file="C:\Users\matthew.d.campbell\Desktop\Active\GFISHER\FY24\VIAME index\Output\VIAMEcomp_sdum yr sd70_15.rtf";
ods rtf file="../test_outputs/original_code/VIAMEcomp_sdum yr sd70_15.rtf";

*******************************************************************************************************************
*******************************************************************************************************************
Start Poisson Model
*******************************************************************************************************************
******************************************************************************************************************;

* Reset sample size to correctly plot qq residuals for Poisson and NB models;
%let sampsize = 1646;

title &Title1;
title2 MinCounts ~ Poisson;
proc glimmix data=dataset method=laplace plots=(studentpanel pearsonpanel); * ABSPCONV=0.000001 method=laplace;
 nloptions maxiter=100;
 class &factorsclass  ;
 model mincount = &modelpars / dist=Poi link=log ddfm=bw;
 random intercept; /*/subject = blkyr;blk*/
 lsmeans year /ilink plot=meanplot(ilink CL join) adjust=tukey;
 output out=Ppreds pred(ilink noblup)=predM stderr(ilink noblup)=SEPM pred(ilink)=predS stderr(ilink)=SEPS
        resid(ilink)=residS student(ilink)=sturesS pearson(ilink)=PearresS;
quit;

* calculate observed and predicted means for plotting;
data Ppreds;
 set Ppreds;
 PA = mincount>0;
run;

proc sort data=Ppreds; by year;
title &Title1 ;
title2 Mincounts (Observed and Predicted) ~ Poisson;
proc means data=Ppreds n mean std stderr cv;
 by year;
 var PA mincount predM predS;
 output out=meansP mean= PA mincount predM predS cv= PAcv mincountCV predMcv predScv;
quit;

/*
PROC EXPORT DATA=meansP 
            OUTFILE ="C:\NMFS\Mississippi Lab Projects\Index\Gray snapper\Output\Runs\meansP yr reef.xlsx"
            DBMS=EXCEL 
            REPLACE; 
            SHEET=REPORT; 
RUN; 
*/

legend1 label=none
        position=(top right inside)
        mode=share;
symbol interpol=join value=dot;
title &Title1 ;
title2 Mean MinCounts (Observed and Predicted) ~ Poisson;
proc gplot data=meansP;
 plot mincount*year predM*year predS*year / overlay legend=legend1;
run;
quit;

*standardize the residual to same mean and variance (i.e. construct a z-score);
data Ppreds1;
 set Ppreds;
 loc = compress(year||blk);
 resid = residS/sqrt(predS);
run;

*calculate its quantile in the sample; 
proc sort data=ppreds1; by resid; quit;
data ppreds1;
 set ppreds1;
 ind+1;
 qresid = (ind)/&&sampsize;
run;

* simulate 50 obs for each sample from the distribution identified by the model and predicted value;
data preds2;
 set Ppreds1;
 do recnum= 0 to 50;
 if recnum = 0 then newresid = resid;
 else newresid = (rand('POISSON', predS) - predS)/sqrt(predS); 
 output;
 end;
run;

proc sort data=preds2;
 by newresid;
quit;

* calculate the expected quantile of the resid from the simulated distribution;
data Preds3;
 set Preds2;
 newind + 1;
 qnewresid = (newind)/(51*&&sampsize); 
 if recnum = 0 then output;
run;

axis1 length=50 order=0 to 1 by 0.1; *to get a square plot;
title &Title1 ; 
title2 Q-Q Plot of Conditional Residuals ~ Poisson;
proc gplot data=preds3;
 plot qresid*qnewresid / haxis=axis1 vaxis=0 to 1 by 0.1;
run;
quit;


/***************************/
/***************************/
/********* Neg Bin *********/
/***************************/
/***************************/

title &Title1;
title2 Mincounts~ NegBin;
proc glimmix data=dataset method=laplace plots=(pearsonpanel); 
 nloptions maxiter=100;
 class &factorsclass  ;
 model mincount = &modelpars / dist=negbin ddfm=bw s;
 random intercept ;/*/ subject = blkyr;blk*/
 covtest zerog;
 lsmeans year /ilink CL plot=meanplot(ilink CL join) adjust=tukey;
 output out=NBpreds pred(ilink noblup)=predM stderr(ilink noblup)=SEPM pred(ilink)=predS stderr(ilink)=SEPS
                    resid(ilink)=residS student(ilink)=sturesS pearson(ilink)=PearresS;
quit;

data NBpreds;
 set NBpreds;
 PA = mincount>0;
run;

proc sort data=NBpreds; by year;
title &Title1 ;
title2 Mean Counts (Observed and Predicted)~ Neg Bin;
proc means data=NBpreds n mean std stderr cv;
 by year;
 var PA mincount predM predS;
 output out=meansNB mean= PA mincount predM predS cv= PAcv mincountCV predMcv predScv;
quit;

/*
PROC EXPORT DATA=meansNB 
            OUTFILE ="C:\NMFS\Mississippi Lab Projects\Index\Gray snapper\Output\Runs\meansNB yr reef.xlsx"
            DBMS=EXCEL 
            REPLACE; 
            SHEET=REPORT; 
RUN; 
*/

legend1 label=none
        position=(top right inside)
        mode=share;
symbol interpol=join value=dot;
title &Title1 ;
title2 Mean Mincounts (Observed and Predicted) ~ Neg Bin;
proc gplot data=meansNB;
 plot mincount*year predM*year predS*year / overlay legend=legend1;
run;
quit;

data NBpreds1;
 set NBpreds;
 resid = residS; 
run;

proc sort data=NBpreds1; by resid; quit;
data NBpreds1;
 set NBpreds1;
 ind+1;
 qresid = (ind)/&&sampsize;
run;

data NBpreds2;
 set NBpreds1;
 r = 1/0.11630; * scale in the neg bin model output;
 p = 1/(1+ preds*0.1163);
 do recnum=0 to 50;
 Y_NB = rand('NEGBINOMIAL',p,r);
 if recnum = 0 then newresid = resid;
 else newresid = (Y_NB - predS);  
 output;
 end;
run;

proc sort data=NBpreds2;
 by newresid;
quit;

data NBpreds3;
 set NBpreds2;
 newind + 1;
 qnewresid = (newind)/(51*&&sampsize); 
 if recnum = 0 then output;
run;

axis1 length = 50 order=0 to 1 by 0.1;
title &Title1 ; 
title2 Q-Q Plot of Conditional Residuals ~ Neg Bin;
proc gplot data=NBpreds3;
 plot qresid*qnewresid / haxis=axis1 vaxis=0 to 1 by 0.1;
run;
quit;

/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/
/* Delta log normal model****************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/

*%include 'C:\NMFS\Index\Index code\Macro\glmm800Mao.sas';
%include 'glmm800Mao.sas';
options pagesize=5000;
options linesize=90;

*===================================================================================================;
 
options pagesize=5000;
options linesize=90;

/*
proc sort data=gag.Sedarupdate2009gag2; run;
proc means data=gag.Sedarupdate2009gag2 (where=(region='E')) mean;
var st_depth;output out=depth1 mean=mndepth;run;*/

data ANALYSIS;
set dataset;
if (&yrstart <= year <= &yrend); 

* Definitions of catch/effort dependent variable;
if mincount gt 0 then lgmincount = log(mincount);
if mincount > 0 then success = 1; else success = 0;

*definition of an ID column for matching the predicted positive values;
idvar = _n_;
depthscale=depth ;

run;

proc sort data=ANALYSIS;
  by &factorsb ; run;                                                  *(1);
proc univariate noprint data=ANALYSIS;
    var success;
    by &factorsb ;                                             *(1);
   output out=pposM nmiss=zero sum=cellpos n=total;
run;   
data pposM (drop=cellpos) ;
    set pposM;
    by &factorsb ;                                             *(1);
     if cellpos=. then cellpos=0;
        total=total+zero;
        positv=cellpos;
     if(total > 0) then
        percpos=positv/total;
run;
data POSIT ;
 set ANALYSIS;
  where mincount  > 0 ;
run;
proc sort data=posit; by year; run;
proc summary data=analysis;
  var mincount success ;
  by year;
  output out=Obsmincount mean=obmincount obppos n=nobs;
  run;
proc summary data=posit;
  var mincount;
  by year;
  output out=obcppos mean=obcppos n=ncppos;
run;
data obcppos; set obcppos;
 keep year obcppos ncppos;
run;
data Obsmincount; merge Obsmincount Obcppos; 
by year;
run;

Title &title1;
goptions ftext=SWISSI ctext=BLACK htext=1.4 cells;
Title &title1;
axis1 width=2 offset=(3 pct) label=(a=90 r=0);
axis2 width=2 offset=(3 pct);
symbol1 c=BLUE ci=BLUE v=DIAMOND height=2 cells
        interpol=JOIN l=1 w=2;
proc gplot data=obsmincount ;
  title2 "Delta Log-Normal: Nominal mincount by year";
   plot OBmincount * YEAR  /;
run;
proc gplot data=obsmincount ;
  title2 "Observed proportion pos/total by year";
   plot OBPPOS * YEAR / ;
  footnote "If prop pos=[1 or 0] Binomial model will not estimate a value for that year! ";
run;
footnote ;
title2 "Frequency distribution log mincount positive catches";
proc univariate data=Posit noprint;
   var LGmincount;
   histogram / caxes=BLACK cframe=CXFFFFFF waxis= 2
               cbarline=CX000080 cfill=CX00FFFF pfill=SOLID
               vscale=percent hminor=0 vminor=2 name='HIST'
               normal( mu=est sigma=est w=2 color=RED ) ;
   inset normal(mu sigma) ;
run;
proc univariate data=Pposm noprint;
title2 "Frequency distribution proportion positive catches summary by &factorsb";
   var percpos;
   histogram / caxes=BLACK cframe=CXFFFFFF waxis= 2
               cbarline=CX000080 cfill=CX00FFFF pfill=SOLID
               vscale=percent hminor=0 vminor=2 name='HIST';
run;
symbol;
goptions ftext= ctext= htext=;

proc summary data=pposm print;
 var percpos;
 class year;
 output out=pposyr mean=pposyr;
run;
data pposyr;
  set pposyr;
  where year > 0;
  rename _Freq_ = ntrips;

  drop _type_;
  if (pposyr = 0 or pposyr =1) then do;


   put 'ERROR:THE FOLLOWING YEAR(S) HAVE PROPORTION POSITIVE EQUAL ZERO (0) OR ONE (1)';
   put '     THE BINOMIAL ESTIMATION WILL NOT GENEREATE AN ESTIMATE (Zero variance!)';
   put '     NEED to make sure that proportion by year be a 0 > PPOS < 1';
   put '     If not, the program will no estimate an Index for this year'
      / @3 year= pposyr= /;
 end;
run;

data test;
  set pposm;
  by year;
  if first.year then highest=.;
  retain highest;
  highest=max(highest,total);
  if last.year then output;
  keep year highest;

run;

data pposm;
 merge test pposm pposyr;
 by year;
run;

data pposm; set pposm;
 n=0;
 if (pposyr = 1.0 and total=highest) then do while (n=0) ;
  positv = positv - 1; n=1; end ;
 else if (pposyr = 0.0 and total=highest) then do while (n=0) ;
  positv = positv + 1; n=1; end;
 percpos = positv/total;
 run;

proc summary data=pposm print;
 var percpos;
 class year;
run;

data pposm;
 set pposm;
 drop highest;
run;


*------------------------------------------------------------;
Title2 'GLIMMIX binomial on proportion of positive';
*------------------------------------------------------------;
        /* Binomial estimation of proportion of positive values,
          using a SAS macro GLIMMIX (Wolfinger) from SAS sample library
          includes interactions effects up to level 2 */
                                                                 *(1)  (3) ;
%glimmix(data=analysis, procopt=ic info , maxit=500,
   stmts=%str(
    class &factorsb ;
    model success = &factorsb &factorsbcon / ddfm=kr chisq cl ;
	
	*repeated /group=year;
	lsmeans year / alpha=0.05 cl ;
    ),
	/*weight=&weight,*/
    error=binomial, link=logit,
    options=mixprintlast, out=prepps
     )
run;/*   random blockno(stratum)/solution;*/
data pposm; 
merge pposm prepps;
by &factorsb; run;

data ESTRAWf (drop=year);                      /* Estimates of proportion of positives */
 set _LSM;
   attrib yr length=8;
   yr=year;
   lpos=estimate; selpos=stderr;  *LSMean for @ year and SE in linear predictor units !;
   ppos=mu; 					  *LSMean for @ year and SE in binomial proportion units [0-1] !;
   mp=df;
   MFO=mu;CVMFO=stderrmu/MFO;LCLMFO=lowermu;UCLMFO=uppermu;
run;

data ModFreqOcc;set ESTRAWf;
year=yr;
keep year MFO CVMFO LCLMFO UCLMFO;
run;

data ESTRAWf (drop=yr); set ESTRAWf;
   year=yr;
run;

data _null_;					* Collect the estimated Variance for the Prop positive submodel overall;
 set _cov; where CovParm = 'Residual';
   call symput('CovPar',estimate);
run;
data itpos;
   do year=&yrstart to &yrend;
     pos_var=symget('CovPar')*1;
	 output;
   end;
   keep year pos_var ;
run;

 
*-----------------------------------------------------------------------------------------------------;
*  USING PROC MIXED TO ALLOW FOR RANDOM EFFECTS With lognormal analysis of the positive catch rates   ;
*-----------------------------------------------------------------------------------------------------;
Title2 'GLM on positive catches';

                                        /*  Changes for model specification of positive values*/
Proc MIXED data=POSIT info IC CL Covtest	;
 CLASS &factorsc ;                                             *(2);
 MODEL lgmincount = &factorsc  &factorsccon
    /SOLUTION cl outPM=posit ;
 
 
 LSMEANS year     /CL OBSMARGINS=posit;
 /*weight &weight;*/
 ODS output covparms=itcpu1 lsmeans=estrawp;
RUN;/*   st_depth  repeated /group=year;  random blockno(stratum)/solution;*/
DATA COVmincount;
 SET  estrawp;
run;
DATA ESTRAWp;                     /* Estimates of density values*/
     SET ESTRAWp;
      mincount=exp(estimate+stderr**2/2); * convert lgmincount to mincount units ;
      lcpu=estimate; selcpu=stderr;  *LSMean for @ year and SE in linear predictor units !;
       mc =df;
      yr=year;
	  margPos = margins;
      keep yr lcpu selcpu mincount mc margpos;
RUN;
DATA ESTRAWP;
  set estrawp;
   year=yr*1.0;
   drop yr;
run;
TITLE2 'Correlation Analysis';
 data ESTIM;
     merge ESTRAWp ESTRAWf;
     by year;
 proc corr outp=c1;    *Using Pearson's Correlation coefficient based on ranks as the 2 distributions -are not Normal!-  **Used to be Kendall's;
     var ppos mincount;
     run;
 proc print data=c1;
     run;
 data c1; set c1; if(_TYPE_='CORR' and _NAME_='ppos');
      cor=mincount;
      if(cor<1.);
      keep year cor;
      do year=&yrstart to &yrend; *this is year specific change to match years;
	   cor=cor;
	  *cor=ABS(cor);
       output; end;run;
 data ESTIM; merge ESTIM c1;by year; run;


/*******Modified due to model change**********/
data itcpu; set itcpu1; if(COVPARM='Residual');
     mse=Estimate;
     do year=&yrstart to &yrend;
       cpu_var=mse;
       output;
     end;
     KEEP year cpu_var;
     run;

/**********************************************/


title2 'Compute Index Values using Lo Method for the GLM positives';
data ESTIM;
   merge ESTIM itcpu itpos obsmincount;
   by year;
       JOIN=1;
   drop _freq_ _type_; 
run;
/* FEB2000 modifications to Lo's algoritm: -reset some variables to zero for each year
new do loop.  use the variable pr(gc/gd) for prior gc/gd values instead of the lag1() function
which generates and invalid (.) value for the first year always. Mao00  */

data ESTIM;
 set ESTIM;
    by year;
  c_var=selcpu**2;
* compute log transform bias correction for mincount;
   tc=(cpu_var-c_var)*(mc+1)/(2*mc);
   td=(cpu_var-2*c_var)*(mc+1)/(mc);
     gc=0; gd=0; d=1;

   do pi=0 to 50;
    p=pi; if (p=0) then do; gc = 0; gd = 0; d=1; end;
    d=(mc+2*p)*d;
    a=(mc**p)*(mc+2*p);
    b=(mc/(mc+1))**p;
    c=GAMMA(p+1);
    cc=(tc**p)/c;
    cd=(td**p)/c;
    prgc=gc; prgd=gd;
    gc= gc + (a/d)*b*cc;
    gd= gd + (a/d)*b*cd;
    cverge=p;
    if(p>2) then do; tol=gc-prgc; tol2=gd-prgd;
    if(ABS(tol)<0.0000001 and ABS(tol2)<0.0000001) then GO TO Next;
    end;
   end;
 Next:
   var_c=exp(2*lcpu)*(gc**2-gd);

/* This comments out the bias correction of proportion positives (GLM log)
  * compute log transform bias correction for ppos (modified Jul 2003 Mao);

	p_var=selpos**2;
* compute log transform bias correction for proportion positives (if using a lognormal model);
	tp=(pos_var-p_var)*(mp+1)/(2*mp);
    tq=(pos_var-2*p_var)*(mp+1)/(mp);
     gp=0; gq=0; d=1;

   do pi=0 to 50;
    p=pi; if (p=0) then do; gp = 0; gq = 0; d=1; end;
    d=(mp+2*p)*d;
    a=(mp**p)*(mp+2*p);
    b=(mp/(mp+1))**p;
	c=GAMMA(p+1);
    cp=(tp**p)/c;
    cq=(tq**p)/c;
	prgp=gp; prgq=gq;
    gp= gp + (a/d)*b*cp;
    gq= gq + (a/d)*b*cq;
    pverge=p;
    if(p>2) then do; tol=gp-prgp; tol2=gq-prgq;
    if(ABS(tol)<0.0000001 and ABS(tol2)<0.0000001) then GO TO Nnext;
    end;
   end;
 Nnext:
     var_p=(exp(2*lpos))*(gp**2-gq);     */

   *If the prop pos is log-normal model it need to comment out this line and activate prior section!;                  

	 var_p= stderrmu**2  ;  * Variance of Proportion positive year lsmean is taken as (SE^)**2 by model  ; 
 
   * compute Lo index and variance of Index;

     index=ppos*((exp(lcpu))*gc);
     bc_pos=ppos; bc_cpu=(exp(lcpu))*gc;

	* Old code.  
	*var_i=var_p*((exp(lcpu))*gc)**2 +
	var_c*ppos**2 +
	cor*(SQRT(var_p)*SQRT(var_c));

	* New code.  Adam Pollack 23-April-2013;
	var_i=var_p*(((exp(lcpu))*gc )**2)+((var_c)*ppos**2) +cor*(SQRT(var_p)*SQRT(var_c))*(2*((exp(lcpu))*gc)*ppos);

se_i=SQRT(var_i);
     cv_i=SQRT(var_i)/index;

output;
run;
title &title1;
title2 'ESTIM Data File';
proc print data=estim noobs;

title &title1;
title2 'Chisq Residuals proportion positive';
goptions ftext=SWISSI ctext=BLACK htext=1.4 cells;
axis1 width=2 offset=(3 pct) label=(a=90 r=0);
axis2 width=2 offset=(3 pct);
symbol1 c=BLUE ci=BLUE v=DIAMOND height=1 cells
        interpol=NONE l=1 w=1;
proc gplot data=Pposm ;
   plot RESCHI * YEAR  / name='Res Ppom' caxis = BLACK ctext = BLACK cvref=RED
      cframe = CXFFFFFF hminor = 0 vminor = 0 vaxis = axis1 haxis = axis2 vref=0;
      run;
quit;
title2 'Residuals positive mincounts * Year';
proc gplot data=Posit ;
   plot RESID * YEAR  /description="Res Positiv*Year" caxis = BLACK cvref=RED
      ctext = BLACK cframe = CXFFFFFF hminor = 0 vminor = 0 vaxis = axis1 vref=0
      haxis = axis2;
      run;
quit;
proc univariate data=Posit ;
   var resid ;
   title2 "Residuals positive mincount Distribution";
   histogram resid / caxes=BLACK cframe=CXFFFFFF href=0 chref=RED
               cbarline=CX000080 cfill=CX00FFFF pfill=SOLID
               vscale=percent hminor=0 vminor=2 name='Hist resid positive'
               normal( mu=est sigma=est w=2 color=RED ) ;
   inset normal ;

 proc univariate data=posit;
   var resid ;
   title2 "QQplot Residuals Positive mincount rates";
   qqplot resid /caxes=BLACK hminor=0 vminor=0  
                normal ( mu=est sigma=est color=RED L=1 W=2);
   symbol v=DIAMOND c=BLUE h=1 cells;
run;

options ls=132;
PROC SUMMARY DATA=ESTIM;
   VAR index obmincount;
 OUTPUT OUT=STAND Mean(index)=MeanINDEX Mean(obmincount)=xobcp;
 RUN;
 DATA STAND;
   SET STAND;
  JOIN=1;
 RUN;
DATA OUTmincount;
   MERGE ESTIM STAND;
   BY JOIN;
   C= EXP(2*SQRT(LOG(1+CV_I**2)));
   STDmincount=INDEX/MeanINDEX;
   LCI=(INDEX/C)/MeanINDEX;
   UCI=(INDEX*C)/MeanINDEX;
   estmincount=index; stderr = se_i;
   obsmincount=obmincount/xobcp;
  KEEP YEAR STDmincount LCI UCI INDEX MeanINDEX CV_I se_i estmincount stderr obmincount obppos nobs obsmincount;
 RUN;
proc gplot data=outmincount;
  Title2 "Observed and Standardized mincount (95% CI)";
  plot (stdmincount lci uci obsmincount ) * year / overlay legend skipmiss vzero frame;
  symbol1 L=1 c=BLUE ci=BLUE interpol=Join W=2 value="DIAMOND";
  symbol2 L=3 c=BLUE ci=BLUE interpol=Join W=1 R=2;
  symbol3 c=RED ci=RED interpol=Join W=2 value="DOT";
 run;
proc sort data=posit; by  idvar ;run;
proc sort data=analysis; by  idvar ;run;
data predict;
 merge analysis posit;
 by idvar;
 if (Pred eq .) then Pred = 0;
run;
proc sort data=predict; by &factorsb;run;
data pposm; set pposm;
 keep &factorsb mu lowermu uppermu percpos positv total stderrmu resraw reschi;
run;
proc sort data=pposm; by &factorsb;run; 
data predict;
 merge predict pposm;
 by &factorsb;
 if (success=1) then 
 estmincount = mu*(exp(pred+stderrpred**2/2));
 else 
 estmincount = 0;
 run;
proc gplot data=estim;
  Title2 "Diagnostic plots: 1) Obs vs Pred Proport Posit";
  plot (obppos bc_pos) * year / overlay legend skipmiss vzero frame;
  symbol2 L=2 c=BLUE ci=BLUE interpol=Join W=1 value="DIAMOND";
  symbol1 L=1 c=RED ci=RED interpol=Join W=2 value="DOT";
 run;

proc gplot data=estim;
  Title2 "Diagnostic plots: 2) Obs vs Pred mincount of Posit only";
  plot (obcppos bc_cpu) * year / overlay legend skipmiss vzero frame;
  symbol2 L=2 c=BLUE ci=BLUE interpol=Join W=1 value="DIAMOND";
  symbol1 L=1 c=RED ci=RED interpol=Join W=2 value="DOT";
 run;
proc gplot data=estim;
  Title2 "Diagnostic plots: 3) Obs vs Pred mincount Input units";
  plot (obmincount index) * year / overlay legend skipmiss vzero frame;
  symbol2 L=2 c=BLUE ci=BLUE interpol=Join W=1 value="DIAMOND";
  symbol1 L=1 c=RED ci=RED interpol=Join W=2 value="DOT";
 run;
QUIT;



data output; set outmincount;
if nobs=. then delete;
SurveyYear=year;
Frequency=obppos;
N=nobs;
LoIndex=index;
StdIndex = stdmincount;
SE=se_i;
CV=cv_i;
LCL=LCI;
UCL=UCI;
keep SurveyYear Frequency N LoIndex CV SE StdIndex LCL UCL;
run;


proc print data=output noobs;
title2 "Index Output";run;


data ModFreqOcc2; merge ModFreqOcc estrawp;by year;
avemincount=mincount;
keep year MFO CVMFO LCLMFO UCLMFO avemincount;run;
proc print data=ModFreqOcc2 noobs;
title2 "Modeled Frequency of Occurrence Index Output";run;


ods rtf close;
