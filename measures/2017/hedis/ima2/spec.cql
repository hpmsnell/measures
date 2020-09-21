library HEDIS_IMA2_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: IMA2
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Meningococcal Vaccine Administered": '2.16.840.1.113883.3.464.1004.1177'
valueset "HEDIS; HPV Vaccine Administered": '2.16.840.1.113883.3.464.1004.1112'
valueset "HEDIS; Tdap Vaccine Administered": '2.16.840.1.113883.3.464.1004.1245'
valueset "HEDIS; Analphylactic Reaction Due to Vaccination": '2.16.840.1.113883.3.464.1004.1024'
valueset "HEDIS; Anaphylactic Reaction Due to Serum": '2.16.840.1.113883.3.464.1004.1023'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

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
  exists(["Procedure, Performed": "HEDIS; Tdap Vaccine Administered"] P
    where P.relevantPeriod starts during ["Patient Characteristic Birthdate" + 10 years, "Patient Characteristic Birthdate" + 13 years])
  or exists(["Medication, Administered": "HEDIS; Tdap Vaccine Administered"] M
    where A.authorDateTime during ["Patient Characteristic Birthdate" + 10 years, "Patient Characteristic Birthdate" + 13 years])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
