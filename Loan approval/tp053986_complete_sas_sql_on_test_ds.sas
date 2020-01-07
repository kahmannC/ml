/* Name of Data Scientist: Choong Kah Mann */
/* Name of Program: tp053986_complete_sas_sql_on_test_ds.sas */
/* Description: To check and do missing values treatment on testing set*/
/* Date First Written: Thursday, 14-Nov-2019 */
/* Date Last Modified: Sunday, 17-Nov-2019 */

/* Getting the dataset while not modifying original dataset */
DATA TP053986.SEP2019_MY_LOAN_TEST_DS;
SET TP053986.MYLOAN_SME_TEST_ACT;
RUN;

PROC CONTENTS DATA = TP053986.SEP2019_MY_LOAN_TEST_DS;
RUN;

/* To view observation from the newly created dataset - TP053986.SEP2019_MY_LOAN_TEST_DS*/
PROC PRINT DATA = TP053986.SEP2019_MY_LOAN_TEST_DS;
TITLE 'To view observation from the newly created dataset - TP053986.SEP2019_MY_LOAN_TEST_DS';
RUN;

DATA TP053986.SEP2019_MY_LOAN_TEST_DS; /* Rename candidate income*/
  SET TP053986.SEP2019_MY_LOAN_TEST_DS(RENAME=  (CANDIATE_INCOME= CANDIDATE_INCOME));
RUN;

/* Begin Data Exploration on testing set*/
/* Check missing values */
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

/* Listing only variable that has missing value in the dataset (MISSDATA_MY_LOAN_TEST_DS) before missing value imputation
  which we have created on previous step */
PROC SQL;

Title 'List only missing values in the testing set before imputing missing value'; /* List of missing values */
SELECT * FROM TP053986.MISSDATA_MY_LOAN_TEST_DS ORDER BY Variable ASC;

QUIT;

/* Missing value imputation in testing set*/
/* Employment*/
/* Creating temporary employment missing dataset for missing value imputation */
PROC SQL;

/* Creating temporary employment missing dataset */
  CREATE TABLE TP053986.TEMP_MS_EMPLOYMENT_Ds AS

  (

   SELECT EMPLOYMENT LABEL 'Employment', 
   COUNT( EMPLOYMENT ) AS Count
   FROM TP053986.SEP2019_MY_LOAN_TEST_DS WHERE ( EMPLOYMENT IS NOT MISSING ) GROUP BY EMPLOYMENT

  )

  ORDER BY EMPLOYMENT DESC;

QUIT;

/* Getting observation from employment temporary table*/
PROC SQL;

TITLE 'Viewing observation of employment with highest frequency';
SELECT * FROM TP053986.TEMP_MS_EMPLOYMENT_Ds;

QUIT;

/* Treat missing value (Employment) with mode. */

/* Getting Employment by mode*/
PROC SQL;

TITLE 'Getting Employment by Mode';
SELECT EMPLOYMENT FROM TP053986.TEMP_MS_EMPLOYMENT_Ds
WHERE COUNT = 
( SELECT MAX(COUNT) LABEL 'Highest Number of Employment' FROM TP053986.TEMP_MS_EMPLOYMENT_Ds) ; /* Retrieve employment when it is mode*/

QUIT;

/*Begin missing value imputation: Update with mode to employment which is found empty on SEP2019_MY_LOAN_TEST_DS dataset */ 
PROC SQL;

UPDATE TP053986.SEP2019_MY_LOAN_TEST_DS
SET EMPLOYMENT = CASE

/* Update employment only if it is empty */
WHEN EMPLOYMENT = '' THEN
( SELECT EMPLOYMENT FROM TP053986.TEMP_MS_EMPLOYMENT_Ds WHERE COUNT = 
( SELECT MAX(COUNT) LABEL 'Highest Number of Employment' FROM TP053986.TEMP_MS_EMPLOYMENT_Ds) /* Retrieve EMPLOYMENT when it is mode*/ )

ELSE EMPLOYMENT
END;

QUIT;

/* Select dataset to see if employment still have missing values*/
PROC SQL;

TITLE 'Getting employment frequency table from SEP2019_MY_LOAN_TEST_DS';
SELECT employment LABEL 'Employment', 
       COUNT(EMPLOYMENT) LABEL 'Total number of employment' 
       FROM TP053986.SEP2019_MY_LOAN_TEST_DS GROUP BY EMPLOYMENT;

TITLE 'Getting employment from original dataset (Before backup)';
SELECT EMPLOYMENT LABEL 'Employment', 
       COUNT(EMPLOYMENT) LABEL 'Total number of employment' 
       FROM TP053986.MYLOAN_SME_TEST_ACT GROUP BY EMPLOYMENT;

