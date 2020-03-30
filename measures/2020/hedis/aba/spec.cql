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

// HEDIS value sets

valueset "HEDIS; BMI": '2.16.840.1.113883.3.464.1004.1037'
valueset "HEDIS; BMI Percentile": '2.16.840.1.113883.3.464.1004.1038'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "BMI":
  ["Assessment, Performed": "HEDIS; BMI"]
  union ["Diagnosis": "HEDIS; BMI"]

define "Patient 20+ with BMI":
  exists(["Encounter, Performed": "HEDIS; Outpatient"] Outpatient
    where Outpatient.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of Outpatient.relevantPeriod) >= 20
      and Outpatient.supplemental = false)
  and exists("BMI" BMI
    where BMI.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
      and BMI.placeOfService != '81')

define "BMI Percentile":
  ["Diagnosis": "HEDIS; BMI Percentile"]
  union ["Assessment, Performed": "HEDIS; BMI Percentile"]

define "Patient <20 with BMI Percentile":
  exists(["Encounter, Performed": "HEDIS; Outpatient"] Outpatient
    where Outpatient.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of Outpatient.relevantPeriod) < 20
      and Outpatient.supplemental = false)
  and exists("BMI Percentile" BMIPercentile
    where BMIPercentile.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
      and BMIPercentile.placeOfService != '81')

// Populations

define "Initial Population":
  AgeInYearsAt(24 months before end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 75

define "Denominator":
  "Initial Population"
  and exists(["Encounter, Performed": "HEDIS; Outpatient"] Outpatient
    where Outpatient.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
      and Outpatient.supplemental = false

define "Exclusion: Hospice":
  /*
   * config_link_id: exclusion_required_hospice
   */
  exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_optional_pregnancy
   */
  "Patient Characteristic Sex" = "Female"
  and exists(["Diagnosis": "HEDIS; Pregnancy"] Pregnancy
    where Pregnancy.prevalencePeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"])

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
