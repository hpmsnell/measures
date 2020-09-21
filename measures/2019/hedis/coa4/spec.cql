library HEDIS_COA4_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: COA4
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// MIPS value sets

valueset "MIPS; Performance Met: G8730" //Pain Assessment
valueset "MIPS; Performance Met: G8731" //Pain Assessment

// HEDIS value sets

valueset "HEDIS; Pain Assessment": '2.16.840.1.113883.3.464.1004.1104'
valueset "HEDIS; CPT CAT II Modifier": '2.16.840.1.113883.3.464.1004.1464'

// Able value sets

valueset "Able; Pain Assessments"
valueset "Able; Standardized Pain Assessment Tool"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Pain Assessment":
  ["Procedure, Performed": "HEDIS; Pain Assessment"]
  union ["Procedure, Performed": "Able; Pain Assessments"]
  union ["Procedure, Performed": "Able; Standardized Pain Assessment Tool"]
  union ["MIPS; Performance Met: G8730"]
  union ["MIPS; Performance Met: G8731"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 66

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
      and PA.code.placeOfService not in "HEDIS; Acute Inpatient POS"
      and PA.placeOfService != '81'
      and PA.code.modifiers not in "HEDIS; CPT CAT II Modifier"
    without ["Procedure, Performed": "HEDIS; Acute Inpatient"] Inpatient
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
