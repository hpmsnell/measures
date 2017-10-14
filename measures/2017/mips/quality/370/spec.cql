library MIPS_370_2017 version '1'

/*
 * Source: MIPS
 * ID: 370
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 370 Encounter"
valueset "MIPS; Major Depressive Disorder"
valueset "MIPS; PHQ-9 > 9 During Identification Period"
valueset "MIPS; Hospice Service"
valueset "MIPS; Performance Met: G9509"
valueset "MIPS; Performance Not Met: G9510"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.526.3.1024'
valueset "VSAC; Care Services in Long-Term Residential Facility": '2.16.840.1.113883.3.464.1003.101.12.1014'
valueset "VSAC; Bipolar Disorder": '2.16.840.1.113883.3.67.1.101.1.128'
valueset "VSAC; Personality Disorder": '2.16.840.1.113883.3.67.1.101.1.246'
valueset "VSAC; PHQ-9 Tool": '2.16.840.1.113883.3.67.1.101.11.723'

// Able value sets

valueset "Able; Expired"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Index Period":
  Interval[25 months before end of "Measurement Period", 13 months before end of "Measurement Period"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 370 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Major Depressive Disorder"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "PHQ-9 > 9":
  ["Assessment, Performed": "VSAC; PHQ-9 Tool"] A
    where A.authorDateTime starts during "Index Period"
      and A.result > 9

define "PHQ-9 > 9 Exists":
  exists(["Procedure, Performed": "MIPS; PHQ-9 > 9"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("PHQ-9 > 9")

define "Hospice or Nursing Home":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Encounter, Performed": "VSAC; Care Services in Long-Term Residential Facility"]

define "Excluded Disorder":
  ["Diagnosis": "VSAC; Bipolar Disorder"]
  union ["Diagnosis": "VSAC; Personality Disorder"]

define "Denominator":
  exists("Denominator Encounter")
  and "PHQ-9 > 9 Exists"

define "Denominator Exclusion: Hospice or Death":
  /*
   * config_link_id: exclusion_1
   */
  exists("Hospice or Nursing Home" I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists(["Diagnosis": "Able; Expired"] D
    where D.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Disorder":
  /*
   * config_link_id: exclusion_2
   */
  or exists(["Diagnosis": "Excluded Disorder"] D
    where D.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: G9509":
  /*
   * config_link_id: G9509
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9509"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Assessment, Performed": "VSAC; PHQ-9 Tool"] A1
    where A1.result < 5
    with "PHQ-9 > 9" A2
      such that A1.authorDateTime between 11 months and 13 months after start of A2.authorDateTime)

define "Numerator Performance Not Met: G9510":
  /*
   * config_link_id: G9510
   */
  not "Denominator Exclusion: Hospice or Death"
  and not "Denominator Exclusion: Disorder"
  and not "Performance Met: G9509"
