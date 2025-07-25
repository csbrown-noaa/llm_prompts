/*-----------------------------------------------------------
 TITLE                                                        
 -----                                                        
 GLIMMIX: a SAS macro for fitting generalized linear mixed    
 models using Proc Mixed and the Output Delivery System (ODS).
 Requires SAS/STAT Version 8.                     
                                                              
 SUPPORT                                                      
 -------                                                      
 Russ Wolfinger, SAS Institute Inc.  The original version was 
 written by Jason Brown, formerly of SAS Institute Inc.       
 Please send email to russ.wolfinger@sas.com with any suggestions 
 or corrections.                                              
                                                              
 HISTORY                                                      
 -------                                                      
 initial coding                                 01Jun92   jbb 
 a few changes and additions                    09Oct92   rdw 
 corrections from Dale McLerran, FHCRC          16Feb94   rdw 
 suggestions from David Murray, U. Minnesota    21Sep95   rdw 
 suggestions from Ken Goldberg, Wyeth-Ayerst    27Oct95   rdw 
 various minor updates                          06Apr96   rdw
 per suggestions from Ken Goldberg, INITIAL 
    option changed, INTERCEPT= option dropped,
    and FITTING, NOPREV, and NOTEST options 
    added.                                      12Mar97   rdw
 more Goldberg ideas: NOTES option added, 
    PARMS specification is only used in the 
    first iteration unless you also specify 
    NOPREV, some clean up                       19May97   rdw
 7.01 conversion                                01Jul97   rdw
 switched XBETA= and PRED=                      14Nov97   rdw 
 save spatial coordinates as suggested by
    Michael O'Kelly, Quintiles Dublin           01Dec97   rdw
 eliminated LSMEANS / OM check                  05Dec97   rdw
 titling code from Dale McLerran, FHCRC         20Feb98   rdw 
 made PRINTLAST and FITTING the default         25Mar98   rdw
 fixed problem with TYPE=SP(EXP)                30Apr98   rdw
 allowed METHOD=MIVQUE0 to persist as
    suggested by Svetlana Rudnaya, Ford         14Aug98   rdw
 changed output data set as suggested
    by Carol Gotway-Crawford, CDC               25Sep98   rdw
 Mauricio Ortiz Oct-2000 CHANGES IN OUTPUT LSMEASN TO
 GIVE SE FOR MU 

                                                             
 DESCRIPTION                                                  
 -----------                                                  
 The macro uses iteratively reweighted likelihoods to fit the 
 model; refer to Wolfinger, R. and O'Connell, M., 1993,       
 ``Generalized Linear Mixed Models:  A Pseudo-Likelihood      
 Approach,'' Journal of Statistical Computation and           
 Simulation, 48.                                              
                                                              
 By default, GLIMMIX uses restricted/residual psuedo          
 likelihood (REPL) to find the parameter estimates of the     
 generalized linear mixed model you specify.  The macro calls 
 Proc Mixed iteratively until convergence, which is decided   
 using the relative deviation of the variance/covariance      
 parameter estimates. An extra-dispersion scale parameter is  
 estimated by default.                                        

 There are a few macros at the beginning; all are used in the 
 main macro, GLIMMIX.  This macro will work on any type of    
 model with the error distributions and link functions given  
 in the ERRLINK macro.  In addition, you can specify your     
 own error and/or link functions.  In order to do this, you   
 must specify error=user and/or link=user in conjunction with 
 the errvar=, errdev=, linku=, linkud=, linkui=, and linkuid=
 options.  
                                                              
 The relevant information is saved using the MAKE statement   
 of Proc Mixed, which is a part of ODS.                        
                                                              
 The following are reserved variable names and should not be  
 used in your input SAS data set:                             
                                                              
    col, deta, dmu, eta, lowereta, lowermu, mu, pred, resraw,
    reschi, stderreta, stderrmu, uppereta, uppermu, var, _offset, 
    _orig, _w, _wght, _y, _z    

 The following data sets are created by the macro and exist
 after completion unless certain options exclude them:

    _class, _con, _cov, _diff, _dim, _ds, _est, _fitstats, _lsm, 
    _model, _pred, _predm, _slice, _soln, _solnr, _tests3

 To see how each of these data sets are created, search the macro
 code below.  If the data set you want is not one of these, add
 an appropriate MAKE statement to your STMTS= specification.
                                                              
 CAUTION:  This macro can produce biased results for repeated
 binary data with few repeats on each subject.  Refer to
 Breslow and Clayton (1993, JASA, 9-25). 
                                                              

 SYNTAX                                                       
 ------                                                       
 Syntax for the macro is similar to that of Proc Mixed.       
 There are other options that are macro-specific, however.    
                                                              
 %glimmix(data=,                                              
    procopt=,                                                 
    stmts=,                                                   
    weight=,                                                  
    freq=,                                                    
    error=,                                                   
    errvar=,                                                  
    errdev=, 
    link=,                                                    
    linkn=,                                                   
    linknd=,                                                  
    linkni=,                                                  
    linku=,                                                   
    linkud=,                                                  
    linkui=,                                                  
    linkuid=,                                                  
    numder=,                                                  
    cf=,                                                      
    converge=,                                                      
    maxit=,                                                      
    offset=,                                                  
    out=,
    outalpha=,
    options=                                                  
 )                                                            
                                                              
 where                                                        
                                                              
  data     specifies the data set you are using.  It can either
           be a regular input data set or the _DS data set
           from a previous call to GLIMMIX.  The latter is used
           to specify starting values for GLIMMIX and should be
           accompanied by the INITIAL option described below.
                                                              
  procopt  specifies options appropriate for a PROC           
           MIXED statement.  Refer to the Proc Mixed          
           documentation for more information.                
                                                              
  stmts    specifies Proc Mixed statements for the analysis,  
           separated by semicolons and listed as a single     
           argument to the %str() macro function.  Statements 
           may include any of the following:  CLASS, MODEL,   
           RANDOM, REPEATED, PARMS, ID, CONTRAST, ESTIMATE,   
           and LSMEANS.  Syntax and options for each          
           statement are exactly as in the Proc Mixed         
           documentation.  If you wish to use the OM option
           with the LSMEANS statement, you should specify
           OM=dataset to avoid conflicts with weights.
                                                              
  weight   specifies a weighting variable for the analysis    
           This allows you to construct your own weights      
           which can modify or replace the ones constructed   
           by GLIMMIX.                                        
                                                              
  freq     specifies a frequency variable for the analysis.   
           It replicates observations with the number of      
           replicates being equal to the value of the FREQ    
           variable.                                          
                                                              
  error    specifies the error distribution. Valid types are: 
                                                              
              binomial|b, normal|n, poisson|p, gamma|g,       
              invgaussian|ig, and user|u                      
                                                              
           When you specify error=user, you must also provide 
           the errvar= and errdev= options.  The default      
           error distribution is binomial.                    
                                                              
  errvar   specifies the user-defined variance function.  It  
           must be expressed as a function the argument "mu"  
           (see examples).                                    
                                                              
  errdev   specifies the user-defined deviance function.  It  
           must be expressed as a function the arguments      
           "_y", which is the response variable, and "mu",    
           which is the mean.  You are allowed to use "_wght" 
           also, which corresponds to the denominator of a    
           binomial response.  Typical deviance functions are 
           as follows:                                        
                                                              
                normal           (_y-mu)**2                   
                poisson          2*_y*log(_y/mu);             
                binomial         2*_wght*(_y*log(_y/mu)+      
                                  (1-_y)*log((1-_y)/(1-mu)))  
                gamma            -2*log(_y/mu)                
                invgaussian      (((_y-mu)**2)/(_y*mu*mu))    
                                                              
           The default deviance is binomial.                  

  link     specifies the link function. Valid types are       
                                                              
              logit, probit, cloglog, loglog, identity,       
              power(), log, exp, reciprocal, nlin, and user.  
              (warning: nlin has not been tested, and it currently
              uses an MQL-type estimation scheme.)             
                                                              
           When you specify link=nlin, you must also provide  
           the linkn=, linknd=, and linkni= options.  When    
           you specify link=user, you must also provide the   
           ulink=, dulink=, and iulink= options.  The default 
           link is different for each error distribution and  
           is as follows:                                     
                                                              
                  Distribution          Default Link          
                  ------------          ------------          
                  Binomial              Logit                 
                  Poisson               Log                   
                  Normal                Identity              
                  Gamma                 Reciprocal            
                  Invgaussian           Power(-2)             
                                                              
  linkn    specifies a nonlinear link function.  It must be 
           enclosed in %str() and assign a value to "mu" by   
           using parameters "b1" - "bk".       
                                                              
  linknd   specifies the derivative of the nonlinear link     
           function.                                          
                                                              
  linkni   specifies the initial values for the nonlinear     
           link function.

  linku    specifies a user-defined link function.  It must 
           be expressed as a function with the argument "mu". 
                                                              
  linkud   specifies the derivative of the user-defined link  
           function with respect to mu.  It must be expressed 
           as a function with argument "mu".  For an          
           approximation, use the formula                     
                                                              
                    (u(mu+h)-u(mu-h))/(2*h)                   
                                                              
           where u() is the link and h is a small number.     
                                                              
  linkui   specifies the inverse of the user-defined link.    
           It must be expressed as a function with argument   
           "eta".                                             
                                                              
  linkuid  specifies the derivative of the inverse of the 
           user-defined link.  It must be expressed as a function 
           with argument "eta". 
                                                              
  numder   specifies the tolerance used to numerically differentiate
           certain link functions (e.g. probit and power).  It has
           a default value of 1e-5. 
                                                              
  cf       specifies the correction factor added to the data  
           in order to avoid singularities in the initial
           iteration.  It has a default value of 0.5.         
                                                              
  converge sets the convergence criterion for the GLIMMIX     
           macro.  This is not the convergence criteria used  
           for each internal Proc Mixed call, but rather the  
           criterion used to assess convergence of the entire 
           macro algorithm.  It has a default value of 1e-8.  
                                                              
  maxit    specifies the maximum number of iterations for the 
           GLIMMIX macro to converge.  It has a default value of
           20.                                             
                                                              
  offset   specifies the offset variable.  By default no offset
           is used.
                                                              
  out      specifies a name for an output data set.  This data
           set is the predicted value data set from Proc Mixed with
           the following additional variables:  

           eta       = linear predictor (xbeta) + offset
           stderreta = approximate std err of eta
           lowereta  = lower confidence limit for eta
           uppereta  = upper confidence limit for eta
           mu        = inverse link transform of eta
           dmu       = derivative of mu with respect to eta
           stderrmu  = approx std err of mu via delta method
           lowermu   = lower cl for mu, inv link transform of lowereta
           uppermu   = upper cl for mu, inv link transform of uppereta
           var       = variance 
           resraw    = raw residual, y - mu
           reschi    = scaled residual, (y-mu)/sqrt(phi*var)     
           deta      = derivative of eta with respect to mu
           _w        = weight used in final Proc Mixed call
           _z        = dependent variable used in final Proc Mixed call   

                      If none is given, then a default name   
                      of _OUTFILE is used.                    
                                                              
  outalpha specifies an alpha level for the confidence limits
           in the out= data set.              
                                                              
  options  specifies GLIMMIX macro options separated by       
           spaces:     

     INITIAL         specifes that the input data set is actually
                     the _DS data set from a previous call to 
                     GLIMMIX.   This allows you to restart a
                     problem that stopped or to specify starting
                     values.
                                                              
     MQL             computes MQL estimates (see Breslow and  
                     Clayton, 1993, JASA, 9-25).  The default 
                     is PQL with an extra-dispersion          
                     parameter. 
                                                              
     NOPREV          prevents use of previous covariance parameter
                     estimates as starting values for the next 
                     iteration.

     NOPRINT         suppresses all printing.                 
                                                              
     NOITPRINT       suppresses printing of the iteration     
                     history.  

     NOTES           requests printing of SAS notes, date, and page
                     numbers during macro execution.  By default, 
                     the notes, date, and numbers are turned off
                     during macro execution and turned back on after
                     completion.
                                                              
     PRINTALL        prints all Proc Mixed runs.              
                                                              
     PRINTDATA       prints the pseudo data after each        
                     iteration.                               

                                                        
 OUTPUT                                                       
 ------                                                       
 The output from this macro is a printout of selected tables  
 from the final iteration of Proc Mixed.  All of these tables 
 are stored in data sets whose names begin with an            
 underscore; you can scan the macro code to find the name of  
 the data set you wish to use.                                
                                                              
                                                              
 EXAMPLE SYNTAX                                               
 --------------                                               
 1) Both of the following examples specifiy the same          
    analysis:  logistic regression, no random effects         
                                                              
    %glimmix(data=ingots,                                     
       stmts=%str(                                            
          class soak;                                         
          model nready/ntotal=soak heat;                      
       )                                                      
    )                                                         
                                                              
    %glimmix(data=ingots,                                     
       stmts=%str(                                            
          class soak;                                         
          model nready/ntotal=soak heat;                      
       ),                                                     
       error=user,errvar=mu*(1-mu),                           
       errdev=2*_wght*(_y*log(_y/mu) +                        
              (1-_y)*log((1-_y)/(1-mu))),                     
       link=user,
       linku=log(mu/(1-mu)),                        
       linkud=1/(mu*(1-mu)),
       linkui=exp(eta)/(1+exp(eta)),
       linkuid=-exp(eta)/(1+exp(eta))**2;     
    )                                                         
                                                              
    Here _wght corresponds to ntotal and _y to nready/ntotal. 
                                                              
 2) This example uses the random, lsmeans, and options        
    arguments:                                                
                                                              
    %glimmix(data=salaman1,                                   
       stmts=%str(                                            
          class fpop fnum mpop mnum;                          
          model y = fpop|mpop;                                
          random fpop*fnum mpop*mnum;                         
          lsmeans fpop|mpop / cl;                             
       )
       options=noitprint                                                    
    )                                                         
                                                              
 3) This example uses the procopt, random, and offset         
    arguments:                                                
                                                              
    %glimmix(data=ship,                                       
       procopt=order=data,                                    
       stmts=%str(                                            
          class type year period;                             
          model y=type;                                       
          random year period;                                 
       ),                                                     
       error=poisson,link=log,offset=service                  
    )                                                         
                                                              
 4) This example uses the repeated argument:                  
                                                              
    %glimmix(data=salaman1,                                   
       stmts=%str(                                            
          class fpop fnum mpop mnum;                          
          model y = fpop|mpop;                                
          repeated / type=ar(1) sub=fpop*fnum;                
          lsmeans fpop|mpop / cl;                             
       )                                                      
    )                                                         
                                                              
 DISCLAIMER                                                   
 -----------                                                  
                                                              
 THIS INFORMATION IS PROVIDED BY SAS INSTITUTE INC. AS A      
 SERVICE TO ITS USERS.  IT IS PROVIDED "AS IS".  THERE ARE NO 
 WARRANTIES, EXPRESSED OR IMPLIED, AS TO MERCHANTABILITY OR   
 FITNESS FOR A PARTICULAR PURPOSE REGARDING THE ACCURACY OF   
 THE MATERIALS OR CODE CONTAINED HEREIN.                      
                                                              
 -------------------------------------------------------------*/

 

 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %mvarlst                                                  */
 /*    Make a variable list from the class list, model           */
 /*    specification, and random specification.                  */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro mvarlst;
 %let varlst =;
 %let mdllst = &mdlspec;
 
 /*---get response variable---*/
 %if %index(&response,/) %then 
    %let varlst = %scan(&response,1,/) %scan(&response,2,/) &varlst; 
 %else %let varlst = &response &varlst; 
 
 /*---get fixed effects---*/
 %if %index(&mdllst,@) %then %do;
    %let j = 1;
    %let mdl = &mdllst;
    %let mdllst=;
    %do %while(%length(%scan(&mdl,&j,' ')));
       %let var=%scan(&mdl,&j,' ');
       %if %index(&var,@) %then %do;
          %let b = %eval(%index(&var,@)-1);
          %let mdllst = &mdllst %substr(%quote(&var),1,&b);
       %end;
       %else %let mdllst = &mdllst &var;
       %let j = %eval(&j+1);
    %end;
 %end;

 %let iv = 1;
 %do %while (%length(%scan(&mdllst,&iv)));
    %let varlst = &varlst %scan(&mdllst,&iv);
    %let iv = %eval(&iv + 1);
 %end;
 
 /*---get random effects---*/
 %let iv = 1;
 %do %while (%length(%scan(&rndlst,&iv)));
    %let temp = %scan(&rndlst,&iv);
    %if &temp ne INT and &temp ne INTERCEPT %then
       %let varlst = &varlst &temp;
    %let iv = %eval(&iv + 1);
 %end;  

 /*---get repeated effects---*/
 %let iv = 1;
 %do %while (%length(%scan(&replst,&iv)));
    %let temp = %scan(&replst,&iv);
    %if &temp ne DIAG %then %let varlst = &varlst &temp;
    %let iv = %eval(&iv + 1);
 %end;  
  
 %let varlst = &varlst &class &id &freq &weight;
