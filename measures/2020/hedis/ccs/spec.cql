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

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Cervical Cytology": '2.16.840.1.113883.3.464.1004.1208'
valueset "HEDIS; HPV Tests": '2.16.840.1.113883.3.464.1004.1265'
valueset "HEDIS; Absence of Cervix": '2.16.840.1.113883.3.464.1004.1123'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Cervical Cytology":
  ["Procedure, Performed": "HEDIS; Cervical Cytology"]
  union ["Laboratory Test, Performed": "HEDIS; Cervical Cytology"]

define "HPV Test":
  ["Procedure, Performed": "HEDIS; HPV Tests"]
  union ["Laboratory Test, Performed": "HEDIS; HPV Tests"]

define "Patient 30-64 with Cervical Cytology and HPV Test":
  exists("Certival Cytology" P1
    where P1.relevantPeriod starts during [60 months before end of "Measurement Period", end of "Measurement Period"
      and AgeInYearsAt(start of P1.relevantPeriod) >= 30
    with "HPV Test" P2
      where AgeInYearsAt(start of P2.relevantPeriod) >= 30
      such that P1.relevantPeriod starts on or after 4 days before start of P2.relevantPeriod
        and P1.relevantPeriod starts on or before 4 days after start of P2.relevantPeriod)

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 24
  and AgeInYearsAt(end of "Measurement Period") < 65
  and "Patient Characteristic Sex" = "Female"
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "HEDIS; Absence of Cervix"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Diagnosis": "HEDIS; Absence of Cervix"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Cervical Cytology" P
    where P.relevantPeriod starts during [36 months before end of "Measurement Period", end of "Measurement Period")
  or "Patient 30-64 with Cervical Cytology and HPV Test"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
