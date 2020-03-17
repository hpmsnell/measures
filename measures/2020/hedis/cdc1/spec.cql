library HEDIS_CDC1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC1
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; HbA1c Tests": '2.16.840.1.113883.3.464.1004.1116'
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; Frailty Device": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Diagnosis": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Encounter": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Symptom": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Advanced Illness": '2.16.840.1.113883.3.464.1004.1465'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Diabetes Medications": '2.16.840.1.113883.3.464.1004.2050'
valueset "HEDIS; Dementia Medications": '2.16.840.1.113883.3.464.1004.1729'

// NCQA medication list value sets

valueset "NCQA; Diabetes Medications"

// MIPS value sets

valueset "MIPS; Performance Met: 3046F" //HbA1c Test
valueset "MIPS; Performance Not Met: 3045F" //HbA1c Test
valueset "MIPS; Performance Not Met: 3044F" //HbA1c Test

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Inpatient Visits with Diabetes":
  distinct(((((["Encounter, Performed": "HEDIS; Acute Inpatient"] E
      with ["Diagnosis": "HEDIS; Diabetes"] D
        such that D.prevalencePeriod starts during E.relevantPeriod
  ) QualifyingEncounter
  where QualifyingEncounter.relevantPeriod overlaps Interval[end of "Measurement Period" - 24 months, end of "Measurement Period"]
    and not QualifyingEncounter.placeOfService in "HEDIS; Telehealth POS"
    and not QualifyingEncounter.code.modifier in "HEDIS; Telehealth Modifier").relevantPeriod) start) date)

define "Other Visits with Diabetes - Non-Telehealth":
  distinct((((((["Encounter, Performed": "HEDIS; Outpatient"]
    union ["Encounter, Performed": "HEDIS; Observation"]
    union ["Encounter, Performed": "HEDIS; ED"]
    union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]
      ) E
      with ["Diagnosis": "HEDIS; Diabetes"] D
        such that D.prevalencePeriod starts during E.relevantPeriod
  ) QualifyingEncounter
  where QualifyingEncounter.relevantPeriod overlaps Interval[end of "Measurement Period" - 24 months, end of "Measurement Period"]
    and not QualifyingEncounter.placeOfService in "HEDIS; Telehealth POS"
    and not QualifyingEncounter.code.modifier in "HEDIS; Telehealth Modifier").relevantPeriod) start) date)

define "Other Visits with Diabetes - Telehealth":
  distinct((((((["Encounter, Performed": "HEDIS; Telephone Visits"]
	    union ["Encounter, Performed": "HEDIS; Online Assessments"]
      ) E
      with ["Diagnosis": "HEDIS; Diabetes"] D
        such that D.prevalencePeriod starts during E.relevantPeriod
  ) QualifyingEncounter
  where QualifyingEncounter.relevantPeriod overlaps Interval[end of "Measurement Period" - 24 months, end of "Measurement Period"]
    and ( QualifyingEncounter.placeOfService in "HEDIS; Telehealth POS"
    or QualifyingEncounter.code.modifier in "HEDIS; Telehealth Modifier")).relevantPeriod) start) date)

define "Met Number of Eligible Visits":
  if
    Count("Inpatient Visits with Diabetes") >= 1
    or Count(
      //we only allow a max of ONE telehealth over the period - and we need to make sure it doesn't intersect with non-telehealth
      //we're going to count the # of telehealth encounters REMOVING the non-telehealth encounters - taking the FIRST element and then converting it to a list
      {First("Other Visits with Diabetes - Telehealth" except "Other Visits with Diabetes - Non-Telehealth")}
      union "Other Visits with Diabetes - Non-Telehealth"
    ) >= 2
  then true
  else false

define "Received Diabetic Medications":
  exists(["Medication, Dispensed": "NCQA; Diabetes Medications"] M
    where M.relevantPeriod overlaps Interval[end of "Measurement Period" - 24 months, end of "Measurement Period"])

define "Patient Has Diabetes":
  "Met Number of Eligible Visits" or "Received Diabetic Medications"


define "Exclusion - Acute Visits with Advanced Illness":
  distinct(((((["Encounter, Performed": "HEDIS; Acute Inpatient"] E
      with ["Diagnosis": "HEDIS; Advanced Illness"] D
        such that D.prevalencePeriod starts during E.relevantPeriod
  ) QualifyingEncounter
  where QualifyingEncounter.relevantPeriod overlaps Interval[end of "Measurement Period" - 24 months, end of "Measurement Period"]).relevantPeriod) start) date)

