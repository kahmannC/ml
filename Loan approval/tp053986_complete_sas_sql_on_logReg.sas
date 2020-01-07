/* Name of Data Scientist: Choong Kah Mann */
/* Name of Program: tp053986_complete_sas_sql_on_logReg.sas */
/* Description: To build logistic regression model*/
/* Date First Written: Monday, 18-Nov-2019 */
/* Date Last Modified: Saturday, 21-Nov-2019 */

/* Getting training set */
DATA TP053986.MISSDATA_MY_LOAN_TRAIN_DS; /* Creating new dataset named MISSDATA_MY_LOAN_TRAIN_DS that stored all the missing values*/
   SET TP053986.SEP2019_MY_LOAN_TRAIN_DS END = eof;
   
   NumberOfCount + 1;
   array num[*] _numeric_;
   array char[*] _character_;
   array n_count[100] _temporary_ (100*0); * Assuming data set has no more than 100 OBS;
   array c_count[100] _temporary_ (100*0);
   do i = 1 to dim(num);
      if missing(num[i]) then n_count[i] + 1;
   end;
   do i = 1 to dim(char);
      if missing(char[i]) then c_count[i] + 1;
   end;
   if eof then do;
      do i = 1 to dim(num);
         Variable = vname(num[i]);
         N_MissingVal = n_count[i];
         output;
      end;
      do i = 1 to dim(char);
         Variable = vname(char[i]);
         N_MissingVal = c_count[i];
         output;
      end;
   end;
keep Variable NumberOfCount N_MissingVal; /* This will retrieve variable name and number of missing columns*/

RUN;

/* Getting testing set */
DATA TP053986.MISSDATA_MY_LOAN_TEST_DS; /* Creating new dataset named MISSDATA_MY_LOAN_TEST_DS that stored all the missing values*/
   SET TP053986.SEP2019_MY_LOAN_TEST_DS END = eof;
   
   NumberOfCount + 1;
   array num[*] _numeric_;
   array char[*] _character_;
   array n_count[100] _temporary_ (100*0); * Assuming data set has no more than 100 OBS;
   array c_count[100] _temporary_ (100*0);
   do i = 1 to dim(num);
      if missing(num[i]) then n_count[i] + 1;
   end;
   do i = 1 to dim(char);
      if missing(char[i]) then c_count[i] + 1;
   end;
   if eof then do;
      do i = 1 to dim(num);
         Variable = vname(num[i]);
         N_MissingVal = n_count[i];
         output;
      end;
      do i = 1 to dim(char);
         Variable = vname(char[i]);
         N_MissingVal = c_count[i];
         output;
      end;
   end;
keep Variable NumberOfCount N_MissingVal; /* This will retrieve variable name and number of missing columns*/

RUN;

/* Viewing missing values from the trianing set*/
PROC SQL;

Title 'List only missing values on training set'; /* List of missing values */
SELECT * FROM TP053986.MISSDATA_MY_LOAN_TRAIN_DS ORDER BY Variable ASC;

QUIT;

/* Viewing missing values from the testing set*/
PROC SQL;

Title 'List only missing values on testing set'; /* List of missing values */
SELECT * FROM TP053986.MISSDATA_MY_LOAN_TEST_DS ORDER BY Variable ASC;

QUIT;

/* Building the logistic Regression Model*/
PROC LOGISTIC DATA = TP053986.SEP2019_MY_LOAN_TRAIN_DS OUTMODEL = TP053986.SEP2019_MY_LOAN_TRAIN_DS_MODEL;
CLASS EMPLOYMENT
      FAMILY_MEMBERS
      GENDER
      LOAN_DURATION
      LOAN_HISTORY
      LOAN_LOCATION               /* independent variable with categorical input*/
      MARITAL_STATUS
      QUALIFICATION;
 
MODEL LOAN_APPROVAL_STATUS = CANDIDATE_INCOME    /* Target variable vs predictor(s)*/
      						 EMPLOYMENT			 
      						 FAMILY_MEMBERS
      						 GENDER
      						 GUARANTEE_INCOME
      						 LOAN_AMOUNT
      						 LOAN_DURATION
      						 LOAN_HISTORY
      						 LOAN_LOCATION
      						 MARITAL_STATUS
      						 QUALIFICATION;
      						 
OUTPUT OUT = TP053986.SEP2019_MY_LOAN_TRAIN_DS P = PREDICTOR_PROBABILITY; /* predictor probability as new variable in training set*/

RUN;

/* Printing the logistic regression model*/
PROC PRINT DATA = TP053986.SEP2019_MY_LOAN_TRAIN_DS_MODEL;
RUN;

/* Printing the training set*/
PROC PRINT DATA = TP053986.SEP2019_MY_LOAN_TRAIN_DS;
RUN;

/* Fitting the model into testing set*/
PROC LOGISTIC INMODEL = TP053986.SEP2019_MY_LOAN_TRAIN_DS_MODEL; /* Logistic Regression model has been built on training set*/
SCORE DATA = TP053986.SEP2019_MY_LOAN_TEST_DS /* Fit into testing set*/
OUT = TP053986.SEP2019_MY_LOAN_PREDICTORS_DS; /* Creating new dataset as prediction*/
QUIT;

/* Viewing observations of loan prediction*/
PROC SQL;

TITLE 'Viewing observations of loan prediction';
SELECT SME_LOAN_ID_NO LABEL 'SME Loan Id No',
	   I_LOAN_APPROVAL_STATUS LABEL 'Approval Status',
	   P_N LABEL 'Probability predicted as No',
	   P_Y LABEL 'Probability predicted as Yes'
	   FROM TP053986.SEP2019_MY_LOAN_PREDICTORS_DS;
	   
QUIT;

/* Exporting loan prediction dataset*/
PROC SQL;

  CREATE TABLE TP053986.SME_FINAL_LOGISTICREG_PREDICTON AS

  (  
     SELECT  SME_LOAN_ID_NO LABEL 'SME Loan Id No',
			 I_LOAN_APPROVAL_STATUS LABEL 'Approval Status',
			 P_N LABEL 'Probability predicted as No',
			 P_Y LABEL 'Probability predicted as Yes'
	 FROM TP053986.SEP2019_MY_LOAN_PREDICTORS_DS 
  );

QUIT;

/* Export final model prediction*/
PROC EXPORT data= TP053986.SME_FINAL_LOGISTICREG_PREDICTON /* Export final model prediction*/
outfile='/home/u38233190/DAP_ASSIGNMENT_TP053986_SEP_2019/cleaned_dataset/SME_FINAL_LOGISTICREG_PREDICTON.csv'
dbms=csv
replace;
RUN;
