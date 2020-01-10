library HEDIS_IMA1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: IMA1
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

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Vaccine Allergy":
  ["Allergy": "HEDIS: Meningococcal Vaccine Administered"]
  union ["Allergy": "HEDIS: HPV Vaccine Administered"]
  union ["Allergy": "Able: Tdap Vaccine Administered"]

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") = 13
  and not exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "HEDIS; Analphylactic Reaction Due to Vaccination"] D
    where D.prevalencePeriod starts on or before 13 years after "Patient Characteristic Birthdate")
  or exists("Vaccine Allergy" A
    where A.prevalencePeriod starts on or before 13 years after "Patient Characteristic Birthdate")
  or exists(["Diagnosis": "HEDIS; Analphylactic Reaction Due to Serum"] D
    where D.prevalencePeriod starts before 63 months before end of "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Procedure, Performed": "HEDIS; Meningococcal Vaccine Administered"] P
    where P.relevantPeriod starts during ["Patient Characteristic Birthdate" + 11 years, "Patient Characteristic Birthdate" + 13 years])
  or exists(["Medication, Administered": "HEDIS; Meningococcal Vaccine Administered"] M
    where A.authorDateTime during ["Patient Characteristic Birthdate" + 11 years, "Patient Characteristic Birthdate" + 13 years])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