%mend mvarlst;


 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %trimlst                                                  */
 /*    Get rid of repetitions in a list                          */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro trimlst(name,lst);
 %let i1 = 1;
 %let tname =;
 %do %while (%length(%scan(&lst,&i1,%str( ))));
    %let first = %scan(&lst,&i1,%str( ));
    %let i2 = %eval(&i1 + 1);
    %do %while (%length(%scan(&lst,&i2,%str( ))));
       %let next = %scan(&lst,&i2,%str( ));
       %if %quote(&first) = %quote(&next) %then %let i2=10000;
       %else %let i2 = %eval(&i2 + 1);
    %end;
    %if (&i2<10000) %then %let tname = &tname &first;
    %let i1 = %eval(&i1 + 1);
 %end;
 %let &name = &tname;
%mend trimlst;

 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %remove                                                   */
 /*    Remove a word from a string                               */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro remove(sntnc,wrd);
 %let sentence=%str( )%nrbquote(&sntnc); 
 %if &sentence^=%str( ) %then %do;
    %let word=%str( )%nrbquote(&wrd);
    %let answer=;
    %let i=%index(&sentence,&word);
    %if &i and &word^=%str( ) %then %do;
       %if &i>1 %then %let answer=%qsubstr(&sentence,1,&i-1);
       %let j=%eval(&i+%index(%qsubstr(&sentence,&i+1),%str( )));
       %if &j>&i %then
       %let answer=&answer%qsubstr(&sentence,&j);
    %end;
    %else %let answer=&sentence;
    %unquote(&answer)
 %end;
