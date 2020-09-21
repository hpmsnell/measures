library HEDIS_DDE_RATE_3_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: DDE Rate 3
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; ESRD"
valueset "HEDIS; CKD Stage 4"
valueset "HEDIS; Kidney Transplant"
valueset "HEDIS; Cox-2 Selective NSAIDs and Nonaspirin NSAIDs Medications"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Kidney Disease":
  ["Diagnosis": "HEDIS; CKD Stage 4"]
  union ["Diagnosis": "HEDIS; ESRD"]
  union ["Procedure, Performed": "HEDIS; ESRD"]
  union ["Diagnosis": "HEDIS; Kidney Transplant"]
  union ["Procedure, Performed": "HEDIS; Kidney Transplant"]

define "Kidney Disease During Index Period"
  "Kidney Disease" D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", 1 month before end of "Measurement Period"]

define "First Kidney Disease During Index Period":
  First("Kidney Disease During Index Period" D
    sort by D.prevalencePeriod asc)

define "Medication":
  ["Medication, Dispensed": "HEDIS; Cox-2 Selective NSAIDs and Nonaspirin NSAIDs Medications"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 67
  and not exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")
  and exists("Kidney Disease During Index Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
   exists("First Kidney Disease During Index Period" E // Since the end date is not achored to the first fall, any fall can be used
     with "Medication" A
       such that M.relevantPeriod starts during [start of E.relevantPeriod, end of "Measurement Period"])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
