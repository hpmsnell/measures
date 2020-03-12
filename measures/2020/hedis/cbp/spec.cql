library HEDIS_CBP_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CBP
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; Performance Met: G8752" //Systolic BP <140
valueset "MIPS; Performance Not Met: G8753" //Systolic BP >=140
valueset "MIPS; Performance Met: G8754" //Diastolic BP <90
valueset "MIPS; Performance Not Met: G8755" //Diastolic BP >=90
valueset "MIPS; Performance Met: G8783" //Normal BP
valueset "MIPS; Performance Met: G8950" //Hypertensive BP
valueset "MIPS; Performance Not Met: G8952" //Hypertensive BP

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Outpatient Without UBREV": '2.16.840.1.113883.3.464.1004.1203'
valueset "HEDIS; Essential Hypertension": '2.16.840.1.113883.3.464.1004.1122'
valueset "HEDIS; ESRD": '2.16.840.1.113883.3.464.1004.1089'
valueset "HEDIS; ESRD Obsolete": '2.16.840.1.113883.3.464.1004.1090'
valueset "HEDIS; Kidney Transplant": '2.16.840.1.113883.3.464.1004.1141'
valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Systolic Less Than 140": '2.16.840.1.113883.3.464.1004'
valueset "HEDIS; Systolic Greater Than or Equal To 140": '2.16.840.1.113883.3.464.1004'
valueset "HEDIS; Diastolic Less Than 80": '2.16.840.1.113883.3.464.1004.1084'
valueset "HEDIS; Diastolic 80-89": '2.16.840.1.113883.3.464.1004.1082'
valueset "HEDIS; Diastolic Greater Than or Equal To 90": '90,2.16.840.1.113883.3.464.1004.1083'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Dialysis Procedure": '2.16.840.1.113883.3.464.1004.1952'
valueset "HEDIS; Nephrectomy": '2.16.840.1.113883.3.464.1004.1909'
valueset "HEDIS; History of Kidney Transplant": '2.16.840.1.113883.3.464.1004.1908'
valueset "HEDIS; Remote Blood Pressure Monitoring": '2.16.840.1.113883.3.464.1004.1469'
valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'

// VSAC value test_set_keys

valueset "VSAC; Diastolic Blood Pressure": '2.16.840.1.113883.3.526.3.1033'
valueset "VSAC; Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]
  union ["Encounter, Performed": "HEDIS; Hospice Encounter"]

