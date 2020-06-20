library HEDIS_IMA3_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: IMA3
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Meningococcal Immunization": '2.16.840.1.113883.3.464.1004.1777'
valueset "HEDIS; Meningococcal Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1778'
valueset "HEDIS; HPV Immunization": '2.16.840.1.113883.3.464.1004.1763'
valueset "HEDIS; HPV Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1764'
valueset "HEDIS; Tdap Immunization": '2.16.840.1.113883.3.464.1004.1791'
valueset "HEDIS; Tdap Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1792'
valueset "HEDIS; Analphylactic Reaction Due to Vaccination": '2.16.840.1.113883.3.464.1004.1024'
valueset "HEDIS; Anaphylactic Reaction Due to Serum": '2.16.840.1.113883.3.464.1004.1023'
valueset "HEDIS; Encephalopathy Due To Vaccination": '2.16.840.1.113883.3.464.1004.1092'


parameter "Measurement Period" Interval<DateTime>

context Patient

define "Vaccine Administered Between 9th and 13th Birthday":
  (["Immunization, Administered": "HEDIS; HPV Immunization"]
  union ["Procedure Performed": "HEDIS; HPV Vaccine Procedure]) HPVVacc
    where HPVVacc.relevantDateTime during Interval["Patient Characteristic Birthdate" + 9 years, "Patient Characteristic Birthdate" + 13 years]

// Populations

define "Denominator":
  "HEDIS IMA1: Denominator"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  "HEDIS IMA1: Denominator Exclusion"

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Vaccine Administered Between 9th and 13th Birthday" P1
    with "Vaccine Administered Between 9th and 13th Birthday" P2
      such that P1.relevantPeriod starts 146 days or more before P2.relevantPeriod)
  or exists("Vaccine Administered Between 9th and 13th Birthday" P1
    with "Vaccine Administered Between 9th and 13th Birthday" P2
      with "Vaccine Administered Between 9th and 13th Birthday" P3
        such that P2.relevantPeriod starts 1 day or more before P3.relevantPeriod
      such that P1.relevantPeriod starts 1 day or more before M2.relevantPeriod)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
