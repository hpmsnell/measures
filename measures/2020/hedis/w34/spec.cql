library HEDIS_W34_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: W34
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Well-Care": '2.16.840.1.113883.3.464.1004.1262'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 3
  and AgeInYearsAt(end of "Measurement Period") < 7
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Encounter, Performed": "HEDIS; Well-Care"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.primaryCareProvider = true)
  or exists(["Diagnosis": "HEDIS; Well-Care"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.primaryCareProvider = true)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