QUIT;

/* 2. Gender*/

/* Creating temporary gender missing dataset for missing value imputation */
PROC SQL;

/* Creating temporary gender missing dataset */
  CREATE TABLE TP053986.TEMP_MS_GENDER_DS AS

  (

   SELECT GENDER LABEL 'Gender', 
   COUNT( GENDER ) AS Count
   FROM TP053986.SEP2019_MY_LOAN_TEST_DS WHERE ( GENDER IS NOT MISSING ) GROUP BY GENDER

  )

  ORDER BY GENDER DESC;

QUIT;

/* Getting observation from gender temporary table*/
PROC SQL;

TITLE 'Viewing observation of gender with highest frequency';
SELECT * FROM TP053986.TEMP_MS_GENDER_DS;

QUIT;

/* Based on the analysis, male has the highest frequency in variable gender, 
	therefore we will impute missing value with male*/

/* Treat missing value (Gender) with mode. */

/* Getting Gender by mode*/
PROC SQL;

TITLE 'Getting Gender with highest frequency';
SELECT GENDER FROM TP053986.TEMP_MS_GENDER_DS
WHERE COUNT = 
( SELECT MAX(COUNT) LABEL 'Highest Number of Gender' FROM TP053986.TEMP_MS_GENDER_DS) ; /* Retrieve employment when it is mode*/

QUIT;

/*Begin missing value imputation: Update with mode to gender which is found empty on SEP2019_MY_LOAN_TEST_DS dataset */ 
PROC SQL;

UPDATE TP053986.SEP2019_MY_LOAN_TEST_DS
SET GENDER = CASE

/* Update gender only if it is empty */
WHEN GENDER = '' THEN
( SELECT GENDER FROM TP053986.TEMP_MS_GENDER_Ds WHERE COUNT = 
( SELECT MAX(COUNT) LABEL 'Highest Number of GENDER' FROM TP053986.TEMP_MS_GENDER_Ds) /* Retrieve GENDER when it is mode*/ )

ELSE GENDER
END;

QUIT;

/* Select dataset to see if gender still have missing values*/
PROC SQL;

TITLE 'Getting gender frequency table from SEP2019_MY_LOAN_TEST_DS';
SELECT gender LABEL 'Gender', 
       COUNT(GENDER) LABEL 'Total number of gender' 
       FROM TP053986.SEP2019_MY_LOAN_TEST_DS GROUP BY GENDER;

TITLE 'Getting gender from original dataset (Before backup)';
SELECT GENDER LABEL 'Gender', 
       COUNT(GENDER) LABEL 'Total number of gender' 
       FROM TP053986.MYLOAN_SME_TEST_ACT GROUP BY GENDER;

QUIT;

 /* 3. Loan duration*/

/* Creating temporary loan duration missing dataset for missing value imputation in loan_duration*/
PROC SQL;

/* Creating temporary loan duration missing dataset */
  CREATE TABLE TP053986.TEMP_MS_LOAN_DURATION_DS AS

  (

   SELECT LOAN_DURATION LABEL 'Loan Duration', 
   COUNT( LOAN_DURATION ) AS Count
   FROM TP053986.SEP2019_MY_LOAN_TEST_DS WHERE ( LOAN_DURATION IS NOT MISSING ) GROUP BY LOAN_DURATION

  )

  ORDER BY LOAN_DURATION DESC;

QUIT;

/* Getting observation from loan duration temporary table*/
PROC SQL;

TITLE 'Viewing observation of loan duration with highest frequency';
SELECT * FROM TP053986.TEMP_MS_LOAN_DURATION_DS ORDER BY COUNT DESC;

QUIT;

/* Based on the analysis, 360 has the highest frequency in variable loan duration, 
	therefore we will impute missing value with 360*/

/* Treat missing value (Loan Duration) with mode. */

/* Getting Loan Duration by mode - 360*/
PROC SQL;

TITLE 'Getting Loan Duration with Highest Frequency';
SELECT LOAN_DURATION FROM TP053986.TEMP_MS_LOAN_DURATION_DS
WHERE COUNT = 
	( SELECT MAX(COUNT) LABEL 'Highest Number of Loan Duration' 
	  FROM TP053986.TEMP_MS_LOAN_DURATION_DS) ; /* Retrieve loan duration when it is mode*/

QUIT;

/*Begin missing value imputation: Update with mode to loan duration which is found empty on SEP2019_MY_LOAN_TEST_DS dataset */ 
PROC SQL;