%mend remove;


 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %errlink                                                  */
 /*    Create macro variables that contain the link, invlink,    */
 /*    derivative, and the variance funtion for the following    */
 /*    error distributions and link functions:                   */
 /*                                                              */
 /*    error distn: normal, binomial, poisson, gamma, and        */
 /*                 inverse gaussian                             */
 /*    link func:   logit, probit, complementary log-log,        */
 /*                 log-log, identity, power(), log, exp, and    */
 /*                 reciprocal.                                  */
 /*                                                              */
 /*    The user-defined specification is given by leaving the    */
 /*    error distribution field blank and then giving the link,  */
 /*    the derivative of the link, the inverse link, and the     */
 /*     variance function.  The parameters for each are:         */
 /*                                                              */
 /*          mu:   variance function, link, and the derivative   */
 /*                of the link                                   */
 /*         eta:   inverse link;                                 */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro errlink;

 /*---error distributions: set variance and deviance functions---*/
 %let exiterr = 0;
 %if %length(&error)=0 %then %do;
    %if %length(&errvar) and %length(&errdev) %then %let error=USER;
    %else %let error=BINOMIAL;
 %end; 
 %if %length(&linkn) and %length(&link)=0 %then %let link=NLIN;
 %if %length(&linku) and %length(&link)=0 %then %let link=USER;
 %if &error=BINOMIAL or &error=B %then %do;
    %let errorfn=BINOMIAL;
    %let varform=mu*(1-mu);
    %let devform=_wght*2*(_y*log(_y/mu) + (1-_y)*log((1-_y)/(1-mu)));
    %if %length(&link)=0 %then %let link=LOGIT;
 %end;
 %else %if &error=POISSON or &error=P %then %do;
    %let errorfn=POISSON;
    %let varform=mu;
    %let devform=_wght*2*_y*log(_y/mu);
    %if %length(&link)=0 %then %let link=LOG;
 %end;
 %else %if &error=NORMAL or &error=N %then %do;
    %let errorfn=NORMAL;
    %let varform=1;
    %let devform=_wght*(_y-mu)**2;
    %if %length(&link)=0 %then %let link=IDENTITY;
 %end;
 %else %if &error=GAMMA or &error=G %then %do;
    %let errorfn=GAMMA;
    %let varform=mu**2;
    %let devform=_wght*-2*log(_y/mu);
    %if %length(&link)=0 %then %let link=RECIPROCAL;
 %end;
 %else %if &error=INVGAUSSIAN or &error=IG %then %do;
    %let errorfn=INVGAUSSIAN;
    %let varform=mu**3;
    %let devform=_wght*(((_y-mu)**2)/(_y*mu*mu));
    %if %length(&link)=0 %then %let link=INVGAUSSIAN;
 %end;
 %else %if &error=USER or &error=U %then %do;
    %let errorfn=USER;
    %if %length(&errvar) %then %let varform=&errvar;
    %else %let exiterr = 1;
    %if %length(&errdev) %then %let devform=&errdev;
    %else %let exiterr = 1;
    %if %length(&link)=0 %then %let link=LOGIT;
 %end;

 /*---truncate link function, so we can match if a power link---*/
 %if %length(&link)>5 %then %let trlink=%substr(&link,1,5); 
 %else %let trlink=&link; 

 /*---link functions; set eta, mu, and derivative formulas---*/
 %if &trlink=LOGIT %then %do;
    %let linkfn=LOGIT;
    %let etaform=log(mu/(1-mu));
    %let detaform=1/(mu*(1-mu));
    %let muform=exp(eta)/(1+exp(eta));
    %let dmuform=exp(eta)/(1+exp(eta))**2;
 %end;
 %else %if &trlink=PROBI %then %do;
    %let linkfn=PROBIT;
    %let etaform=probit(mu);
    %let detaform=(probit(mu+&numder)-probit(mu-&numder))/
       (2*&numder);
    /*
    %let detaform=(probit(min(1,mu+&numder*(1+abs(mu)))) - 
       probit(max(1,mu-&numder*(1+abs(mu))))) /
       (2*&numder*(1+abs(mu)));
    */
    %let muform=probnorm(eta);
    %let dmuform=(probnorm(eta+&numder)-probnorm(eta-&numder))/
       (2*&numder);
 %end;
 %else %if &trlink=CLOGL %then %do;
    %let linkfn=COMPLEMENTARY LOG LOG;
    %let etaform=log(-log(1-mu));
    %let detaform=-1/((1-mu)*log(1-mu));
    %let muform=1-exp(-exp(eta));
    %let dmuform=exp(-exp(eta))*exp(eta);
 %end;
 %else %if &trlink=LOGLO %then %do;
    %let linkfn=LOG LOG;
    %let etaform=-log(-log(mu));
    %let detaform=-1/(mu*log(mu));
    %let muform=exp(-exp(-eta));
    %let dmuform=exp(-exp(-eta))*exp(-eta);
 %end;
 %else %if &trlink=IDENT %then %do;
    %let linkfn=IDENTITY;
    %let etaform=mu;
    %let detaform=1;
    %let muform=eta;
    %let dmuform=1;
 %end;
 %else %if &trlink=LOG %then %do;
    %let linkfn=LOG;
    %let etaform=log(mu);
    %let detaform=1/mu;
    %let muform=exp(eta);
    %let dmuform=exp(eta);
 %end;
 %else %if &trlink=EXP %then %do;
    %let linkfn=EXPONENTIAL;
    %let etaform=exp(mu);
    %let detaform=exp(mu);
    %let muform=log(eta);
    %let dmuform=1/eta;
 %end;
 %else %if &trlink=RECIP %then %do;
    %let linkfn=INVERSE;
    %let etaform=1/mu;
    %let detaform=-1/mu**2;
    %let muform=1/eta;
    %let dmuform=-1/eta**2;
 %end;
 %else %if &trlink=POWER %then %do;
    %let linklen = %eval(%length(&link)-7);
    %let expon=%substr(&link,7,&linklen);
    %let linkfn=POWER(&expon);
    %let etaform=mu**(&expon);
    %let detaform=(&expon)*mu**(&expon-1);
    /*
    %let detaform=((mu+&numder)**(&expon)-(mu-&numder)**(&expon))/
       (2*&numder);
    %let detaform=((mu+&numder*(1+abs(mu)))**(&expon) -
       (mu-&numder*(1+abs(mu)))**(&expon))/
       (2*&numder*(1+abs(mu)));
    */
    %let muform=eta**(1/(&expon));
    %let dmuform=(1/(&expon))*eta**(1/(&expon)-1);
 %end;
 %else %if &trlink=INVGA %then %do;
    %let linkfn=POWER(-2);
    %let etaform=mu**(-2);
    %let detaform=-2*mu**(-3);
    %let muform=eta**(-1/2);
    %let dmuform=(-1/2)*eta**(-3/2);
 %end;
 %else %if &trlink=BOXCO %then %do;
    %let linkfn=BOX-COX;
    %let linklen = %eval(%length(&link)-8);
    %let expon=%substr(&link,8,&linklen);
    %let etaform=(mu**(&expon)-1)/(&expon);
    %let detaform=mu**((&expon)-1);
    %let muform=((&expon)*eta + 1)**(1/(&expon));
    %let dmuform=((&expon)*eta + 1)**(1/(&expon)-1);
 %end;
 %else %if &trlink=USER %then %do;
    %let linkfn=USER;
    %if %length(&linku) %then %let etaform=&linku;
    %else %let exiterr = 1;
    %if %length(&linkud) %then  %let detaform=&linkud;
    %else %let exiterr = 1;
    %if %length(&linkui) %then %let muform=&linkui;
    %else %let exiterr = 1;
    %if %length(&linkuid) %then %let dmuform=&linkuid;
    %else %let exiterr = 1;
 %end;
 %else %if &trlink=NLIN %then %do;
    %let linkfn=NONLINEAR;
    %if %length(&linkn) %then %let nlinform=&linkn;
    %else %let exiterr = 1;
    %if %length(&linknd) %then %let nlinder=&linknd;
    %else %let exiterr = 1;
 %end;

 %if %index(&options,DEBUG) %then %do;
    %put options = &options;
    %put intopt = &intopt;
    %put varlst = &varlst;
    %put error = &errorfn;
    %put variance = &varform;
    %put deviance = &devform;
    %put link:  eta = &etaform;
    %put dlink:  deta = &detaform;
    %put invlink:  mu = &muform;
 %end;
 
