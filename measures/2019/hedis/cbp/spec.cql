library HEDIS_CBP_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: CBP
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// MIPS value sets

valueset "MIPS; Performance Met: G8752" //Systolic BP <140
valueset "MIPS; Performance Not Met: G8753" //Systolic BP >=140
valueset "MIPS; Performance Met: G8754" //Diastolic BP <90
valueset "MIPS; Performance Not Met: G8755" //Diastolic BP >=90
valueset "MIPS; Performance Met: G8783" //Normal BP
valueset "MIPS; Performance Met: G8950" //Hypertensive BP
valueset "MIPS; Performance Not Met: G8952" //Hypertensive BP

// HEDIS value sets

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

// VSAC value test_set_keys

valueset "VSAC; Diastolic Blood Pressure": '2.16.840.1.113883.3.526.3.1033'
valueset "VSAC; Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
  we need to count the DISTINCT DATES of service for the following criteria

  Members who had at least two visits on different dates of service
  with a diagnosis of hypertension
  during the measurement year or the year prior to the measurement year
  (count services that occur over both years).
*/
define "Distinct Dates of Telehealth Encounters with Hypertension":
   distinct(((
     (
       /*
       •	A telephone visit (Telephone Visits Value Set) with any diagnosis of hypertension (Essential Hypertension Value Set).
       •	An online assessment (Online Assessments Value Set) with any diagnosis of hypertension (Essential Hypertension Value Set).
       */
       //telephone visits or online assessments
      ((["Encounter, Performed": "HEDIS; Telephone Visits"]
	     union ["Encounter, Performed": "HEDIS; Online Assessments"]
      ) TelephoneOrOnlineEncounters
      with ["Diagnosis": "HEDIS; Essential Hypertension"] D
        such that D.claimId = TelephoneOrOnlineEncounters.claimId
        or (
          end of TelephoneOrOnlineEncounters.relevantPeriod != null
          and start of D.prevalencePeriod during TelephoneOrOnlineEncounters.relevantPeriod
        )
        or (
          TelephoneOrOnlineEncounters.stopDate = null
          and start of D.prevalencePeriod same day as start of TelephoneOrOnlineEncounters.relevantPeriod
        )
      where TelephoneOrOnlineEncounters.relevantPeriod starts 2 years or less before end of "Measurement Period"
        and E.placeOfService != 81
        and E.supplemental = false
        and D.placeOfService != 81
        and D.supplemental = false
        //NOTE: not sure if we need to filter by telehealth pos/modifier here as well - leaving be for now
      )

      /*
        Identify outpatient telehealth visits by the presence of
          - a telehealth modifier (Telehealth Modifier Value Set)
          - or the presence of a telehealth POS code (Telehealth POS Value Set)
        associated with the outpatient visit
      */
      //outpatient telehealth
      union (["Encounter, Performed": "HEDIS; Outpatient Without UBREV"] UBREV
        with ["Diagnosis": "HEDIS; Essential Hypertension"] D
          such that D.claimId = UBREV.claimId
            or (
              end of UBREV.relevantPeriod != null
              and start of D.prevalencePeriod during UBREV.relevantPeriod
            )
            or (
              UBREV.stopDate = null
              and start of D.prevalencePeriod same day as start of UBREV.relevantPeriod
            )
        where E.relevantPeriod starts 2 years or less before end of "Measurement Period"
          and E.placeOfService != 81
          and E.supplemental = false
          and (
              //MUST BE either telehealth POS or modifier
              E.placeOfService in "HEDIS; Telehealth POS"
              or E.code.modifier in "HEDIS; Telehealth Modifier"
            )
          and D.placeOfService != 81
          and D.supplemental = false
      )

      ).relevantPeriod) start) date)

/*
  we need to count the DISTINCT DATES of service for the following criteria
*/
define "Distinct Dates of Non-Telehealth Encounters with Hypertension":
    distinct(((
      ((["Encounter, Performed": "HEDIS; Outpatient Without UBREV"]) E
	      with ["Diagnosis": "HEDIS; Essential Hypertension"] D
	        such that D.claimId = E.claimId
          or (
            end of E.relevantPeriod != null
            and start of D.prevalencePeriod during E.relevantPeriod
          )
          or (
            E.stopDate = null
            and start of D.prevalencePeriod same day as start of E.relevantPeriod
          )
        where E.relevantPeriod starts 2 years or less before end of "Measurement Period"
          and D.placeOfService != 81
          and E.supplemental = false
          and not E.placeOfService in {81, "HEDIS; Telehealth POS"} //DO NOT INCLUDE telehealth or lab
          and not E.code.modifier in "HEDIS; Telehealth Modifier" //DO NOT INCLUDE telehealth
      ).relevantPeriod) start) date)

