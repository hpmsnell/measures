library HEDIS_CDC1_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC1
 * Year: 2017
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; HbA1c Tests": '2.16.840.1.113883.3.464.1004.1116'
valueset "HEDIS; Diabetes Medications"
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 3046F" //HbA1c Test
valueset "MIPS; Performance Not Met: 3045F" //HbA1c Test
valueset "MIPS; Performance Not Met: 3044F" //HbA1c Test

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Nonacute Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]

define "Patient Has Diabetes":
  exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  or count("Nonacute Visit" E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod) >= 2
  or exists(["Medication": "HEDIS; Diabetes Medication"] M
    where M.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 76
  and "Patient Has Diabetes"
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

 define "Denominator Exclusion: Diagnosis"
   /*
    * config_link_id: exclusion_1
    */
   not exists(["Diagnosis": "HEDIS; Diabetes"] D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
   and exists(["Diagnosis": "HEDIS; Diabetes Exclusions"] D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

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
  not "Numerator Performance Met"