UPDATE TP053986.SEP2019_MY_LOAN_TEST_DS
SET loan_duration = CASE

/* Update loan duration only if it is empty */
WHEN loan_duration EQ input('', 18.) THEN
( SELECT loan_duration FROM TP053986.TEMP_MS_LOAN_DURATION_DS 
WHERE COUNT = 
				( SELECT MAX(COUNT) LABEL 'Highest Number of Loan Duration' 
				  FROM TP053986.TEMP_MS_LOAN_DURATION_DS ) /* Retrieve loan duration when it is mode*/ )

ELSE loan_duration /* Remain unchange with loan duration */
END;

QUIT;

/* Verify if data is updated correctly: Select dataset to see if loan duration from SEP2019_MY_LOAN_TEST_DS has missing values*/
PROC SQL;

TITLE 'Getting loan duration frequency table from TP053986.SEP2019_MY_LOAN_TEST_DS';
SELECT loan_duration LABEL 'Loan Duration', 
       COUNT(loan_duration) LABEL 'Total number of Loan Duration' 
       FROM TP053986.SEP2019_MY_LOAN_TEST_DS GROUP BY loan_duration;

TITLE 'Getting loan duration from original dataset';
SELECT loan_duration LABEL 'Loan Duration', 
       COUNT(loan_duration) LABEL 'Total number of Loan Duration (before backup)'
       FROM TP053986.MYLOAN_SME_TEST_ACT GROUP BY loan_duration;

QUIT;

/* 4. Loan History*/

/* Creating temporary loan history missing dataset for missing value imputation */
PROC SQL;

/* Creating temporary loan history missing dataset */
  CREATE TABLE TP053986.TEMP_MS_LOAN_HISTORY_DS AS

  (

   SELECT LOAN_HISTORY LABEL 'Loan History', 
   COUNT( LOAN_HISTORY ) AS Count
   FROM TP053986.SEP2019_MY_LOAN_TEST_DS WHERE ( LOAN_HISTORY IS NOT MISSING ) GROUP BY LOAN_HISTORY

  )

  ORDER BY LOAN_HISTORY DESC;

QUIT;		

/* Getting observation from loan history temporary table*/
PROC SQL;

TITLE 'Viewing observation of loan history with highest frequency';
SELECT * FROM TP053986.TEMP_MS_LOAN_HISTORY_DS;

QUIT;

/* Based on the analysis, 1 has the highest frequency in variable loan history, 
	therefore we will impute missing value with 1*/

/* Treat missing value (Loan History) with mode. */

/* Getting Loan History by mode - 1*/
PROC SQL;

TITLE 'Getting loan history with highest frequency';
SELECT LOAN_HISTORY FROM TP053986.TEMP_MS_LOAN_HISTORY_DS
WHERE COUNT = 
				( SELECT MAX(COUNT) LABEL 'Highest Number of Loan History' 
				  FROM TP053986.TEMP_MS_LOAN_HISTORY_DS) ; /* Retrieve loan history when it is mode*/

QUIT;

/*Begin missing value imputation: Update with mode to loan history which is found empty on SEP2019_MY_LOAN_TEST_DS dataset */ 
PROC SQL;

UPDATE TP053986.SEP2019_MY_LOAN_TEST_DS
SET loan_history = CASE

/* Update loan history only if it is empty */
WHEN loan_history EQ input('', 18.) THEN
( SELECT loan_history FROM TP053986.TEMP_MS_LOAN_HISTORY_DS WHERE COUNT = 
( SELECT MAX(COUNT) LABEL 'Highest Number of Loan HISTORY' FROM TP053986.TEMP_MS_LOAN_HISTORY_DS ) /* Retrieve loan_history when it is mode*/ )

ELSE loan_history /* Remain unchange with loan history */
END;

QUIT;

/* Verify if data is updated correctly: Select dataset to see if loan history from SEP2019_MY_LOAN_TEST_DS has missing values*/
PROC SQL;

TITLE 'Getting loan history frequency table from TP053986.SEP2019_MY_LOAN_TEST_DS';
SELECT loan_history LABEL 'Loan History', 
       COUNT(loan_history) LABEL 'Total number of Loan History' 
       FROM TP053986.SEP2019_MY_LOAN_TEST_DS GROUP BY loan_history;

TITLE 'Getting loan history from original dataset';
SELECT loan_history LABEL 'Loan History', 
       COUNT(loan_history) LABEL 'Total number of Loan History (before backup)'
       FROM TP053986.MYLOAN_SME_TEST_ACT GROUP BY loan_history;

