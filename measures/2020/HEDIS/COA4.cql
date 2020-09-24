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

valueset "HEDIS; PAIN ASSESSMENT": '2.16.840.1.113883.3.464.1004.1104'
valueset "HEDIS; CPT_CAT_II_MODIFIER": '2.16.840.1.113883.3.464.1004.1464'

// Able value sets

valueset "Able; PAIN_ASSESSMENTS"
valueset "Able; STANDARDIZED_PAIN_ASSESSMENT_TOOL"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Pain Assessment":
  ["Procedure, Performed": "HEDIS; PAIN_ASSESSMENT"]
  union ["Procedure, Performed": "Able; PAIN_ASSESSMENTS"]
  union ["Procedure, Performed": "Able; STANDARDIZED_PAIN_ASSESSMENT_TOOL"]
  union ["MIPS; PERFORMANCE_MET_G8730"]
  union ["MIPS; PERFORMANCE_MET_G8731"]

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
    where PA.relevantPeriod starts during "Measurement Period"
      and PA.code.placeOfService not in "HEDIS; ACUTE_INPATIENT_POS"
      and PA.placeOfService != '81'
      and PA.code.modifiers not in "HEDIS; CPT_CAT_II_MODIFIER"
    without ["Procedure, Performed": "HEDIS; ACUTE_INPATIENT"] Inpatient
      such that (
        (
          FSA.claimId != null
          and FSA.claimId = Inpatient.claimId
        )
        or (
          FSA.claimId == null
          and FSA.startDate = Inpatient.startDate

        )
      )
    )

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
