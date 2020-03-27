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

include "../shared/hedis_shared" version '1' called HedisShared

// MIPS value sets

valueset "MIPS; Performance Met: G8420"
valueset "MIPS; Performance Met: G8417"
valueset "MIPS; Performance Met: G8418"
valueset "MIPS; Denominator Exception: G8416"
valueset "MIPS; Performance Not Met: G8419"

// HEDIS value sets

valueset "HEDIS; BMI": '2.16.840.1.113883.3.464.1004.1037'
valueset "HEDIS; BMI Percentile": '2.16.840.1.113883.3.464.1004.1038'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'

// VSAC value sets

valueset "VSAC; BMI LOINC Value": '2.16.840.1.113883.3.600.1.681'
valueset "VSAC; BMI percentile": '2.16.840.1.113883.3.464.1003.121.12.1012'

parameter "Measurement Period" Interval<DateTime>

context Patient

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

define "Initial Population":
  AgeInYearsAt(24 months before end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 75

define "Denominator":
  "Initial Population"
  and exists(["Encounter, Performed": "HEDIS; Outpatient"] E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
      and E.supplemental = false

define "Exclusion: Hospice":
  /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_optional_pregnancy
   */
  exists(["Diagnosis": "HEDIS; Pregnancy"] D
    where D.prevalencePeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"])

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