QUIT;

/* 5. Family Members */

/* Getting variable (family members) frequency */
PROC SQL;

TITLE 'Getting variable (family members) frequency';
SELECT FAMILY_MEMBERS LABEL 'Family Members', 
	   count(FAMILY_MEMBERS) 'Number of Family Members'
FROM TP053986.SEP2019_MY_LOAN_TEST_DS GROUP BY FAMILY_MEMBERS; /* Despite having missing values, it may also have inconsistent data */

QUIT;

/* Replacing family members by first digit */
PROC SQL;

UPDATE TP053986.SEP2019_MY_LOAN_TEST_DS 

SET FAMILY_MEMBERS = substring(FAMILY_MEMBERS from 0 for 2);

QUIT;

/* Get variable family members to see if there are still inconsistent data*/
PROC SQL;

TITLE 'Getting variable (family members) frequency after inconsistent data treatment';
SELECT FAMILY_MEMBERS LABEL 'Family Members', 
	   count(FAMILY_MEMBERS) 'Number of Family Members'
FROM TP053986.SEP2019_MY_LOAN_TEST_DS GROUP BY FAMILY_MEMBERS; 

QUIT;

/* Creating temporary family members missing dataset for missing value imputation */
PROC SQL;

/* Creating temporary family members missing dataset */
  CREATE TABLE TP053986.TEMP_MS_FAMILY_MEMBERS_DS AS

  (

   SELECT FAMILY_MEMBERS LABEL 'Family Members', 
   COUNT( FAMILY_MEMBERS ) AS Count
   FROM TP053986.SEP2019_MY_LOAN_TEST_DS WHERE ( FAMILY_MEMBERS IS NOT MISSING ) GROUP BY FAMILY_MEMBERS

  )

  ORDER BY FAMILY_MEMBERS DESC;

QUIT;

/* Getting observation from family members temporary table*/
PROC SQL;

TITLE 'Viewing observation of family members with highest frequency';
SELECT * FROM TP053986.TEMP_MS_FAMILY_MEMBERS_DS ORDER BY COUNT DESC;

QUIT;

/* Based on the analysis, 0 has the highest frequency in variable family members, 
	therefore we will impute missing value with 0*/

/* Treat missing value (Family Members) with mode. */

/* Getting Family Members by mode - 0*/
PROC SQL;

TITLE 'Getting family members with highest frequency';
SELECT FAMILY_MEMBERS FROM TP053986.TEMP_MS_FAMILY_MEMBERS_DS
WHERE COUNT = 
				( SELECT MAX(COUNT) LABEL 'Highest Number of Family Members' 
				  FROM TP053986.TEMP_MS_FAMILY_MEMBERS_DS) ; /* Retrieve family members when it is mode*/

QUIT;

/*Begin missing value imputation: Update with mode to family members which is found empty on SEP2019_MY_LOAN_TEST_DS dataset */ 
PROC SQL;

UPDATE TP053986.SEP2019_MY_LOAN_TEST_DS
SET FAMILY_MEMBERS = CASE

/* Update employment only if it is empty */
WHEN FAMILY_MEMBERS = '' THEN
( SELECT FAMILY_MEMBERS FROM TP053986.TEMP_MS_FAMILY_MEMBERS_DS
  WHERE COUNT = 
				( SELECT MAX(COUNT) LABEL 'Highest Number of Family Members' 
				  FROM TP053986.TEMP_MS_FAMILY_MEMBERS_DS) /* Retrieve family members when it is mode*/ )

ELSE FAMILY_MEMBERS
END;

QUIT;

/* Verify if data is updated correctly: Select dataset to see if family members from SEP2019_MY_LOAN_TEST_DS has missing values*/
PROC SQL;

TITLE 'Getting family members frequency table from TP053986.SEP2019_MY_LOAN_TEST_DS';
SELECT FAMILY_MEMBERS LABEL 'Family Members', 
       COUNT(FAMILY_MEMBERS) LABEL 'Total number of Family Members' 
       FROM TP053986.SEP2019_MY_LOAN_TEST_DS GROUP BY FAMILY_MEMBERS;

TITLE 'Getting loan history from original dataset';
SELECT FAMILY_MEMBERS LABEL 'Family Members', 
       COUNT(FAMILY_MEMBERS) LABEL 'Total number of Family Members (before backup)'
       FROM TP053986.MYLOAN_SME_TEST_ACT GROUP BY FAMILY_MEMBERS;

QUIT;

/* 7. Loan Amount*/

