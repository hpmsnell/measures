library HEDIS_COA4_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: COA4
 * Year: 2017
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: G8730" //Pain Assessment
valueset "MIPS; Performance Met: G8731" //Pain Assessment

// HEDIS value sets

valueset "HEDIS; Pain Assessment": '2.16.840.1.113883.3.464.1004.1104'

// Able value sets

valueset "Able; Pain Assessments"
valueset "Able; Standardized Pain Assessment Tool"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Pain Assessment":
  ["Procedure, Performed": "HEDIS; Pain Assessment"]
  union ["Procedure, Performed": "Able; Pain Assessments"]
  union ["Procedure, Performed": "Able; Standardized Pain Assessment Tool"]
  union ["MIPS; Performance Met: G8730"]
  union ["MIPS; Performance Met: G8731"]

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
  exists("Pain Assessment" P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
