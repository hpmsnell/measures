library HEDIS_ABA_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: ABA
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; Performance Met: G8420"
valueset "MIPS; Performance Met: G8417"
valueset "MIPS; Performance Met: G8418"
valueset "MIPS; Denominator Exception: G8416"
valueset "MIPS; Performance Not Met: G8419"

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; BMI": '2.16.840.1.113883.3.464.1004.1037'
valueset "HEDIS; BMI Percentile": '2.16.840.1.113883.3.464.1004.1038'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'

// VSAC value sets

valueset "VSAC; BMI LOINC Value": '2.16.840.1.113883.3.600.1.681'
valueset "VSAC; BMI percentile": '2.16.840.1.113883.3.464.1003.121.12.1012'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "BMI":
  ["Assessment, Performed": "VSAC; BMI LOINC Value"]
  union ["Diagnosis": "HEDIS; BMI"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8420"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8417"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8418"]
  union ["Procedure, Performed": "MIPS; Denominator Exception: G8416"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8419"]

define "Patient 20+ with BMI":
  exists(["Encounter, Performed": "HEDIS; Outpatient"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 20)
  and exists("BMI" P
    where P.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

define "BMI Percentile":
  ["Diagnosis": "HEDIS; BMI Percentile"]
  union ["Assessment, Performed": "VSAC; BMI percentile"]

define "Patient <20 with BMI Percentile":
  exists(["Encounter, Performed": "HEDIS; Outpatient"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) < 20)
  and exists("BMI Percentile" P
    where P.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

// Populations

define "Denominator":
  AgeInYearsAt(24 months before end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 75
  and exists(["Encounter, Performed": "HEDIS; Outpatient"] E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "HEDIS; Pregnancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Patient 20+ with BMI"
  or "Patient <20 with BMI Percentile"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