%mend errlink;



 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %init                                                     */
 /*    Sets the initial values for the iterations.               */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro init;

 %let off = &offset;

 %if %index(&intopt,NLIN) %then %do;
    /*---determine number of parameters---*/
    %let nb = 0;
    %let i = 1;
    %do %while(%index(&linkni,B&i));
       %let nb = %eval(&nb + 1);
       %let i = %eval(&i + 1);
    %end;
    %let nu = 0;
    %let ns = 0;
    %let nus = 0;
    %let varlst = &varlst one mu;
 %end;

 data _ds;
    set %unquote(&data);   
    %if not %index(&options,INITIAL) %then %do;
       /*---move away from parameter space boundary for the binomial
            error situation---*/
       %if %index(&response,/) %then %do;
          mu = (%scan(&response,1,/) + &cf)/(%scan(&response,2,/) + 
             2*&cf); 
          _wght = %scan(&response,2,/) ;
       %end;
       %else %if &errorfn=BINOMIAL %then %do;
          mu = (&response + &cf)/(1 + 2*&cf);
          _wght = 1;
       %end;
       %else %do;
          mu = &response + &cf;
          _wght = 1;
       %end;
       %if %length(&weight) %then %do;
          _wght = &weight * _wght;               
       %end;
       _y      = &response;
       var     = &varform;
       _offset = &off;
       %if %index(&intopt,NLIN) %then %do;
          array b{&nb} b1-b&nb;
          array db{&nb} db1-db&nb;
          one = 1;
          %do i = 1 %to &nb;
             %let idx = %index(&linkni,B&i);
             b&i = %scan(%substr(&linkni,&idx),2,'=' ' ');
          %end;
          &nlinform
          _z = _y - mu;
          &nlinder
          do i = 1 to &nb;
             _z = _z + db{i}*b{i};
          end;
          _w = _wght / var;
       %end;
       %else %do;
          eta  = &etaform ;
          deta = &detaform ; 
          _w = _wght / ((deta**2)*(var));
          _z = (_y-mu)*deta + eta - _offset;
       %end;
       %if %length(&freq) %then %do;
          do i = 1 to &freq;
             if i=1 then _orig='y'; 
             else _orig='n';                    
             output;                         
          end;
       %end;
       %else %do;
          _orig='y';
       %end;
       if (_w = .) then _w = 1;
       /*
       keep _y _z _w _offset _wght _orig &varlst;
       */
    %end;
 run;

 %if %index(&options,PRINTDATA) %then %do;
    proc print;
    run;
 %end;

 %let iter = 0;
  
