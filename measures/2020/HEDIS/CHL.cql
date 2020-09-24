library HEDIS_CHL_2020

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
  exists("Initial Population"
  and "Sexual Activity Exists")

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
  and exists("Pregnancy Test Exclusion" preg_test
    with "Retinoid or Diagnostic Radiology" retiniod_rad
      such that preg_test.start_date on or 6 days or less before retiniod_rad.start_date)

define "Numerator Performance Met":
  /*
   * Option ID: performance_met
   */
  exists("Chlamydia Tests" P
    where P.start_date starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * Option ID: performance_not_met
   */

// Definitions

define "Denominator Pregnancy":
  (["Diagnosis": "HEDIS; PREGNANCY"]) pregnancy
    with (["Clinical Activity"]) any_encounter //ANY encounter
      such that P.claim_id = E.claim_id
    where pregnancy.start_date starts during "Measurement Period"
    and pregnancy.supplemental = false
    and pregnancy.place_of_service != 81
    and any_encounter.supplemental = false
    and any_encounter.place_of_service != 81

define "Denominator Sexual Activity":
  ((["Diagnosis": "HEDIS; SEXUAL_ACTIVITY"]) sexual_activity
    where sexual_activity.start_date  during "Measurement Period"
      and sexual_activity.supplemental = false
    )
  union ((["Clinical Activity": "HEDIS; SEXUAL_ACTIVITY"]) sexual_activity1
    where sexual_activity1.start_date starts during "Measurement Period"
      and sexual_activity1.supplemental = false
    )

define "Denominator Pregnancy Tests":
  (["Clinical Activity": "HEDIS; PREGNANCY_TESTS"]) preg_test
    where preg_test.start_date during "Measurement Period"
      and preg_test.supplemental = false

define "Denominator Contraceptive Medications":
  (["Medication": "NCQA; CONTRACEPTIVE_MEDICATIONS"]) contraceptive_med
    where contraceptive_med.start_date during "Measurement Period"
      and contraceptive_med.supplemental = false
      and contraceptive_med.dispensed = true

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
  ["Clinical Activity": "HEDIS; PREGNANCY_TEST_EXCLUSION"]
  union ["Laboratory Test Performed": "HEDIS; PREGNANCY_TEST_EXCLUSION"]

define "Retinoid or Diagnostic Radiology":
  (["Clinical Activity": "HEDIS; DIAGNOSTIC_RADIOLOGY"]) Radiology
    where Radiology.place_of_service != 81
  union (["Medication": "NCQA; RETINOID_MEDICATIONS"]) Meds
    where Meds.dispensed = true

define "Chlamydia Tests":
  ["Clinical Activity": "HEDIS; CHLAMYDIA_TESTS"]
  union ["Laboratory Test Performed": "HEDIS; CHLAMYDIA_TESTS"]