define "Encounter with Hypertension":
  ["Encounter, Performed": "HEDIS; Outpatient Without UBREV"] E
    with ["Diagnosis": "HEDIS; Essential Hypertension"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
        where E.relevantPeriod starts 2 years or less before end of "Measurement Period"	 

define "Distinct Dates of Telehealth Encounters with Hypertension":
    distinct(date from (
	    (["Encounter, Performed": "HEDIS; Telephone Visits"] 
	    union ["Encounter, Performed": "HEDIS; Online Assessments"] 
	    union ["Encounter, Performed": "HEDIS; Telehealth Modifier"] 
	    union ["Encounter, Performed": "HEDIS; Telehealth POS"]) E
	      with ["Diagnosis": "HEDIS; Essential Hypertension"] D
	        such that D.prevalencePeriod starts during E.relevantPeriod
	           where E.relevantPeriod starts 2 years or less before end of "Measurement Period"	   
   ))

define "Distinct Dates of Non-Telehealth Encounters with Hypertension":
    distinct(date from (
	    (["Encounter, Performed": "HEDIS; Outpatient Without UBREV"]) E
	      with ["Diagnosis": "HEDIS; Essential Hypertension"] D
	        such that D.prevalencePeriod starts during E.relevantPeriod
	           where E.relevantPeriod starts 2 years or less before end of "Measurement Period"
   ))
   
define "Count of Visits with Hypertension Diagnosis":
    //we only allow a max of ONE telehealth over the period - and we need to make sure it doesn't intersect with non-telehealth
    count(first("Distinct Dates of Telehealth Encounters with Hypertension" except "Distinct Dates of Non-Telehealth Encounters with Hypertension"))
    + count("Distinct Dates of Non-Telehealth Encounters with Hypertension")

define "Date of Second Hypertension Diagnosis":
  date from ((["Diagnosis": "HEDIS; Essential Hypertension"])[1])

define "Encounters On or After Second Hypertension Diagnosis":
  (["Encounter, Performed": "HEDIS; Outpatient Without UBREV"] 
    union ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"]
    union ["Encounter, Performed": "HEDIS; Outpatient Without UBREV"]
    union ["Encounter, Performed": "HEDIS; Remote Blood Pressure Monitoring"] //this is likely a procedure and NOT an encounter
    ) E
      where E.relevantPeriod starts on or after "Date of Second Hypertension Diagnosis"
      and E.relevantPeriod overlaps "Measurement Period"

define "ESRD Procedure":
  ["Procedure, Performed": "HEDIS; ESRD"]
  union ["Procedure, Performed": "HEDIS; ESRD Obsolete"]
  union ["Procedure, Performed": "HEDIS; Kidney Transplant"]
  union ["Procedure, Performed": "HEDIS; Dialysis Procedure"]
  union ["Procedure, Performed": "HEDIS; Nephrectomy"]
  union ["Procedure, Performed": "HEDIS; History of Kidney Transplant"]

define "Nonacute Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]

define "Systolic Blood Pressure":
  ["Assessment, Performed": "VSAC; Systolic Blood Pressure"]
  union ["Procedure, Performed": "HEDIS; Systolic Less Than 140"]
  union ["Procedure, Performed": "HEDIS; Systolic Greater Than or Equal To 140"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8752"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8753"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8783"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8950"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8952"]

define "Normal Systolic Blood Pressure Procedure":
  ["Procedure, Performed": "HEDIS; Systolic Less Than 140"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8752"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8783"]

define "Most Recent Systolic":
  Last("Systolic Blood Pressure" A
    with "Encounters On or After Second Hypertension Diagnosis" E
      such that A.authorDateTime during E.relevantPeriod
    where A.authorDateTime during "Measurement Period"
    sort by A.authorDateTime desc)

define "Diastolic Blood Pressure":
  ["Assessment, Performed": "VSAC; Diastolic Blood Pressure"]
  union ["Procedure, Performed": "HEDIS; Diastolic Less Than 80"]
  union ["Procedure, Performed": "HEDIS; Diastolic 81-89"]
  union ["Procedure, Performed": "HEDIS; Diastolic Greater Than or Equal To 90"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8754"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8755"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8783"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8950"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8952"]

define "Normal Diastolic Blood Pressure Procedure":
  ["Procedure, Performed": "HEDIS; Diastolic Less Than 80"]
  union ["Procedure, Performed": "HEDIS; Diastolic 81-89"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8754"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8783"]

define "Most Recent Diastolic":
  Last("Diastolic Blood Pressure" A
    with "Encounters On or After Second Hypertension Diagnosis" E
      such that A.authorDateTime during E.relevantPeriod
    where A.authorDateTime during "Measurement Period"
    sort by A.authorDateTime desc)

define "Blood Pressure Days":
  ( 
    ( "Most Recent Diastolic" DBPExam
      return date from DBPExam.authorDatetime)
    intersect 
    ( "Most Recent Diastolic" SBPExam 
      return date from SBPExam.authorDatetime)
  )

define "Most Recent Blood Pressure Days":
  Last("Blood Pressure Days" BPDays sort by BPDays.authorDateTime desc)

define "Lowest Diastolic Reading on Most Recent Blood Pressure Day":
  First("Qualifying Diastolic Blood Pressure Reading" DBPReading
    where DBPReading.authorDatetime same day as "Most Recent Blood Pressure Day"
    sort by(result as Quantity)
  )
  
define "Lowest Systolic Reading on Most Recent Blood Pressure Day":
  First("Qualifying Systolic Blood Pressure Reading" SBPReading
    where SBPReading.authorDatetime same day as "Most Recent Blood Pressure Day"
    sort by(result as Quantity)
  )


define "Systolic Blood Pressure < 140":
  exists("Lowest Systolic Reading on Most Recent Blood Pressure Day" A1
    with ["Assessment, Performed": "VSAC; Systolic Blood Pressure"] A2
      such that A2.authorDateTime same day as A1.authorDateTime
        and A2.result < 140)
  or exists("Lowest Systolic Reading on Most Recent Blood Pressure Day" A1
    with "Normal Systolic Blood Pressure Procedure" A2
      such that A2.authorDateTime same day as A1.authorDateTime)

define "Diastolic Blood Pressure < 90":
  exists("Lowest Diastolic Reading on Most Recent Blood Pressure Day" A1
    with ["Assessment, Performed": "VSAC; Diastolic Blood Pressure"] A2
      such that A2.authorDateTime same day as A1.authorDateTime
        and A2.result < 90)
  or exists("Lowest Diastolic Reading on Most Recent Blood Pressure Day" A1
    with "Normal Diastolic Blood Pressure Procedure" A2
      such that A2.authorDateTime same day as A1.authorDateTime)

define "Blood Pressure < 140/90":
  "Systolic Blood Pressure < 140"
  and "Diastolic Blood Pressure < 90"

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 86
  and exists("Encounter with Hypertension")
  and "Count of Visits with Hypertension Diagnosis" >= 2 
  and not exists("Hospice" I
    where I.relevantPeriod overlaps "Measurement Period")

define "Denominator Exclusion: ESRD":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "HEDIS; ESRD"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists("ESRD Procedure" P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Denominator Exclusion: Pregnancy":
  /*
   * config_link_id: exclusion_2
   */
  exists (["Patient Characteristic Sex": "Female"])
  and exists(["Diagnosis": "HEDIS; Pregnancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion: Inpatient Visit":
  /*
   * config_link_id: exclusion_3
   */
  exists(["Encounter, Performed": "HEDIS; Inpatient Stay"] E1
    with ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] E2
      such that E2.relevantPeriod overlaps E1.relevantPeriod
        where E1.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Blood Pressure < 140/90" 

define "Numerator Performance Not Met: Out of Range":
  /*
   * config_link_id: out_of_range
   */
  exists("Systolic Blood Pressure" A
    where A.authorDateTime during "Measurement Period")
  and exists("Diastolic Blood Pressure" A
    where A.authorDateTime during "Measurement Period")

define "Numerator Performance Not Met: No Blood Pressure":
  /*
   * config_link_id: no_blood_pressure
   */
  not "Denominator Exclusion: ESRD"
  and not "Denominator Exclusion: Pregnancy"
  and not "Denominator Exclusion: Inpatient Visit"
  and not "Numerator Performance Met"
  and not "Numerator Performance Not Met: Out of Range"
