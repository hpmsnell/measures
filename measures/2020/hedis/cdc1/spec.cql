library HEDIS_CDC1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC1
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; HbA1c Lab Test": '2.16.840.1.113883.3.464.1004.1755'
valueset "HEDIS; HbA1c Test Result or Finding": '2.16.840.1.113883.3.464.1004.1756'
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'

// NCQA medication list value sets

valueset "NCQA; Diabetes Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Nonacute Visit No Telehealth":
  (["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]
  union "Nonacute Inpatient Visit")E
    where E1.code.modifier != {'GT','95'}
          and E1.placeOfService != {'02'}

define "Nonacute Inpatient Visit":
  ["Encounter, Performed": "HEDIS; Inpatient Stay"] Inpatient
    with ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] Nonacute
      such that Inpatient.claimId = Nonacute.claimId
      and Inpatient.placeOfService != 81
      and Nonacute.placeOfService != 81

define "Nonacute Visit Telehealth":
  ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Encounter, Performed": "HEDIS Online Assessments"]
  union "Nonacute Inpatient Visit" Nonacute
    where Nonacute.code.modifier in {'GT','95'}
      or Nonacute.placeOfService in {'02'}

define "Nonacute Visit with Diabetes":
  "Nonacute Visit No Telehealth" E
    where E.dischargeDate during [24 months before end of "Measurement Period", end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Nonacute Visit Telehealth with Diabetes":
  "Nonacute Visit Telehealth" E
    where E.dischargeDate during [24 months before end of "Measurement Period", end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Patient Has Diabetes":
// only 1 of 2 "Nonacute Visit with Diabetes" can be outpatient telehealth
  exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
      and not E.code.modifier in {'GT','95'}
      and not E.placeOfService in {'02'})
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  or exists(["Encounter, Performed": "HEDIS; Inpatient Stay"])InpatientE
    where InpatientE.dischargeDate during [24 months before end of "Measurement Period", end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during InpatientE.relevantPeriod
        and InpatientE.claimId = D.claimId)
  or exists("Nonacute Visit with Diabetes" E1
    with "Nonacute Visit with Diabetes" E2
      such that start of E2.relevantPeriod != start of E1.relevantPeriod
  or exists("Nonacute Visit with Diabetes" E1
    with "Nonacute Visit Telehealth with Diabetes" E2
      such that start of E2.relevantPeriod != start of E1.relevantPeriod)
  or exists(["Medication, Dispensed": "NCQA; Diabetes Medications"] M
    where M.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 76
  and "Patient Has Diabetes"

define "Exclusion: Hospice":
  /*
  * config_link_id: exclusion_required_hospice
  */
  exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Diagnosis"
  /*
  * config_link_id: exclusion_1
  */
  not exists(["Diagnosis": "HEDIS; Diabetes"] D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
  and exists(["Diagnosis": "HEDIS; Diabetes Exclusions"] D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

define "Denominator Exclusion: Frailty or Advanced Illness":
  /*
  * config_link_id: exclusion_required_frailty
  */
  AgeInYearsAt(end of "Measurement Period") >= 66
    and ("LTI During Period"("Measurement Period")
         or "SNP"("Measurement Period")
         or ("Advanced Illness"("Measurement Period and Year Prior")
             and "Frailty: Claim During Period"("Measurement Period")
           )
     )

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Laboratory Test, Performed": "HEDIS; HbA1c Test Result or Finding"] L
    where L.resultDateTime during "Measurement Year")
  or exists(["Procedure, Performed": "HEDIS; HbA1c Lab Test"] P
    where P.relevantDatetime during "Measurement Year")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Exclusion: Hospice"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Denominator Exclusion: Diagnosis"
  and not "Numerator Performance Met"