%mend init;


 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %newdata                                                  */
 /*    Create the new data set with the updated values           */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro newdata;
 /*---save previous parameter estimates---*/
 data _oldsoln;
    set _soln;
 run;

 /*---save previous estimates of covariance matrix---*/
 data _oldcov;
    set _cov;
    %let covsaved = 1;
 run;

 %if %index(&options,DEBUG) %then %put Creating new pseudo data.;

 /*---create new data set---*/
 data _ds; 
    %if %index(&intopt,NLIN) %then %do;
       set _ds;
       array b{&nb} b1-b&nb;
       array db{&nb} db1-db&nb;
       /*
       array u{&nu,&ns} u1-u&nus;
       array du{&nu,&ns} du1-du&nus;
       array _r{&nu} _r1-_r&nu;
       */
       &nlinform 
       _z = _y - mu;
       &nlinder 
       do i = 1 to &nb;
          _z = _z + db{i}*b{i};
       end;
       /*
       do i = 1 to &nu;
          _r{i} = du{i,subject};
          _z = _z + _r{i}*u{i,subject};
          end;
       end;
       */
       var = &varform; 
       _w = _wght / var;
       /*
       keep _y _z _w _offset _wght _orig &varlst db1-db&nb one x;
       */
    %end;
    %else %do; 
       set _pred;
       eta = pred + _offset;
       mu = &muform; 
       deta = &detaform;
       var = &varform;  
       %if %index(&options,HYBRID) %then %do;
          eta = (pred + _offset)/1.5;
          mu = &muform; 
          deta = &detaform;
          eta = pred + _offset;
          mu = &muform; 
          /*
          mu = &muform; 
          var = &varform;  
          */
       %end;
       _w = _wght / ((deta**2)*(var));
       _z = (_y - mu)*deta + eta - _offset;
       /*
       keep _y _z _w _offset _wght _orig &varlst;
       */
       %end;
    run;
  
 %if %index(&options,PRINTDATA) %then %do;
    proc print;
    run;
 %end;

%mend newdata;



 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %mixed                                                    */
 /*    Calculate parameter estimates using Proc Mixed.           */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro mixed;

 %if %index(&options,DEBUG) %then %put Calling Proc Mixed.;

 %let mivque0 = 0;
 
 %again:

 /*---get rid of predicted data set---*/
 /*proc datasets lib=work nolist;
    delete _pred;
 run;*/

 /*---use mivque0 if did not converge the first time---*/
 %if (&mivque0 = 1) %then %do;
    /*---save the original method---*/
    %let procopt0 = &procopt;
    %let procopt = &procopt METHOD=MIVQUE0;
 %end;

 proc mixed data=_ds &procopt;
    %if %length(&class) %then %do;
       class &class ; 
       %if not %index(&procopt,NOCLPRINT) %then %do;
          ods output classlevels=_class;
       %end;
    %end;
    model _z = %unquote(&mdlspec) %unquote(&mdlopt);
    weight _w;
    ods output modelinfo=_model;
    ods output dimensions=_dim;
    ods output covparms=_cov;
    ods output fitstatistics=_fitstats;
    ods output solutionf=_soln;
    %if %length(%scan(&mdlspec,1)) and not %index(&mdlopt,NOTEST) 
       %then %do;
       ods output tests3=_tests3;
    %end;
    %if %length(&spec) %then %do;
       %unquote(&spec)
       %if %index(&intopt,SOLNR) %then %do;
          ods output solutionr=_solnr;
       %end;
       %if %index(&spec,ESTIMATE) %then %do;
          ods output estimates=_est;
       %end;
       %if %index(&spec,CONTRAST) %then %do;
          ods output contrasts=_con;
       %end;
       %if %index(&spec,LSMEANS) %then %do;
          ods output lsmeans=_lsm;
          %if %index(&intopt,LSMDIFF) %then %do;
             ods output diffs=_diff;
          %end;
          %if %index(&intopt,LSMSLICE) %then %do;
             ods output slices=_slice;
          %end;
       %end;
    %end;
    %if &covsaved=1 and not %index(&options,NOPREV) and 
       not %index(&procopt,MIVQUE0) and (&mivque0 = 0) %then 
       %str(parms / pdata=_oldcov &parmopt2;);
    %else %if (%length(&parmspec) or %length(&parmopt)) and 
       (&mivque0 = 0) %then %do;
       parms &parmspec &parmopt ;
    %end;
    id _y _offset _wght _orig &varlst;
 run;

 %if %index(&options,PRINTDATA) %then %do;
    proc print data=_pred;
    run;
 %end;

 /*---check for convergence, if not, then run again
      with method=mivque0---*/
 %if (&mivque0 = 1) %then %do;
    %let procopt = &procopt0;
    %let mivque0 = 0;
 %end;
 %else %do;
    %let there = no;
    data _null_; 
       set _pred; 
       call symput('there','yes'); 
    run;
    %if ("&there" = "no") %then %do;
       %if not %index(&options,NOPRINT) %then %do;
          %put Computing MIVQUE0 estimates in iteration &iter because;
          %put %str(   )Proc Mixed did not converge.;
       %end;
       %let mivque0 = 1;
       %goto again;
    %end;
 %end;

 /*---set up for hybrid Taylor series---*/
 %if %index(&options,HYBRID) %then %do;
    data _predm;
       set _predm;
       predm = pred;
       keep predm;
    run;
    data _pred;
       merge _predm _pred;
    run;
 %end; 

 /*---merge in new estimates of b and u for nonlinear link---*/
 %if %index(&intopt,NLIN) %then %do;
    %if (&nb) %then %do;
       proc transpose data=_soln out=_beta;
          var estimate;
       run;
       data _beta;
          set _beta;
          array b{&nb} b1-b&nb;   
          array col{&nb} col1-col&nb;
          do i = 1 to &nb;
             b{i} = col{i};
             end;
          one = 1;
          keep one b1-b&nb;
       run;
       data _ds;
          set _ds;
          drop b1-b&nb;
       run;
       data _ds;
          merge _ds _beta;
          by one;
       run;
    %end;
    /*---this isn't finished---*/
    /*
    %if (&nu) %then %do;
       proc transpose data=_solnr out=_blup;
          var estimate;
       run;
       data _blup;
          set _blup;
          array u{&nus} u1-u&nus;   
          array col{&nus} col1-col&nus;
          do i = 1 to &nus;
             u{i} = col{i};
             end;
          one = 1;
          keep one u1-u&nus;
       run;
    %end;
    */
 %end;

