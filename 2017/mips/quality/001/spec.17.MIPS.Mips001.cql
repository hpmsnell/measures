library MIPS_001_2017 version '1'

/*
 * THIS MEASURE IS NOT READY!!!!
 *
 * Source: MIPS
 * ID: 001
 * Year: 2017
 * Version: 1
 * Clinical Lead: Calvin Newman
 * Engineer: TBD
 * Q/A Reviewer: TBD
 * Date of Validation:
 *
 * THIS MEASURE IS NOT READY!!!!
 *
  */

using QDM

// Able custom value sets

valueset "MIPS; MIPS 001 Encounters"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 3046F"
valueset "MIPS; Performance Met: 3046F-8P"
valueset "MIPS; Performance Not Met: 3044F"
valueset "MIPS; Performance Not Met: 3045F"

// CMS created VSACs

valueset "VSAC; Diabetes": '2.16.840.1.113883.3.464.1003.103.11.1002' //Note this is the value set for the ICD-10-CM extensional value set—only import ICD-10-CM codes
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; HbA1c Laboratory Test": '2.16.840.1.113883.3.464.1003.198.12.1013'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and AgeInYearsAt(start of "Measurement Period") < 75
  and exists([Diagnosis: "Diagnosis of Diabates"] D
    where D.prevalencePeriod overlaps "Measurement Period")
  and exists([Encounter, Performed: "MIPS; 001 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
    and E.signingProvider.pqrsProvider = true)

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion
   */
  exists([Intervention, Performed: "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists([Intervention, Performed: "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: 3046F":
  /*
   * config_link_id: 3046F
   */
  Last([Laboratory Test, Performed: "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period").result.value > 9 //Note that this is verifying the result of the last test
  or exists([Procedure, Performed: "MIPS; Performance Met: 3046F"] P
    where P.relevantPeriod starts during "Measurement Period")
  )

define "Numerator Performance Met: 3046-8P":
  /*
   * config_link_id: 3046F-8P
   */
  not exists(Laboratory Test, Performed: "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period")
  or exists([Procedure, Performed: "MIPS; Performance Met: 3046F-8P"] P
    where P.relevantPeriod starts during "Measurement Period")
  )

define "Numerator Performance Not Met: 3044F":
  /*
   * config_link_id: 3044F
   */
  Last([Laboratory Test, Performed: "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period").result.value < 7
  or exists([Procedure, Performed: "MIPS; Performance Not Met: 3044F"] P
    where P.relevantPeriod starts during "Measurement Period")
  )

define "Numerator Performance Not Met: 3045F":
  /*
   * config_link_id: 3045F
   */
  not "Numerator Performance Met: 3046F"
  and not "Numerator Performance Met: 3046-8P"
  and not "Numerator Performance Not Met: 3044F"
