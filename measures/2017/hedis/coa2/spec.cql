library HEDIS_COA2_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: COA2
 * Year: 2017
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// VSAC value sets

valueset "VSAC; Current Medications Documented SNMD"

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Medication Review": '2.16.840.1.113883.3.464.1004.1175'
valueset "HEDIS; Medication List": '2.16.840.1.113883.3.464.1004.1173'
valueset "HEDIS; Transitional Care Management Services": '2.16.840.1.113883.3.464.1004.1462'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Medication List":
  ["Procedure, Performed": "HEDIS; Medication List"]
  union ["Procedure, Performed": "VSAC; Current Medications Documented SNMD"]

define "Medication Review Exists":
  exists(["Procedure, Performed": "HEDIS; Medication Review"] P
    where P.relevantPeriod starts during "Measurement Period")
  and exists("Medication List Exists" P
    where P.relevantPeriod starts during "Measurement Period")

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
  "Medication Review Exists"
  or exists(["Procedure, Performed": "HEDIS; Transitional Care Management Sercices"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
