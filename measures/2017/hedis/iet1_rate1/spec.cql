library HEDIS_IET1_RATE1_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: IET1 Rate 1
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; IET Stand Alone Visits"
valueset "HEDIS; IET Visits Group 1"
valueset "HEDIS; IET Visits Group 2"
valueset "HEDIS; Detoxification"
valueset "HEDIS; Telephone Visits"
valueset "HEDIS; Online Assessments"
valueset "HEDIS; AOD Abuse and Dependence"
valueset "HEDIS; Alcohol Abuse and Dependence"
valueset "HEDIS; Opioid Abuse and Dependence"
valueset "HEDIS; Other Drug Abuse and Dependence"
valueset "HEDIS; Medication Assisted Treatment"
valueset "HEDIS; MAT for Alcohol Abuse or Dependence Medications"
valueset "HEDIS; MAT for Opioid Abuse or Dependence Medications"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Encounter":
  ["Encounter, Performed": "HEDIS; IET Stand Alone Visits"]
  union ["Encounter, Performed": "HEDIS; IET Visits Group 1"] E
    where E.placeOfService in ['02','03','05','07','09','11','12','13','14','15','16','17','18','19','20','22','33','49','50','52','53','57','71','72']
  union ["Encounter, Performed": "HEDIS; IET Visits Group 2"] E
    where E.placeOfService in ['02','52','53']
  union ["Encounter, Performed": "HEDIS; Detoxification"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Inpatient Stay"]
  union ["Encounter, Performed": "HEDIS; Telephone Visit"]
  union ["Encounter, Performed": "HEDIS; Online Assessment"]

define "AOD":
  ["Diagnosis": "HEDIS; Alcohol Abuse and Dependence"]

define "Encounter with AOD":
  "Encounter" E
    with "AOD" D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Encounter with AOD During Index Period":
  "Encounter with AOD" E
    where E.relevantPeriod starts during [start of "Measurement Period", 46 days before end of "Measurement Period"]

define "AOD During Index Period Exists":
  exists("Encounter with AOD During Index Period")

define "First AOD During Index Period":
  First("Encounter With AOD During Index Period" E
    sort by E.relevantPeriod asc)

define "MAT":
  ["Procedure, Performed": "HEDIS; Medication Assisted Treatement"]
  union ["Medication": "HEDIS; MAT for Alcohol Abuse or Dependence"]

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
  and not exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")

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
  or exists("First AOD During Index Period" E
    with "Alcohol or Opioid" D
      such that D.prevalencePeriod starts during E.relevantPeriod
    with "MAT" M
      such that M.relevantPeriod starts during E.relevantPeriod
      and not M.signingProvider = E.signingProvider
      and not M.signingProvider = null)
  or exists("First AOD During Index Period" E
    with "MAT" M
      such that M.relevantPeriod starts starts 13 days or less after E.relevantPeriod)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
