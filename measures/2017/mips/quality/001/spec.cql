library MIPS_001_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 001
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 001 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Diabetes"
valueset "MIPS; Performance Met: 3046F"
valueset "MIPS; Performance Met: 3046F-8P"
valueset "MIPS; Performance Not Met: 3044F"
valueset "MIPS; Performance Not Met: 3045F"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; HbA1c Laboratory Test": '2.16.840.1.113883.3.464.1003.198.12.1013'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 001 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and AgeInYearsAt(start of E.relevantPeriod) < 75
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Diabetes"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Ordered HbA1c Tests":
  ["Laboratory Test, Performed": "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period"
    sort by L.resultDateTime ASC

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Numerator Performance Met: 3046F":
  /*
   * config_link_id: 3046F
   */
  Last("Ordered HbA1c Test").result > 9
  or exists([Procedure, Performed: "MIPS; Performance Met: 3046F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 3046F-8P":
  /*
   * config_link_id: 3046F-8P
   */
  not exists("Ordered HbA1c Tests")
  or Last("Ordered HbA1c Tests").result = null
  or exists([Procedure, Performed: "MIPS; Performance Met: 3046F-8P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3044F":
  /*
   * config_link_id: 3044F
   */
  Last("Ordered HbA1c Tests").result < 7
  or exists([Procedure, Performed: "MIPS; Performance Not Met: 3044F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3045F":
  /*
   * config_link_id: 3045F
   */
  not "Numerator Performance Met: 3046F"
  and not "Numerator Performance Met: 3046-8P"
  and not "Numerator Performance Not Met: 3044F"
