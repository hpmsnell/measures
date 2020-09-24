library HEDIS_COA4_2020

/*
 *
 * Source: HEDIS
 * ID: COA4
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using ADM v1

include "../shared/hedis_shared" version '1' called HedisShared

// MIPS value sets

valueset "MIPS; PERFORMANCE_MET_G8730" //Pain Assessment
valueset "MIPS; PERFORMANCE_MET_G8731" //Pain Assessment

// HEDIS value sets

valueset "HEDIS; PAIN_ASSESSMENT": '2.16.840.1.113883.3.464.1004.1104'
valueset "HEDIS; CPT_CAT_II_MODIFIER": '2.16.840.1.113883.3.464.1004.1464'

// Able value sets

valueset "Able; PAIN_ASSESSMENTS"
valueset "Able; STANDARDIZED_PAIN_ASSESSMENT_TOOL"

parameter "Measurement Period" Interval<DateTime>

context Patient

/* Populations */

define "Initial Population":
  AgeInYearsAt(end of "Measurement Period") >= 66

define "Denominator":
  "Initial Population"

define "Exclusion: Hospice":
  /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Pain Assessment" PA
    where PA.start_date during "Measurement Period"
      and PA.place_of_service not in "HEDIS; ACUTE_INPATIENT_POS"
      and PA.place_of_service != '81'
      and PA.code_modifiers not in "HEDIS; CPT_CAT_II_MODIFIER"
    without ["Clinical Activity": "HEDIS; ACUTE_INPATIENT"] Inpatient
      such that (
        (
          FSA.claim_id != null
          and FSA.claim_id = Inpatient.claim_id
        )
        or (
          FSA.claim_id == null
          and FSA.start_date = Inpatient.start_date

        )
      )
    )

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"

// Definitions

define "Pain Assessment":
  ["Clinical Activity": "HEDIS; PAIN_ASSESSMENT"]
  union ["Clinical Activity": "Able; PAIN_ASSESSMENTS"]
  union ["Clinical Activity": "Able; STANDARDIZED_PAIN_ASSESSMENT_TOOL"]
  union ["MIPS; PERFORMANCE_MET_G8730"]
  union ["MIPS; PERFORMANCE_MET_G8731"]
