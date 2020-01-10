library HEDIS_IMA5_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: IMA Combination 2
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Meningococcal Vaccine Administered": '2.16.840.1.113883.3.464.1004.1177'
valueset "HEDIS; HPV Vaccine Administered": '2.16.840.1.113883.3.464.1004.1112'
valueset "HEDIS; Tdap Vaccine Administered": '2.16.840.1.113883.3.464.1004.1245'
valueset "HEDIS; Analphylactic Reaction Due to Vaccination": '2.16.840.1.113883.3.464.1004.1024'
valueset "HEDIS; Anaphylactic Reaction Due to Serum": '2.16.840.1.113883.3.464.1004.1023'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Populations

define "Denominator":
  "HEDIS IMA1: Denominator"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  "HEDIS IMA1: Denominator Exclusion"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "HEDIS IMA1: Performance Met"
  and "HEDIS IMA2: Performance Met"
  and "HEDIS IMA3: Performance Met"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
