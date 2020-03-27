library HEDIS_CHL_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CHL
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// MIPS value sets

valueset "MIPS; Performance Met: G9820" //Chlamydia Screening

// HEDIS value sets

valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'
valueset "HEDIS; Pregnancy Tests": '2.16.840.1.113883.3.464.1004.1221'
valueset "HEDIS; Sexual Activity": '2.16.840.1.113883.3.464.1004.1238'
valueset "HEDIS; Pregnancy Test Exclusion": '2.16.840.1.113883.3.464.1004.1344'
valueset "HEDIS; Diagnostic Radiology": '2.16.840.1.113883.3.464.1004.1081'
valueset "HEDIS; Chlamydia Tests": '2.16.840.1.113883.3.464.1004.1060'

// NCQA medication list value sets

valueset "NCQA; Retinoid Medications"
valueset "NCQA; Contraceptive Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Diagnosis":
  ["Diagnosis": "HEDIS; Pregnancy"]
  union ["Diagnosis": "HEDIS; Sexual Activity"]

define "Denominator Procedure":
  ["Procedure, Performed": "HEDIS; Pregnancy Tests"]
  union ["Procedure, Performed": "HEDIS; Sexual Activity"]

define "Sexual Activity Exists":
  exists("Denominator Procedure" P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Denominator Diagnosis" D
    where D.prevalencePeriod starts during "Measurement Period")
  or exists(["Medication, Dispensed": "NCQA; Contraceptive Medications"] M
    where M.relevantPeriod starts during "Measurement Period")

define "Only Pregnancy Test Exists":
  not exists(["Procedure, Performed": "HEDIS; Sexual Activity"] P
    where P.relevantPeriod starts during "Measurement Period")
  and not exists("Denominator Diagnosis" D
    where D.relevantPeriod overlaps "Measurement Period")

define "Pregnancy Test Exclusion":
  ["Procedure, Performed": "HEDIS; Pregnancy Test Exclusion"]
  union ["Laboratory Test, Performed": "HEDIS; Pregnancy Test Exclusion"]

define "Retinoid or Diagnostic Radiology":
  ["Procedure, Performed": "HEDIS; Diagnostic Radiology"]
  union ["Medication, Dispensed": "NCQA; Retinoid Medications"]

define "Chlamydia Tests":
  ["Procedure, Performed": "HEDIS; Chlamydia Tests"]
  union ["Laboratory Test, Performed": "HEDIS; Chlamydia Tests"]
  union ["Procedure, Performed": "MIPS; Performance Met: G9820"]

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 16
  and AgeInYearsAt(end of "Measurement Period") < 25
  and "Patient Characteristic Sex" = "Female"
  and "Sexual Activity Exists"

define "Exclusion: Hospice":
	   /*
	   * config_link_id: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_optional_pregnancy
   */
  "Only Pregnancy Test Exists"
  and exists("Pregnancy Test Exclusion" L
    with "Retinoid or Diagnostic Radiology" P
      such that L.resultDateTime on or 6 days or less before start of P.relevantPeriod)

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Chlamydia Tests" P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