%mend mixed;   


 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %compare                                                  */
 /*    Compare the last two parameter estimates to check for     */
 /*    convergence if no random components, else compare         */
 /*    estimates of covariance matrix.                           */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro compare;

 /*---Use relative difference of parameter estimates and
      covariance matrix as a measure of convergence---*/
 %let crit = 0;
 %compit(soln,estimate); 
 %compit(cov,estimate);

 data _null_;
    crit = &crit;
    if (crit<&converge) then conv = 1;
    else conv = 0;
    call symput('conv',conv);
 run;

%mend compare;


%macro compit(type,est);

 /*---save convergence information in conv and crit---*/
 data _compare;
    merge _old&type(rename=(&est=oldest)) _&type end=last;
    retain crit &crit;
    denom = (abs(oldest) + abs(&est))/2;
    if (denom > &converge) then do; 
       reldiff = abs(oldest - &est) / denom;
       crit = max(crit,reldiff);
    end;
    output;
    if last then do;
       call symput('crit',left(crit));
    end;
 run;

 %if %index(&options,DEBUG) %then %do;
    proc print data=_compare; 
    run;
 %end;

%mend compit;




 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %iterate                                                  */
 /*    Iteration process                                         */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro iterate;

 %let conv = 0;
 %let iter = 1;

 %do %while(&iter <= &maxit); 
    %newdata
    %mixed
    %compare
    %if not %index(&options,NOPRINT) and
        not %index(&options,NOITPRINT) %then %do;
       %if (&iter=1) %then %do;
          %put %str(   ) GLIMMIX Iteration History;
          %put;
          %put Iteration    Convergence criterion;
       %end;
       %if (&iter<10) %then 
          %put %str(   ) &iter            &crit;
       %else %if (&iter<100) %then 
          %put %str(  ) &iter            &crit;
       %else 
          %put %str( ) &iter            &crit;
    %end;
    %let iter = %eval(&iter+1);
    %if (&conv=1) %then %let iter=%eval(&maxit+1);
 %end;   

%mend iterate;


 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %compile                                                  */
 /*    Compile the macro results.                                */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro compile;

 /*---get variance estimate---*/
 %let scale = 1;
 data _null_;
    set _cov;
    if covparm='Residual' then call symput('scale',estimate);
 run;

 /*---calculate deviance and Pearson Chi-Squared---*/
 %if %index(&intopt,NLIN) %then %do;
    data _pred;
       set _pred;
       one = 1;
    run;
    data _pred;
       merge _pred _beta;
       by one;
    run;
 %end;

 data _stats;
    set _pred end=last;
    retain deviance 0 pearson 0;
    if ((_y ne .) and (pred ne .)) then do;
       _y  = _y + 1e-10*(_y=0) - 1e-10*(_y=1);
       eta = pred + _offset;
       %if %index(&intopt,NLIN) %then %do;
          &nlinform;
       %end;
       %else %do;
          mu = &muform;
       %end;
       deviance + &devform;
       pearson  + _wght * ((_y-mu)**2/(&varform));
    end;
    if last;
    keep deviance pearson;
 run;

 data _stats;
    length descript $35;
    set _stats;
    descript = 'Deviance'; 
    value = deviance; output;
    descript = 'Scaled Deviance'; 
    value = deviance / &scale; output;
    descript = 'Pearson Chi-Square'; 
    value = pearson; output;
    descript = 'Scaled Pearson Chi-Square'; 
    value = pearson / &scale; output;
    descript = 'Extra-Dispersion Scale'; 
    value = &scale; output;
    keep descript value;
    label descript = 'Description' value = 'Value';
 run;

 /*---ESTIMATE statement results---*/
 %if %index(&spec,ESTIMATE) %then %do;
    data _est;
       set _est;
       %if not %index(&intopt,NLIN) %then %do;
          eta = estimate;
          mu = &muform;
          label mu = 'Mu';
          drop eta;
          %if %index(&intopt,ESTCL) %then %do;
             eta = lower;
             lowermu = &muform;
             eta = upper;
             uppermu = &muform;
             label lowermu = 'LowerMu' uppermu = 'UpperMu';
          %end;
       %end;
    run;
 %end;

 /*---least squares means---*/
 %if %index(&spec,LSMEANS) %then %do;
    data _lsm;
       set _lsm;
       %if not %index(&intopt,NLIN) %then %do;
          eta = estimate;
	      stderreta = stderr;
          mu = &muform;
          dmu = &dmuform;
          stderrmu = abs(dmu)*stderreta;
          label mu = 'Mu';
          %if %index(&intopt,LSMCL) %then %do;
             eta = lower;
             lowermu = &muform;
             eta = upper;
             uppermu = &muform;
             label lowermu = 'LowerMu' uppermu = 'UpperMu';
          %end;
          drop eta;
       %end;
    run;
 %end;

