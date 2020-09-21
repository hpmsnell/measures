library HEDIS_PCR_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: PCR
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Inpatient Stay"
valueset "HEDIS; Nonacute Inpatient Stay"
valueset "HEDIS; Pregnancy"
valueset "HEDIS; Perinatal Conditions"
valueset "HEDIS; Chemotherapy"
valueset "HEDIS; Rehabilitation"
valueset "HEDIS; Kidney Transplant"
valueset "HEDIS; Bone Marrow Transplant"
valueset "HEDIS; Organ Transplant Other Than Kidney"
valueset "HEDIS; Potentially Planned Procedures"
valueset "HEDIS; Acute Condition"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Pregnancy":
  ["Diagnosis": "HEDIS; Pregnancy"]
  union ["Diagnosis": "HEDIS; Perinatal Conditions"]

define "Discharge":
  ["Encounter, Performed": "HEDIS; Inpatient Stay"] E1
    where E1.relevantPeriod starts [start of "Measurement Period", 30 days before end of "Measurement Period"]
      and AgeInYearsAt(end of E1.relevantPeriod) >= 18
    without ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] E2 // Ensure acute
      such that E2.relevantPeriod starts during E1.relevantPeriod
    without ["Encounter, Performed": "HEDIS; Inpatient Stay"] E3 // Ensure this is the last one in a series and no direct transfers
      such that E3.relevantPeriod starts 1 day after start of E1.relevantPeriod
    with ["Encounter, Performed": "HEDIS; Inpatient Stay"] E4 // Ensure this is a multi-day stay
      such that E4.relevantPeriod starts 1 day before start of E1.relevantPeriod
    without "Pregnancy" D // No pregnancy or perinatal condition
      such that D.prevalencePeriod starts during E1.relevantPeriod

define "Planned Hospital Stay":
  ["Encounter, Performed": "HEDIS; Inpatient Stay"] E1
    where E1.relevantPeriod starts during [2 days after "Discharge", 30 days after "Discharge"]
    without ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] E2 // Ensure acute
      such that E2.relevantPeriod starts during E1.relevantPeriod

define "Earliest Planned Hospital Stay":
  First("Planned Hospital Stay" E
    sort by start of E.relevantPeriod asc)

define "Planned Procedure":
  ["Procedure, Performed": "HEDIS; Chemotherapy"]
  union ["Procedure, Performed": "HEDIS; Rehabilitation"]
  union ["Procedure, Performed": "HEDIS; Kidney Transplant"]
  union ["Procedure, Performed": "HEDIS; Bone Marrow Transplant"]
  union ["Procedure, Performed": "HEDIS; Organ Transplant Other Than Kidney"]

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

/* Populations */

define "Denominator":
  "Discharge"
  and not exists("Earliest Planned Hospital Stay" E
    with "Planned Proce dure" P
      such that P.relevantPeriod starts during E.relevantPeriod)
  and not exists("Earliest Planned Hospital Stay" E
    with ["HEDIS"; "Potentially Planned Procedures"] P
      such that P.relevantPeriod starts during E.relevantPeriod
    without ["Diagnosis"; "HEDIS; Acute Condition"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Discharge" E1
    with "Discharge" E2
      such that E2.relevantPeriod starts during [2 days after start of E1.relevantPeriod, 30 days after start of E1.relevantPeriod])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