define "Exclusion - Outpatient Visits with Advanced Illness":
  distinct(((((
      ( ["Encounter, Performed": "HEDIS; Outpatient"]
        union ["Encounter, Performed": "HEDIS; Observation"]
        union ["Encounter, Performed": "HEDIS; ED"]
        union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]
      ) E
      with ["Diagnosis": "HEDIS; Advanced Illness"] D
        such that D.prevalencePeriod starts during E.relevantPeriod
  ) QualifyingEncounter
  where QualifyingEncounter.relevantPeriod overlaps Interval[end of "Measurement Period" - 24 months, end of "Measurement Period"]).relevantPeriod) start) date)

define "Exclusion - Received Dementia Medications":
  exists(["Medication, Dispensed": "HEDIS; Dementia Medications"] M
    where M.relevantPeriod overlaps Interval[end of "Measurement Period" - 24 months, end of "Measurement Period"])

define "Exclusion - Advanced Illness Exists":
  Count("Exclusion - Outpatient Visits with Advanced Illness") >= 2
  or Count("Exclusion - Acute Visits with Advanced Illness") >= 1
  or "Exclusion - Received Dementia Medications"

define "Qualifying Exclusion Age":
  AgeInYearsAt(end of "Measurement Period") >= 66

define "Frailty Diagnosis or Symptoms":
  (["Diagnosis": "HEDIS; Frailty Diagnosis"]
  union ["Diagnosis": "HEDIS; Frailty Symptom"]) FrailDxSx
    where FrailDxSx.prevalencePeriod overlaps "Measurement Period"
      and FrailDxSx.supplemental = false

define "Frailty Encounter":
  ["Encounter, Performed": "HEDIS; Frailty Encounter"]FrailEnc
    where FrailEnc.relevantPeriod overlaps "Measurement Period"
      and FrailEnc.supplemental = false

define "Frailty Device":
  ((["Device, Applied": "HEDIS; Frailty Device"]
  union ["Device, Order": "HEDIS; Frailty Device"]
  union ["Device, Recommended": "HEDIS; Frailty Device"])FrailDevice
    where (FrailDevice.relevantPeriod overlaps "Measurement Period"
      or FrailDevice.authorDatetime during "Measurement Period")
      and FrailDevice.supplemental = false)

define "Frailty":
  "Frailty Diagnosis or Symptoms"
  union "Frailty Encounter"
  union "Frailty Device"


define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice Intervention"]
  union ["Encounter, Performed": "HEDIS; Hospice Encounter"]

/* Populations */


define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 76
  and "Patient Has Diabetes"
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

/*
 * config_link_id: exclusion_required_hospice
 */
define "Exclusion: Hospice":
  exists("Hospice" Hospice
    where Hospice.relevantPeriod overlaps "Measurement Period")


//define "Denominator Exclusion: Diagnosis"
// /*
//  * config_link_id: exclusion_1
//  */
//   not exists(["Diagnosis": "HEDIS; Diabetes"] D
//    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
//   and exists(["Diagnosis": "HEDIS; Diabetes Exclusions"] D
//    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])


define "Denominator Exclusion: Frailty or Advanced Illness":
  /*
   * config_link_id: exclusion_required_frailty
   */
  "Qualifying Exclusion Age"
  and "Exclusion - Advanced Illness Exists"
    and exists("Frailty")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Laboratory Test, Performed": "HEDIS; HbA1c Tests"] L
    where L.resultDateTime during "Measurement Year")
  or exists(["Procedure, Performed": "HEDIS; HbA1c Tests"] P
    where P.relevantPeriod starts during "Measurement Year")
  or exists(["Procedure, Performed": "MIPS; Performance Met: 3046F"] P
    where P.relevantPeriod starts during "Measurement Year")
  or exists(["Procedure, Performed": "MIPS; Performance Not Met: 3045F"] P
    where P.relevantPeriod starts during "Measurement Year")
  or exists(["Procedure, Performed": "MIPS; Performance Not Met: 3044F"] P
    where P.relevantPeriod starts during "Measurement Year")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Diagnosis"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met"
