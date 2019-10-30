library HEDIS_PPC2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: PPC2
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Deliveries": '2.16.840.1.113883.3.464.1004.1072'
valueset "HEDIS; Non-live Births": '2.16.840.1.113883.3.464.1004.1187'
valueset "HEDIS; Cervical Cytology": '2.16.840.1.113883.3.464.1004.1208'
valueset "HEDIS; Postpartum Visits": '2.16.840.1.113883.3.464.1004.1218'
valueset "HEDIS; Postpartum Bundled Services": '2.16.840.1.113883.3.464.1004.1217'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Delivery":
  ["Procedure, Performed": "HEDIS; Deliveries"] P1
    where P1.relevantPeriod starts during [56 days before start of "Measurement Period", 56 days before end of "Measurement Period"]

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Postpartum Visit":
  ["Procedure, Performed": "HEDIS; Cervical Cytology"]
  union ["Laboratory Test, Performed": "HEDIS; Cervical Cytology"]
  union ["Encounter, Performed": "HEDIS; Postpartum Visits"]
  union ["Diagnosis": "HEDIS; Postpartum Visits"]
  union ["Procedure, Performed": "HEDIS; Postpartum Bundled Services"]

// Populations

define "Denominator":
  "Delivery" P1
    where "Patient Characteristic Sex" = 'Female'
    without ["Diagnosis": "HEDIS; Non-live Births"] D
      such that D.prevalencePeriod starts during P1.relevantPeriod
    without "Delivery" P2
      such that P1.relevantPeriod starts 6 months or less before start of P2.relevantPeriod
    without "Hospice" I
      such that I.authorDateTime during "Measurement Period"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Delivery" P
    with "Postpartum Visit" E
      such that E.relevantPeriod starts during [21 days after start of P.relevantPeriod, 56 days after start of P.relevantPeriod]

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
