library HEDIS_CHL_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CHL
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using ADM v1

include "../shared/hedis_shared" called HedisShared

// MIPS value sets

valueset "MIPS; Performance Met: G9820" //Chlamydia Screening

// HEDIS value sets

valueset "HEDIS; PREGNANCY": '2.16.840.1.113883.3.464.1004.1219'
valueset "HEDIS; PREGNANCY_TESTS": '2.16.840.1.113883.3.464.1004.1221'
valueset "HEDIS; SEXUAL_ACTIVITY": '2.16.840.1.113883.3.464.1004.1238'
valueset "HEDIS; PREGNANCY_TEST_EXCLUSION": '2.16.840.1.113883.3.464.1004.1344'
valueset "HEDIS; DIAGNOSTIC_RADIOLOGY": '2.16.840.1.113883.3.464.1004.1081'
valueset "HEDIS; CHLAMYDIA_TESTS": '2.16.840.1.113883.3.464.1004.1060'

// NCQA medication list value sets

valueset "NCQA; RETINOID_MEDICATIONS": '2.16.840.1.113883.3.464.1004.2172'
valueset "NCQA; CONTRACEPTIVE_MEDICATIONS": '2.16.840.1.113883.3.464.1004.2048'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Populations

define "Initial Population":
  AgeInYearsAt(end of "Measurement Period") >= 16
  and AgeInYearsAt(end of "Measurement Period") < 25
  and sex = "Female"

define "Denominator":
  "Initial Population"
  and "Sexual Activity Exists"

define "Exclusion: Hospice":
	 /*
	 * Option ID: exclusion_required_hospice
	 */
	   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion":
  /*
   * Option ID: exclusion_optional_pregnancy
   */
  "Only Pregnancy Test Exists"
  and exists("Pregnancy Test Exclusion" L
    with "Retinoid or Diagnostic Radiology" P
      such that L.resultDateTime on or 6 days or less before start of P.relevantPeriod)

define "Numerator Performance Met":
  /*
   * Option ID: performance_met
   */
  exists("Chlamydia Tests" P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * Option ID: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"

// Definitions

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
  union ((["Clinical Activity": "HEDIS; Sexual Activity"]) P
    where P.relevantPeriod starts during "Measurement Period"
      and P.supplemental = false
    )

define "Denominator Pregnancy Tests":
  (["Clinical Activity": "HEDIS; Pregnancy Tests"]) P
    where P.start_date starts during "Measurement Period"
      and P.supplemental = false

define "Denominator Contraceptive Medications":
  (["Medication": "NCQA; Contraceptive Medications"]) P
    where P.start_date during "Measurement Period"
      and P.supplemental = false
      and P.dispensed = true

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
  ["Clinical Activity": "HEDIS; Pregnancy Test Exclusion"]
  union ["Laboratory Test Performed": "HEDIS; Pregnancy Test Exclusion"]

define "Retinoid or Diagnostic Radiology":
  (["Clinical Activity": "HEDIS; Diagnostic Radiology"]) Radiology
    where Radiology.placeOfService != 81
  union (["Medication": "NCQA; Retinoid Medications"]) Meds
    where Meds.dispensed = true

define "Chlamydia Tests":
  ["Clinical Activity": "HEDIS; Chlamydia Tests"]
  union ["Laboratory Test Performed": "HEDIS; Chlamydia Tests"]
  union ["Clinical Activity": "MIPS; Performance Met: G9820"]
