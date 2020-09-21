library HEDIS_IMA1_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: IMA1
 * Year: 2019
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

define "Meningococcal Vaccination":
  (["Immunization, Administered": "HEDIS; Meningococcal Immunization"]
  union ["Procedure Performed": "HEDIS; Meningococcal Vaccine Procedure"]) MeningVacc
    where MeningVacc.relevantDateTime during Interval["Patient Characteristic Birthdate" + 11 year, "Patient Characteristic Birthdate" + 13 years]

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") = 13

define "Denominator Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Allergy":
   /*
    * config_link_id: exclusion_optional_allergy
    */
   exists(["Diagnosis": "HEDIS; Analphylactic Reaction Due to Vaccination"] D
     where D.prevalencePeriod starts on or before "Patient Characteristic Birthdate" + 13 years)
   or exists(["Diagnosis": "HEDIS; Analphylactic Reaction Due to Serum"] D
     where D.prevalencePeriod starts before end of "Measurement Period" - 63 months)
   or exists(["Diagnosis": "HEDIS; Encephalopathy Due To Vaccination"] D
     where D.prevalencePeriod starts on or before "Patient Characteristic Birthdate" + 13 years)

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */

  exists("Meningococcal Vaccination")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Hospice"
  and not "Denominator Exclusion: Allergy"
  and not "Numerator Performance Met"
