library HEDIS_COA2_2020

/*
 *
 * Source: HEDIS
 * ID: COA2
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using ADM v1

include "../shared/hedis_shared" called HedisShared

// HEDIS value sets

valueset "HEDIS; MEDICATION_REVIEW": '2.16.840.1.113883.3.464.1004.1175'
valueset "HEDIS; MEDICATION_LIST": '2.16.840.1.113883.3.464.1004.1173'
valueset "HEDIS; TRANSITIONAL_CARE_MANAGEMENT_SERVICES": '2.16.840.1.113883.3.464.1004.1462'
valueset "HEDIS; CPT_CAT_II_MODIFIER": '2.16.840.1.113883.3.464.1004.1464'

parameter "Measurement Period" Interval<DateTime>

context Patient
/* Populations */

define "Initial Population":
  AgeInYearsAt(end of "Measurement Period") >= 66

define "Denominator":
  "Initial Population"

define "Exclusion: Hospice":
  /*
   * Option ID: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * Option ID: performance_met
   */
  "Medication Review" MedReview
    with "Medication List" MedList
      such that MedReview.claim_id = MedList.claim_id
  or exists("Transitional Care")

define "Numerator Performance Not Met":
  /*
   * Option ID: performance_not_met
   */


// Definitions

define "Medication List":
  ["Clinical Activity": "HEDIS; MEDICATION_LIST"] MedList
    where MedList.start_date during "Measurement Period"
      and MedList.place_of_service != '81'
      and FSA.place_of_service not in "HEDIS; ACUTE_INPATIENT_POS"
      and MedList.code_modifiers not in "HEDIS; CPT_CAT_II_MODIFIER"
    with (["Provider"] Provider
      where (
        Provider.prescribing = true
        or Provider.pharmacy_provider = true
      ))
      such that Provider.external_id = MedList.provider_id
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

define "Medication Review":
  ["Clinical Activity": "HEDIS; MEDICATION_REVIEW"] MedReview
  where MedReview.start_date during "Measurement Period"
    and MedReview.place_of_service != '81'
    and FSA.place_of_service not in "HEDIS; ACUTE_INPATIENT_POS"
    and MedReview.code_modifiers not in "HEDIS; CPT_CAT_II_MODIFIER"
  with (["Provider"] Provider
    where (
      Provider.prescribing = true
      or Provider.pharmacy_provider = true
    ))
    such that Provider.external_id = MedReview.provider_id
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

define "Transitional Care":
  ["Clinical Activity": "HEDIS; TRANSITIONAL_CARE_MANAGEMENT_SERVICES"] Trans
    where Trans.start_date during "Measurement Period"
      and Trans.place_of_service != '81'
      and FSA.place_of_service not in "HEDIS; ACUTE_INPATIENT_POS"
      and Trans.code_modifiers not in "HEDIS; CPT_CAT_II_MODIFIER")
    without ["Clinical Activity": "HEDIS; ACUTE_INPATIENT"] Inpatient
      such that (
        (
          Trans.claim_id != null
          and Trans.claim_id = Inpatient.claim_id
        )
        or (
          Trans.claim_id == null
          and Trans.start_date = Inpatient.start_date
        )
      )
