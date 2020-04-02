library HEDIS_CCS_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CCS
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Cervical Cytology Lab Test": '2.16.840.1.113883.3.464.1004.1525'
valueset "HEDIS; Cervical Cytology Result or Finding": '2.16.840.1.113883.3.464.1004.1524'
valueset "HEDIS; High Risk HPV Lab Test": '2.16.840.1.113883.3.464.1004.1527'
valueset "HEDIS; High Risk HPV Test Result or Finding": '2.16.840.1.113883.3.464.1004.1526'
valueset "HEDIS; Hysterectomy With No Residual Cervix": '2.16.840.1.113883.3.464.1004.1523'
valueset "HEDIS; Absence of Cervix Diagnosis": '2.16.840.1.113883.3.464.1004.1522'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Cervical Cytology 24-64 within 3 years":
  (["Procedure, Performed": "HEDIS; Cervical Cytology Lab Test"]
  union ["Laboratory Test, Performed": "HEDIS; Cervical Cytology Lab Test"]
  union ["Laboratory Test, Performed": "HEDIS; Cervical Cytology Result or Finding"]) CervicalCytology
    where CervicalCytology.result is not null
      and AgeInYearsAt(end of "Measurement Period") >= 24
      and AgeInYearsAt(end of "Measurement Period") <= 64
      and CervicalCytology.relevantPeriod starts 36 months or less before end of "Measurement Period"

define "HPV Test 30-64 within 5 years":
  (["Procedure, Performed": "HEDIS; High Risk HPV Lab Test"]
  union ["Laboratory Test, Performed": "HEDIS; High Risk HPV Lab Test"]
  union ["Laboratory Test, Performed": "HEDIS; High Risk HPV Test Result or Finding"])HPVTest
    where HPVTest.result is not null
      and AgeInYearsAt(end of "Measurement Period") >= 30
      and AgeInYearsAt(end of "Measurement Period") <= 64
      and AgeInYearsAt(start of HPVTest.relevantPeriod) >= 30
      and HPVTest.relevantPeriod starts 60 months or less before end of "Measurement Period"

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 24
  and AgeInYearsAt(end of "Measurement Period") < 65
  and "Patient Characteristic Sex" = "Female"

define "Exclusion: Hospice":
	   /*
	   * config_link_id: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_optional_cervix
   */
  exists(["Procedure, Performed": "HEDIS; Hysterectomy With No Residual Cervix"] P
    where P.relevantPeriod starts before end of "Measurement Period"
      and P.placeOfService != '81')
  or exists(["Diagnosis": "HEDIS; Absence of Cervix Diagnosis"] D
    where D.prevalencePeriod starts before end of "Measurement Period"
      and D.placeOfService != '81')

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
