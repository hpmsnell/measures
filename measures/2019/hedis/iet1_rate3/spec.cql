library HEDIS_IET1_RATE3_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: IET1 Rate 3
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; IET Stand Alone Visits": '2.16.840.1.113883.3.464.1004.1131'
valueset "HEDIS; IET POS Group 1": '2.16.840.1.113883.3.464.1004.1129'
valueset "HEDIS; IET POS Group 2": '2.16.840.1.113883.3.464.1004.1130'
valueset "HEDIS; IET Visit Group 1": '2.16.840.1.113883.3.464.1004.1131'
valueset "HEDIS; IET Visit Group 2": '2.16.840.1.113883.3.464.1004.1132'
valueset "HEDIS; Detoxification": '2.16.840.1.113883.3.464.1004.1076'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; AOD Abuse and Dependence": '2.16.840.1.113883.3.464.1004.1013'
valueset "HEDIS; AOD Medication Treatment": '2.16.840.1.113883.3.464.1004.2017'
valueset "HEDIS; Alcohol Abuse and Dependence": '2.16.840.1.113883.3.464.1004.1424'
valueset "HEDIS; Opioid Abuse and Dependence": '2.16.840.1.113883.3.464.1004.1425'
valueset "HEDIS; Other Drug Abuse and Dependence": '2.16.840.1.113883.3.464.1004.1426'

// NCQA medication list value sets

valueset "NCQA; Alcohol Use Disorder Treatment Medications"
valueset "NCQA; Opioid Use Disorder Treatment Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Other Encounter with AOD":
  (["Encounter, Performed": "HEDIS; IET Stand Alone Visits"]
  union ["Encounter, Performed": "HEDIS; IET Visits Group 1"] E
    where E.placeOfService in ['02','03','05','07','09','11','12','13','14','15','16','17','18','19','20','22','33','49','50','52','53','57','71','72']
  union ["Encounter, Performed": "HEDIS; IET Visits Group 2"] E
    where E.placeOfService in ['02','52','53']
  union ["Encounter, Performed": "HEDIS; Detoxification"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; Telephone Visit"])Enc
    with "AOD" D
      such that D.prevalencePeriod starts during Enc.relevantPeriod

define "Nonacute or Acute Inpatient Encounter with AOD":
  ["Encounter, Performed": "HEDIS; Inpatient Stay"]IPEnc
    with "AOD" D
      such that D.prevalencePeriod starts during IPEnc.relevantPeriod
      and D.claimId = IPEnc.claimId

define "AOD":
  ["Diagnosis": "HEDIS; Other Drug Abuse and Dependence"]


define "Encounter with AOD":
  "Other Encounter with AOD"
  union "Nonacute or Acute Inpatient Encounter with AOD"

define "Encounter with AOD During Index Period":
  "Other Encounter with AOD" E
    where E.relevantPeriod starts during Interval[start of "Measurement Period", "Measurement Period" - 49 days]
  union "Nonacute or Acute Inpatient Encounter with AOD" IPEnc
    where IPEnc.relevantPeriod ends during Interval[start of "Measurement Period", "Measurement Period" - 49 days]

define "AOD During Index Period Exists":
  exists("Encounter with AOD During Index Period")

define "First AOD During Index Period":
  First("Encounter With AOD During Index Period" E
    sort by start of E.relevantPeriod asc)

define "MAT":
  ["Procedure, Performed": "HEDIS; AOD Medication Treatment"]

define "Diagnosis History":
  ["Diagnosis": "HEDIS; AOD Abuse and Dependence"]
  union "MAT"

define "First AOD During Index Period Has Prior Diagnosis":
  exists("First AOD During Index Period" E
    with "Diagnosis History" D
      such that D.prevalencePeriod starts 60 days or less before start of E.relevantPeriod

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 13
  and "AOD During Index Period Exists"
  and not "First AOD During Index Period Has Prior Diagnosis"

define "Exclusion: Inpatient Discharge After November 27 Measurement Year":
// Exclude the member from the denominator if the initiation of treatment event is an inpatient stay with a discharge date after November 27 of the measurement year.
  /*
  * config_link_id: exclusion_required_inpatient
  */

  exists("Encounter with AOD During Index Period" E
    where E.code in ["Encounter, Performed": "HEDIS; Inpatient Stay"]
      and IPIndex.relevantPeriod ends on or before end of "Measurement Period" - 34 days)

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("First AOD During Index Period" E1
    with ["Encounter, Performed": "HEDIS; Inpatient Stay"] E2
      such that E2.relevantPeriod starts during E1.relevantPeriod)
  or exists("First AOD During Index Period" E1
    with "Encounter with AOD" E2
      such that E2.relevantPeriod starts during E1.relevantPeriod
      and not E2.signingProvider = E1.signingProvider)
  or exists("First AOD During Index Period" E1
    with "Encounter with AOD" E2
      such that E2.relevantPeriod starts 13 days or less after E1.relevantPeriod)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