%mend compile;


 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %printout                                                 */
 /*    Print out the macro results.                              */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro printout;

 &titlen 'GLIMMIX Model Statistics';  
 proc print data=_stats noobs label;
    format value 10.4;
 run;  
 &titlen;   

%mend printout;


                        
 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %outinfo                                                  */
 /*    Make an output data set.                                  */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro outinfo(outfile);

 data &outfile; 
    set _pred;
    eta = pred + _offset;
    stderreta = stderrpred;
    lowereta = lower + _offset;
    uppereta = upper + _offset;
    mu = &muform;
    dmu = &dmuform;
    stderrmu = abs(dmu)*stderreta;
    eta = lowereta;
    lowermu = &muform;
    eta = uppereta;
    uppermu = &muform;
    eta = pred + _offset;
    var = &varform;
    resraw = _y - mu;
    reschi = (_y-mu)/sqrt(&scale * var);
    deta = &detaform;
    _w = _wght /((deta**2)*(var));
    _z = (_y - mu)*deta + eta - _offset; 
    if _orig='y';
 run;

%mend outinfo;
                         
 /*--------------------------------------------------------------*/
 /*                                                              */
 /*    %glimmix                                                  */
 /*    Put it all together                                       */
 /*                                                              */
 /*--------------------------------------------------------------*/
