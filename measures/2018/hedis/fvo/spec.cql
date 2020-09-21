library HEDIS_FVO_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: FVO
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// VSAC value sets

valueset "VSAC; Influenza Vaccination" '2.16.840.1.113883.3.526.3.402'
valueset "VSAC; Influenza Vaccine" '2.16.840.1.113883.3.526.2.1351'
valueset "VSAC; Previous Receipt of Influenza Vaccine" '2.16.840.1.113883.3.526.3.1185'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Influenza Vaccine":
  ["Medication, Administered": "Influenza Vaccine"]
  union ["Procedure, Performed": "Influenza Vaccination"]
  union ["Communication: From Patient to Provider": "Previous Receipt of Influenza Vaccine"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 65

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Influenza Vaccine" P
    where P.relevantPeriod starts during [6 months before end of "Measurement Period", end of "Measurement Period"])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
