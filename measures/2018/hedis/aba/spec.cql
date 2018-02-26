library HEDIS_ABA_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: ABA
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; BMI": '2.16.840.1.113883.3.464.1004.1037'
valueset "HEDIS; BMI Percentile": '2.16.840.1.113883.3.464.1004.1038'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'

// VSAC value sets

valueset "VSAC; BMI LOINC Value": '2.16.840.1.113883.3.600.1.681'
valueset "VSAC; BMI percentile": '2.16.840.1.113883.3.464.1003.121.12.1012'
valueset "VSAC; Height": '2.16.840.1.113883.3.464.1003.121.12.1014'
valueset "VSAC; Weight": '2.16.840.1.113883.3.464.1003.121.12.1015'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "BMI and Weight Exists":
  exists(["Assessment, Performed": "VSAC; BMI LOINC Value"] A
    where A.authorDateTime during [24 months before end of "Measurement Period", end of "Measurement Period"])
  and exists(["Assessment, Performed": "VSAC; Weight"] A
    where A.authorDateTime during [24 months before end of "Measurement Period", end of "Measurement Period"])

define "BMI Exists":
  exists(["Diagnosis": "HEDIS; BMI"] D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
  or "Patient has BMI and Weight"

define "Patient 20+ with BMI":
  exists(["Encounter, Performed": "HEDIS; Outpatient"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 20)
  and "BMI Exists"

define "BMI Percentile, Height, and Weight Exist":
  exists(["Assessment, Performed": "VSAC; BMI percentile"] A
    where A.authorDateTime during [24 months before end of "Measurement Period", end of "Measurement Period"])
  and exists(["Assessment, Performed": "VSAC; Height"] A
    where A.authorDateTime during [24 months before end of "Measurement Period", end of "Measurement Period"])
  and exists(["Assessment, Performed": "VSAC; Weight"] A
    where A.authorDateTime during [24 months before end of "Measurement Period", end of "Measurement Period"])

define "BMI Percentile Exists":
  exists(["Diagnosis": "HEDIS; BMI Percentile"] D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
  or "BMI Percentile, Height, and Weight Exist"

define "Patient <20 with BMI Percentile":
  exists(["Encounter, Performed": "HEDIS; Outpatient"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) < 20)
  and "BMI Percentile Exists"

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
