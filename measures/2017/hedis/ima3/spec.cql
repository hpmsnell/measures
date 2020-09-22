library HEDIS_IMA3_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: IMA3
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

define "Vaccine Administered Between 9th and 13th Birthday":
  ["Procedure, Performed": "HEDIS; HPV Vaccine Administered"] P
    where P.relevantPeriod starts during ["Patient Characteristic Birthdate" + 9 years, "Patient Characteristic Birthdate" + 13 years]

define "Vaccine Between 9th and 13th Birthday":
  ["Medication, Administered": "HEDIS; HPV Vaccine Administered"] M
    where A.authorDateTime during ["Patient Characteristic Birthdate" + 9 years, "Patient Characteristic Birthdate" + 13 years]

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
  exists("Vaccine Administered Between 9th and 13th Birthday" P1
    with "Vaccine Administered Between 9th and 13th Birthday" P2
      such that P1.relevantPeriod starts 146 days or more before P2.relevantPeriod)
  or exists("Vaccine Administered Between 9th and 13th Birthday" P1
    with "Vaccine Administered Between 9th and 13th Birthday" P2
      with "Vaccine Administered Between 9th and 13th Birthday" P3
        such that P2.relevantPeriod starts 1 day or more before P3.relevantPeriod
      such that P1.relevantPeriod starts 1 day or more before M2.relevantPeriod)
   or exists("Vaccine Between 9th and 13th Birthday" M1
     with "Vaccine Between 9th and 13th Birthday" M2
       such that M1.relevantPeriod starts 146 days or more before M2.relevantPeriod)
   or exists("Vaccine Between 9th and 13th Birthday" M1
     with "Vaccine Between 9th and 13th Birthday" M2
       with "Vaccine Between 9th and 13th Birthday" M3
         such that M2.relevantPeriod starts 1 day or more before M3.relevantPeriod
       such that M1.relevantPeriod starts 1 day or more before M2.relevantPeriod)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
