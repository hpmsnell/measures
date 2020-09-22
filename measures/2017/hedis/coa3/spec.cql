library HEDIS_COA3_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: COA3
 * Year: 2017
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Functional Status Assessment": '2.16.840.1.113883.3.464.1004.1104'

// Able value sets

valueset "Able; Functional Status Assessment"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Functional Status Assessment":
  ["Procedure, Performed": "HEDIS; Functional Status Assessment"]
  union ["Procedure, Performed": "Able; Functional Status Assessment"]

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 66
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Functional Status Assessment" P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
