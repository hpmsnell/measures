library HEDIS_COA1_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: COA1
 * Year: 2018
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Advance Care Planning": '2.16.840.1.113883.3.464.1004.1020'

// Able Value Sets

valueset "Able; Advance Directive"
valueset "Able; Advance Directive Discussed"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Advance Care Planning":
  ["Procedure, Performed": "HEDIS; Advance Care Planning"]
  union ["Procedure, Performed": "Able; Advance Directive"]
  union ["Procedure, Performed": "Able; Advance Directive Discussed"]

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
  exists("Advance Care Planning" P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