/* Listing only variable that has missing value in the dataset (MISSDATA_MY_LOAN_TRAIN_DS) 
  which we have created on previous step */
PROC SQL;

Title 'List only missing values'; /* List of missing values */
SELECT * FROM TP053986.MISSDATA_MY_LOAN_TEST_DS WHERE ( N_MissingVal > 0 AND VARIABLE EQ 'LOAN_AMOUNT' ) 
ORDER BY Variable ASC;

QUIT;

/* Create a dataset that stored all the interquartile range and median that will be used for outliers treatment in the next step. */
PROC UNIVARIATE DATA = TP053986.SEP2019_MY_LOAN_TEST_DS;

VAR LOAN_AMOUNT;
OUTPUT OUT = TP053986.DS_LOAN_AMOUNT_IR_RANGE MEAN= MEAN MODE = MODE MEDIAN = MEDIAN PCTLPTS = 25, 95 PCTLPRE = IR_RANGE;

RUN;

/* Treat missing values by putting median */
PROC SQL;

TITLE 'Getting median from loan amount';
SELECT MEDIAN LABEL 'Loan Amount Median' FROM TP053986.DS_LOAN_AMOUNT_IR_RANGE;

QUIT;

/*Begin missing value imputation: Replacing median to missing value, 
	median is more appropriate when data has outlier*/ 
PROC SQL;

UPDATE TP053986.SEP2019_MY_LOAN_TEST_DS
SET LOAN_AMOUNT = CASE

/* Update loan amount when loan amount is found empty (-1) */
WHEN LOAN_AMOUNT IS MISSING 
THEN ( SELECT MEDIAN LABEL 'Loan Amount Median' FROM TP053986.DS_LOAN_AMOUNT_IR_RANGE )

ELSE LOAN_AMOUNT
END; 

QUIT;

/* Select dataset to see if loan amount still have missing values*/
PROC SQL;

TITLE 'Getting loan amount frequency table from SEP2019_MY_LOAN_TEST_DS';
SELECT LOAN_AMOUNT LABEL 'Loan Amount'
       FROM TP053986.SEP2019_MY_LOAN_TEST_DS WHERE ( LOAN_AMOUNT IS MISSING );

TITLE 'Getting gender from original dataset (Before backup)';
SELECT LOAN_AMOUNT LABEL 'Loan Amount'
	   FROM TP053986.MYLOAN_SME_TEST_ACT WHERE ( LOAN_AMOUNT IS MISSING );

QUIT;

/* Check missing values again after missing value imputation*/
DATA TP053986.MISSDATA_MY_LOAN_TEST_DS_2; /* Creating new dataset named MISSDATA_MY_LOAN_TEST_DS_2 that stored all the missing values*/
										   /* 2 indicate second check*/
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

/* Listing only variable that has missing value in the dataset (MISSDATA_MY_LOAN_TEST_DS_2) 
  which we have created on previous step */
PROC SQL;
Title 'List only missing values (Before missing value imputation) - MISSDATA_MY_LOAN_TEST_DS'; /* List of missing values */
SELECT * FROM TP053986.MISSDATA_MY_LOAN_TEST_DS WHERE ( N_MissingVal > 0 )  ORDER BY Variable ASC;

Title 'List only missing values (After missing value imputation imputation) - MISSDATA_MY_LOAN_TEST_DS_2'; /* List of missing values */
SELECT * FROM TP053986.MISSDATA_MY_LOAN_TEST_DS_2 WHERE ( N_MissingVal > 0 )  ORDER BY Variable ASC;

QUIT;

/* Check the missing value again on the testing set after missing value imputation*/
DATA TP053986.MISSDATA_MY_LOAN_TEST_DS; /* Recreating new dataset named MISSDATA_MY_LOAN_TEST_DS that stored all the missing values*/
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

/* Listing only variable that has missing value in the dataset (MISSDATA_MY_LOAN_TEST_DS) after imputation
  which we have created on previous step */
PROC SQL;

Title 'List only missing values in the testing set after imputing missing value'; /* List of missing values */
SELECT * FROM TP053986.MISSDATA_MY_LOAN_TEST_DS ORDER BY Variable ASC;

QUIT;

/* Export cleaned dataset*/
PROC EXPORT data=TP053986.SEP2019_MY_LOAN_TEST_DS /* Export cleaned testing set*/
OUTFILE='/home/u38233190/DAP_ASSIGNMENT_TP053986_SEP_2019/cleaned_dataset/SEP2019_MY_LOAN_TEST_DS_CLEANED.csv'
DBMS=csv
REPLACE;
RUN;