%macro glimmix(data=,procopt=,stmts=,weight=,freq=,
    error=BINOMIAL,errvar=,errdev=,link=,linku=,linkud=,
    linkui=,linkuid=,linkn=,linknd=,linkni=,numder=1e-5,cf=0.5,
    converge=1e-8,maxit=20,offset=0,out=,outalpha=0.05,options=);

 %let options = %qupcase(&options);
 %if %index(&options,DEBUG) %then %put Initializing.;
 %else %if not %index(&options,NOTES) %then %do;
    options nonotes nodate nonumber;
 %end;

 /*---default data set---*/
 %if %bquote(&data)= %then %let data=&syslast;
 %let exiterr = 0;
 %let covsaved = 0;
 %let there = no;
 /*---check that it is there---*/
 data _null_; 
    set &data; 
    call symput('there','yes'); 
 run;
 %if ("&there" = "no") %then %do;
    %let exiterr = 1;
    %goto exit;
 %end;

 /*---change to uppercase---*/
 %let data     = %qupcase(&data);
 %let procopt  = %qupcase(&procopt);
 %let weight   = %qupcase(&weight);
 %let freq     = %qupcase(&freq);
 %let stmts    = %qupcase(&stmts);
 %let error    = %qupcase(&error);
 %let errvar   = %qupcase(&errvar);
 %let errdev   = %qupcase(&errdev);
 %let link     = %qupcase(&link);
 %let linkn    = %qupcase(&linkn);
 %let linknd   = %qupcase(&linknd);
 %let linkni   = %qupcase(&linkni);
 %let linku    = %qupcase(&linku);
 %let linkud   = %qupcase(&linkud);
 %let linkui   = %qupcase(&linkui);
 %let linkuid  = %qupcase(&linkuid);
 %let offset   = %qupcase(&offset);
 %let outfile  = %qupcase(&out);
 %let outalpha = %qupcase(&outalpha);
 %let options  = %qupcase(&options);

 /*---title---*/
 %let ntitle=0; 
 %let titlesas=;
 data _null_;
    set sashelp.vtitle;
    if (number=1) and (text="The SAS System") then 
       call symput("titlesas",right(text));
    else call symput("ntitle",left(put(number,2.)));
    if number=10 then call symput("title10",text);
 run;
 %if &ntitle=10 %then %let titlen = title10;
 %else %let titlen = title%eval(&ntitle + 1);

 /*---loop through statements and extract information---*/
 %let spec = ;
 %let class = ;
 %let parms = ;
 %let id = ;
 %let rndlst = ;
 %let replst = ;
 %let intopt = ;
 %let iv = 1;
 %do %while (%length(%scan(&stmts,&iv,;)));

    %let stmt = %qscan(&stmts,&iv,%str(;));
    %let first = %qscan(&stmt,1);
    %let fn = %eval(%index(&stmt,&first) + %length(&first));

    /*---check RANDOM options and extract random effects list---*/
    %if %index(&first,RANDOM) or %index(&first,REPEATED) %then %do; 
       %let intopt = &intopt COVMOD;
    %end;
    %if %index(&first,RANDOM) %then %do;
       %let i = %index(&stmt,/);
       %if &i = 0 %then %let i = %length(&stmt);
       %else %do;  
          %let rndopt = %substr(&stmt,&i); 
          %if %index(&rndopt,%str( S )) or %index(&rndopt,SOLUTION) or
             %index(&rndopt,%str( CL )) or %index(&rndopt,ALPHA) %then %do;
             %let intopt = &intopt SOLNR;
          %end;
       %end;
       %let rndlst = %substr(&stmt,&fn,%eval(&i-&fn+1));
    %end;
  
    /*---check REPEATED options and extract repeated effects list---*/
    %if %index(&first,REPEATED) %then %do;
       %let i = %index(&stmt,/);
       %if &i = 0 %then %let i = %length(&stmt);
       %else %do; 
          %let repopt = %substr(&stmt,&i); 
          %let j = %index(&repopt,EXP);
          %if &j ne 0 %then %do;
             %let k = %index(&repopt,EXP);
             %let repexp = %bquote(%substr(&repopt,&k));
             %let k1 = %index(&repexp,%str(%());
             %let k1 = %eval(&k1 + 1);
             %let repexp1 = %bquote(%substr(&repexp,&k1));
             %let k2 = %index(&repexp1,%str(%)));
             %let replst = &replst %substr(&repexp,&k1,
                %eval(&k2-1));
          %end;
          %let j = %index(&repopt,TYPE=SP);
          %if &j ne 0 %then %do;
             %let k = %index(&repopt,TYPE=SP);
             %let repexp = %bquote(%substr(&repopt,&k));
             %let k1 = %eval(%index(&repexp,%str(%))) + 1);
             %let repexp = %bquote(%substr(&repexp,&k1));
             %let k2 = %eval(%index(&repexp, %str(%()) + 1);
             %let k3 = %eval(%index(&repexp, %str(%))) - 1);
             %let replst = &replst %substr(&repexp,&k2,
                %eval(&k3-&k2+1));
          %end;
       %end;
       %let j = %eval(&i-&fn);
       %if &j > 0 %then 
          %let replst = &replst %substr(&stmt,&fn,&j);
    %end;

    /*---check ESTIMATE and LSMEANS options---*/
    %if %index(&first,ESTIMATE) and 
       (%index(&stmt,CL) or %index(&stmt,ALPHA)) %then %do;
       %let intopt = &intopt ESTCL;
    %end;
    %if %index(&first,LSMEANS) %then %do;
       %if %index(&stmt,CL) or %index(&stmt,ALPHA) %then %do;
          %let intopt = &intopt LSMCL;
       %end; 
       %if %index(&stmt,DIFF) or %index(&stmt,ADJ) %then %do;
          %let intopt = &intopt LSMDIFF;
       %end; 
       %if %index(&stmt,SLICE) %then %do;
          %let intopt = &intopt LSMSLICE;
       %end; 
    %end;

    /*---save statements---*/
    %if %index(&first,CLASS) %then %do;
       %let class = %qsubstr(&stmt,&fn);
    %end;
    %else %if %index(&first,MODEL) %then %do;
       %let model = %qsubstr(&stmt,&fn);
    %end;
    %else %if %index(&first,ID) %then %do;
       %let id = %qsubstr(&stmt,&fn);
    %end;
    %else %if %index(&first,PARMS) %then %do;
       %let parms = %qsubstr(&stmt,&fn);
    %end;
    %else %let spec = &spec &stmt %str(;) ;

    %let iv = %eval(&iv + 1);
 %end;

 /*---get response, model specification, and model options---*/
 %let response = %scan(&model,1,=);
 %let eqidx = %eval(%index(&model,=)+1);
 %if (&eqidx > %length(&model)) %then %let mdl = %str();
 %else %let mdl = %str( ) %qsubstr(&model,&eqidx);
 %if %index(&mdl,/) %then %do;
    %let mdlspec = %qscan(&mdl,1,/);  
    %let mdlopt = / %qscan(&mdl,2,/); 
    %if %index(&mdlopt,%str( S )) or %index(&mdlopt,SOLUTION) or
       %index(&mdlopt,CL) or %index(&mdlopt,ALPHA) %then %do;
       %let intopt = &intopt SOLNF;
    %end;
    %if %index(&options,HYBRID) %then %do;
       %let mdlopt = &mdlopt S OUTPM=_predm OUTP=_pred;
    %end;
    %else %if %index(&options,MQL) %then %do;
       %let mdlopt = &mdlopt S OUTPM=_pred;
    %end;
    %else %do;
       %let mdlopt = &mdlopt S OUTP=_pred;
    %end;
 %end;
 %else %do;
    %let mdlspec = &mdl;
    %if %index(&options,HYBRID) %then %do;
       %let mdlopt = / S OUTPM=_predm OUTP=_pred;
    %end; 
    %else %if %index(&options,MQL) %then %do;
       %let mdlopt = / S OUTPM=_pred;
    %end; 
    %else %do;
       %let mdlopt = / S OUTP=_pred; 
    %end;
 %end;
 %let mdlopt = &mdlopt alphap = &outalpha;

 /*---add an @ sign if it is missing---*/
 %if %index(&mdlspec,|) %then %do;
    %let mdl=&mdlspec;
    %let mdlspec=;
    %let i=1;
    %do %while(%length(%scan(&mdl,&i,' ')));
       %let mdlterm = %scan(&mdl,&i,' ');
       %if %index(&mdlterm,|) and %index(&mdlterm,@)=0 %then %do;
          %let j=1;
          %do %while(%length(%scan(&mdlterm,&j,|)));
           %let j = %eval(&j+1);
          %end;
          %let atvalue = %eval(&j-1);
          %let mdlterm = &mdlterm.@&atvalue;
       %end;
       %let mdlspec = &mdlspec &mdlterm;
       %let i = %eval(&i+1);
    %end;
 %end;
 
 /*---get parms specification, and parms options---*/
 %let parmopt2 = ;
 %if %index(&parms,/) %then %do;
    %let parmspec = %scan(&parms,1,/);
    %let parmopt = / %scan(&parms,2,/);
    %if not %index(&options,NOPREV) %then %do;
       %let parmopt2 = %scan(&parms,2,/);
       %let parmopt2 = %remove(%quote(&parmopt2),PARMSDATA);
       %let parmopt2 = %remove(%quote(&parmopt2),PDATA);
       %let parmopt2 = %remove(%quote(&parmopt2),OLS);
       %let parmopt2 = %remove(%quote(&parmopt2),RATIOS);
    %end;
 %end;
 %else %do;
    %let parmspec = %qupcase(&parms);
    %let parmopt  = ; 
 %end;

 %if %length(&linkn) %then %let intopt = &intopt NLIN;

 /*---create local variables---*/
 %local varlst errorfn linkfn varform devform etaform detaform 
    muform dmuform nlinform nlinder deviance scale n nb nu ns nus 
    crit conv cf intopt iter;

 /*---get variable list and trim it---*/
 %mvarlst
 %trimlst(varlst,&varlst);                 

 /*---set error and link function macro variables---*/
 %errlink

 /*---print header---*/
 %if not %index(&options,NOPRINT) %then %do;
    %if %index(&data,.)=0 %then %let data=WORK.&data;
    %put;
    %put %str(      ) The GLIMMIX Macro;
    %put;
    %put Data Set           : &data;
    %put Error Distribution : &errorfn;
    %put Link Function      : &linkfn;
    %put Response Variable  : &response;
    %if %length(&weight) %then
       %put Weight             : &weight;
    %if %length(&freq) %then
       %put Frequency          : &freq;
    %put;
    %put;
 %end;

 /*---initialize iteration starting values---*/
 %init

 /*---turn off printing---*/
 %if not %index(&options,PRINTALL) %then %do;
    ods exclude all;
 %end;

 /*---run first estimates for convergence tests---*/
 %mixed

 /*---iterate until convergence---*/
 %iterate

 /*---turn the printing back on---*/
 %if not %index(&options,PRINTALL) %then %do;
    ods select all;
 %end;

 /*---final Proc Mixed run---*/
 %if not %index(&options,NOPRINT) %then %do;
    %put;
    %put Output from final Proc Mixed run:;
    %mixed
 %end;

 /*---stop if did not converge---*/   
 %if &conv ne 1 %then %do; 
    %if not %index(&options,NOPRINT) %then %do;
       %put GLIMMIX did not converge.;
    %end;
 %end;
 /*---otherwise compile and print results---*/
 %else %do;
    %compile
    %if not %index(&options,NOPRINT) %then %do;
       %printout
    %end;
    /*---create output data set---*/
    %if %length(&outfile) %then %do;
       %outinfo(%quote(&outfile));
    %end;
 %end;

 %exit:;
 %if not %index(&options,NOTES) %then %do;
    options notes date number;
 %end;

 /*---title cleanup---*/
 &titlen;
 %if %length(&titlesas) %then %do;
    title "The SAS System";
 %end;
 %else %if &ntitle=10 %then title10 &title10;
  
%mend glimmix;
