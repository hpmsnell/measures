library HEDIS_CHL_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: CHL
 * Year: 2019
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

valueset "NCQA; Retinoid Medications": '2.16.840.1.113883.3.464.1004.2172'
valueset "NCQA; Contraceptive Medications": '2.16.840.1.113883.3.464.1004.2048'

parameter "Measurement Period" Interval<DateTime>

context Patient


define "Denominator Pregnancy":
  (["Diagnosis": "HEDIS; Pregnancy"]) P
    with (["Encounter, Performed"]) E //ANY encounter
      such that P.claimId = E.claimId
    where P.prevalencePeriod starts during "Measurement Period"
    and P.supplemental = false
    and P.placeOfService != 81
    and E.supplemental = false
    and E.placeOfService != 81

define "Denominator Sexual Activity":
  ((["Diagnosis": "HEDIS; Sexual Activity"]) P
    where P.prevalencePeriod starts during "Measurement Period"
      and P.supplemental = false
    )
  union ((["Procedure, Performed": "HEDIS; Sexual Activity"]) P
    where P.relevantPeriod starts during "Measurement Period"
      and P.supplemental = false
    )

define "Denominator Pregnancy Tests":
  (["Procedure, Performed": "HEDIS; Pregnancy Tests"]) P
    where P.relevantPeriod starts during "Measurement Period"
      and P.supplemental = false

define "Denominator Contraceptive Medications":
  (["Medication, Dispensed": "NCQA; Contraceptive Medications"]) P
    where P.relevantPeriod starts during "Measurement Period"
      and P.supplemental = false

define "Sexual Activity Exists":
  exists (
    "Denominator Pregnancy"
    union "Denominator Sexual Activity"
    union "Denominator Pregnancy Tests"
    union "Denominator Contraceptive Medications"
  )

define "Only Pregnancy Test Exists":
  exists ("Denominator Pregnancy Tests")
  and not exists (
    "Denominator Pregnancy"
    union "Denominator Sexual Activity"
    union "Denominator Contraceptive Medications"
  )

define "Pregnancy Test Exclusion":
  ["Procedure, Performed": "HEDIS; Pregnancy Test Exclusion"]
  union ["Laboratory Test, Performed": "HEDIS; Pregnancy Test Exclusion"]

define "Retinoid or Diagnostic Radiology":
  (["Procedure, Performed": "HEDIS; Diagnostic Radiology"]) Radiology
    where Radiology.placeOfService != 81
  union (["Medication, Dispensed": "NCQA; Retinoid Medications"]) Meds

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