define "Count of Visits with Hypertension Diagnosis":
    //we only allow a max of ONE telehealth over the period - and we need to make sure it doesn't intersect with non-telehealth
    //we're going to count the # of telehealth encounters REMOVING the non-telehealth encounters - taking the FIRST element and then converting it to a list
    Count(
    	{First("Distinct Dates of Telehealth Encounters with Hypertension" except "Distinct Dates of Non-Telehealth Encounters with Hypertension")}
    	union "Distinct Dates of Non-Telehealth Encounters with Hypertension"
    )

define "Second Hypertension Diagnosis":
  ((["Diagnosis": "HEDIS; Essential Hypertension"] D
      with ["Encounter, Performed"]  E //ANY encounter
        such that E.claimId = D.claimId
        or (
          end of E.relevantPeriod != null
          and start of D.prevalencePeriod during E.relevantPeriod
        )
        or (
          E.stopDate = null
          and start of D.prevalencePeriod same day as start of E.relevantPeriod
        )
      where
        D.placeOfService != 81
        and E.placeOfService != 81
  ) HypertensionDX
  sort by start of prevalencePeriod asc)[1] //prevalencePeriod //note we want the second element here

define "Encounters On or After Second Hypertension Diagnosis":
  (["Encounter, Performed": "HEDIS; Outpatient Without UBREV"]
    union ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"]
    union ["Encounter, Performed": "HEDIS; Remote Blood Pressure Monitoring"] //this is likely a procedure and NOT an encounter
    ) E
      where E.relevantPeriod starts on or after start of ("Second Hypertension Diagnosis").prevalencePeriod
      and E.relevantPeriod overlaps "Measurement Period"

define "ESRD Procedure":
  ["Procedure, Performed": "HEDIS; ESRD"]
  union ["Procedure, Performed": "HEDIS; ESRD Obsolete"]
  union ["Procedure, Performed": "HEDIS; Kidney Transplant"]
  union ["Procedure, Performed": "HEDIS; Dialysis Procedure"]
  union ["Procedure, Performed": "HEDIS; Nephrectomy"]
  union ["Procedure, Performed": "HEDIS; History of Kidney Transplant"]

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

define "Qualifying Systolic Blood Pressure Reading":
  "Systolic Blood Pressure" A
    with "Encounters On or After Second Hypertension Diagnosis" E
      such that start of A.relevantPeriod during E.relevantPeriod
    where start of A.relevantPeriod during "Measurement Period"
    sort by start of relevantPeriod desc

