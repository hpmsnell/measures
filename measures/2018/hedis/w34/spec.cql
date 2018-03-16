library HEDIS_W34_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: W34
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Well-Care": '2.16.840.1.113883.3.464.1004.1262'

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

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
    where E.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "HEDIS; Well-Care"] E
    where E.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
