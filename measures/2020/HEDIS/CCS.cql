library HEDIS_CCS_2020

/*
 *
 * Source: HEDIS
 * ID: CCS
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using ADM v1

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; CERVICAL_CYTOLOGY_LAB_TEST": '2.16.840.1.113883.3.464.1004.1525'
valueset "HEDIS; CERVICAL_CYTOLOGY_RESULT_OR_FINDING": '2.16.840.1.113883.3.464.1004.1524'
valueset "HEDIS; HIGH_RISK_HPV_LAB_TEST": '2.16.840.1.113883.3.464.1004.1527'
valueset "HEDIS; HIGH_RISK_HPV_TEST_RESULT_OR_FINDING": '2.16.840.1.113883.3.464.1004.1526'
valueset "HEDIS; HYSTERECTOMY_WITH NO_RESIDUAL_CERVIX": '2.16.840.1.113883.3.464.1004.1523'
valueset "HEDIS; ABSENCE_OF_CERVIX_DIAGNOSIS": '2.16.840.1.113883.3.464.1004.1522'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Populations

define "Inital Population":
    AgeInYearsAt(end of "Measurement Period") >= 24
    and AgeInYearsAt(end of "Measurement Period") < 65
    and sex = "Female"

define "Denominator":
    "Inital Population"

define "Exclusion: Hospice":
	   /*
	   * config_link_id: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_optional_cervix
   */
  exists(["Clinical Activity": "HEDIS; HYSTERECTOMY_WITH_NO_RESIDUAL_CERVIX"] P
    where P.start_date before end of "Measurement Period"
      and P.place_of_Service != '81')
  or exists(["Diagnosis": "HEDIS; ABSENCE_OF_CERVIX_DIAGNOSIS"] D
    where D.start_date before end of "Measurement Period"
      and D.place_of_Service != '81')

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Cervical Cytology 24-64 within 3 years"
    union "HPV Test 30-64 within 5 years"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"

// Definitions

define "Cervical Cytology 24-64 within 3 years":
  (["Clinical Activity": "HEDIS; CERVICAL_CYTOLOGY_LAB_TEST"]
  union ["Clinical Activity": "HEDIS; CERVICAL_CYTOLOGY_RESULT_OR_FINDING"]
  union ["Laboratory Test Performed": "HEDIS; CERVICAL_CYTOLOGY_LAB_TEST"]
  union ["Laboratory Test Performed": "HEDIS; CERVICAL_CYTOLOGY_RESULT_OR_FINDING"]) CervicalCytology
    where CervicalCytology.result is not null
      and AgeInYearsAt(end of "Measurement Period") >= 24
      and AgeInYearsAt(end of "Measurement Period") <= 64
      and CervicalCytology.start_date 36 months or less before end of "Measurement Period"

define "HPV Test 30-64 within 5 years":
  (["Clinical Activity": "HEDIS; HIGH_RISK_HPV_LAB_TEST"]
  union ["Clinical Activity": "HEDIS; HIGH_RISK_HPV_TEST_RESULT_OR_FINDING"]
  union ["Laboratory Test Performed": "HEDIS; HIGH_RISK_HPV_LAB_TEST"]
  union ["Laboratory Test Performed": "HEDIS; HIGH_RISK_HPV_TEST_RESULT_OR_FINDING"])HPVTest
    where HPVTest.result is not null
      and AgeInYearsAt(end of "Measurement Period") >= 30
      and AgeInYearsAt(end of "Measurement Period") <= 64
      and AgeInYearsAt(start of HPVTest.relevantPeriod) >= 30
      and HPVTest.start_date 60 months or less before end of "Measurement Period"