define "Diastolic Blood Pressure":
  ["Assessment, Performed": "VSAC; Diastolic Blood Pressure"]
  union ["Procedure, Performed": "HEDIS; Diastolic Less Than 80"]
  union ["Procedure, Performed": "HEDIS; Diastolic 80-89"]
  union ["Procedure, Performed": "HEDIS; Diastolic Greater Than or Equal To 90"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8754"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8755"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8783"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8950"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8952"]

define "Normal Diastolic Blood Pressure Procedure":
  ["Procedure, Performed": "HEDIS; Diastolic Less Than 80"]
  union ["Procedure, Performed": "HEDIS; Diastolic 80-89"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8754"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8783"]

define "Qualifying Diastolic Blood Pressure Reading":
  "Diastolic Blood Pressure" A
    with "Encounters On or After Second Hypertension Diagnosis" E
      such that start of A.relevantPeriod during E.relevantPeriod
    where start of A.relevantPeriod during "Measurement Period"
    sort by start of relevantPeriod desc

define "Blood Pressure Days":
  (
    ( "Qualifying Diastolic Blood Pressure Reading" DBPExam
      return date from start of DBPExam.relevantPeriod
      )
    intersect
    ( "Qualifying Systolic Blood Pressure Reading" SBPExam
      return date from start of SBPExam.relevantPeriod
      )
  )

define "Most Recent Blood Pressure Day":
  Last("Blood Pressure Days" BPDays sort by $this desc)

define "Lowest Diastolic Reading on Most Recent Blood Pressure Day":
  First("Qualifying Diastolic Blood Pressure Reading" DBPReading
    where start of DBPReading.relevantPeriod same day as "Most Recent Blood Pressure Day"
    sort by(result as Quantity) asc
  )

define "Lowest Systolic Reading on Most Recent Blood Pressure Day":
  First("Qualifying Systolic Blood Pressure Reading" SBPReading
    where start of SBPReading.relevantPeriod same day as "Most Recent Blood Pressure Day"
    sort by(result as Quantity) asc
  )

define "Systolic Blood Pressure < 140":
  "Lowest Systolic Reading on Most Recent Blood Pressure Day".result < 140 'mm[Hg]'

define "Diastolic Blood Pressure < 90":
  "Lowest Diastolic Reading on Most Recent Blood Pressure Day".result < 90 'mm[Hg]'

define "Blood Pressure < 140/90":
  "Systolic Blood Pressure < 140"
  and "Diastolic Blood Pressure < 90"

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 86
  and "Count of Visits with Hypertension Diagnosis" >= 2


define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Frailty and Advanced Illness":
  /*
   * config_link_id: exclusion_required_frailty
   */
   (
     AgeInYearsAt(end of "Measurement Period") >= 66
     and (
        "LTI During Period"("Measurement Period")
        or "SNP"("Measurement Period")
     )
   )
   or (
     AgeInYearsAt(end of "Measurement Period") between 67 and 80
     and (
        ("Advanced Illness"("Measurement Period and Year Prior")
        and ("Frailty: Claim During Period"("Measurement Period")))
     )
   )
   or (
        AgeInYearsAt(end of "Measurement Period") >= 81
        and ("Frailty: Claim During Period"("Measurement Period"))
      )

/*
•	Exclude from the eligible population all members with
  - evidence of end-stage renal disease (ESRD) (ESRD Diagnosis Value Set),
  - dialysis (Dialysis Procedure Value Set),
  - nephrectomy (Nephrectomy Value Set)
  - or kidney transplant (Kidney Transplant Value Set; History of Kidney Transplant Value Set)

  on or prior to December 31 of the measurement year
*/
define "Denominator Exclusion: ESRD":
  /*
   * config_link_id: exclusion_esrd
   */
  exists(["Diagnosis": "HEDIS; ESRD"] Dx
    with ["Encounter, Performed"] Enc //ANY encounters
      such that Enc.claimId = Dx.claimId
      or (
        end of Enc.relevantPeriod != null
        and start of Dx.prevalencePeriod during Enc.relevantPeriod
      )
      or (
        Enc.stopDate = null
        and start of Dx.prevalencePeriod same day as start of Enc.relevantPeriod
      )
    where Dx.prevalencePeriod starts before end of "Measurement Period"
      and Dx.placeOfService != 81
      and Enc.placeOfService != 81
    )
  or exists("ESRD Procedure" P
    where P.relevantPeriod starts on or before end of "Measurement Period"
      and P.placeOfService != 81 //FIXME: unclear if we need to correlate w/ an encounter
    )

/*
•	Exclude from the eligible population female members with a diagnosis of pregnancy (Pregnancy Value Set)
  during the measurement year.
*/
define "Denominator Exclusion: Pregnancy":
  /*
   * config_link_id: exclusion_pregnancy
   */
  exists (["Patient Characteristic Sex": "Female"])
  and exists(["Diagnosis": "HEDIS; Pregnancy"] D
    with ["Encounter", "Performed"] E // ANY encounters
      such that E.claimId = D.claimId
      or (
        end of E.relevantPeriod != null
        and start of D.prevalencePeriod during E.relevantPeriod
      )
      or (
        E.stopDate = null
        and start of D.prevalencePeriod same day as start of E.relevantPeriod
      )
    where D.prevalencePeriod overlaps "Measurement Period"
      and D.placeOfService != 81
      and E.placeOfService != 81
    )

/*
Exclude from the eligible population all members who had a nonacute inpatient admission during the measurement year.
1.	Identify all acute and nonacute inpatient stays (Inpatient Stay Value Set).
2.	Confirm the stay was for nonacute care based on the presence of a nonacute code (Nonacute Inpatient Stay Value Set) on the claim.
3.	Identify the admission date for the stay
*/
define "Denominator Exclusion: Nonacute Inpatient Visit":
  /*
   * config_link_id: exclusion_nonacute_inpatient_visit
   */
  exists(["Encounter, Performed": "HEDIS; Inpatient Stay"] Inpatient
    with ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] Nonacute
      such that Inpatient.claimId = Nonacute.claimId
    where Inpatient.admissionDate during "Measurement Period"
      and Inpatient.placeOfService != 81
      and Nonacute.placeOfService != 81
    )

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Blood Pressure < 140/90"


//FIXME: address the CPT II codes
define "Numerator Performance Not Met: Out of Range":
  /*
   * config_link_id: out_of_range
   */
  exists("Systolic Blood Pressure" A
    where start of A.relevantPeriod during "Measurement Period")
  and exists("Diastolic Blood Pressure" A
    where start of A.relevantPeriod during "Measurement Period")

define "Numerator Performance Not Met: No Blood Pressure":
  /*
   * config_link_id: no_blood_pressure
   */
  not "Denominator Exclusion: ESRD"
  and not "Denominator Exclusion: Pregnancy"
  and not "Denominator Exclusion: Nonacute Inpatient Visit"
  and not "Numerator Performance Met"
  and not "Numerator Performance Not Met: Out of Range"
