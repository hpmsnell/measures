library MIPS_001_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 001
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/frailty_lti_shared" version '1' called FrailtyLTIShared

// MIPS value sets

valueset "MIPS; MIPS 001 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Diabetes"
valueset "MIPS; Performance Met: 3046F"
valueset "MIPS; Performance Met: 3046F-8P"
valueset "MIPS; Performance Not Met: 3044F"
valueset "MIPS; Performance Not Met: 3045F"
valueset "MIPS; LTI"
valueset "MIPS; Frailty and Dementia Medication"
valueset "MIPS; Frailty and Advanced Illness"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; HbA1c Laboratory Test": '2.16.840.1.113883.3.464.1003.198.12.1013'
valueset "VSAC; Acute Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1083'
valueset "VSAC; Advanced Illness": '2.16.840.1.113883.3.464.1003.110.12.1082'
valueset "VSAC; Care Services in Long-Term Residential Facility": '2.16.840.1.113883.3.464.1003.101.12.1014'
valueset "VSAC; Dementia Medications": '2.16.840.1.113883.3.464.1003.196.12.1510'
valueset "VSAC; Diabetes": '2.16.840.1.113883.3.464.1003.103.12.1001'
valueset "VSAC; Encounter Inpatient": '2.16.840.1.113883.3.666.5.307'
valueset "VSAC; Frailty Diagnosis": '2.16.840.1.113883.3.464.1003.113.12.1074'
valueset "VSAC; Frailty Encounter": '2.16.840.1.113883.3.464.1003.101.12.1088'
valueset "VSAC; Nonacute Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1084'
valueset "VSAC; Nursing Facility Visit": '2.16.840.1.113883.3.464.1003.101.12.1012'
valueset "VSAC; Observation": '2.16.840.1.113883.3.464.1003.101.12.1086'
valueset "VSAC; Outpatient": '2.16.840.1.113883.3.464.1003.101.12.1087'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 001 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and AgeInYearsAt(start of E.relevantPeriod) < 75
      and E.signingProvider.hasMeasureMembership = true

define "Ordered HbA1c Tests":
  ["Laboratory Test, Performed": "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period"
    sort by L.resultDateTime ASC

/* Populations */

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Diagnosis": "MIPS; Diabetes"] D
    where D.prevalencePeriod overlaps "Denominator Period")

define "Denominator Exclusion: Hospice":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Denominator Exclusion: Frailty/LTI":
  /*
   * config_link_id: exclusion_frailty_lti
   */
  FrailtyLTIShared."Frailty/LTI Exclusion Exists"


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
  or Last("Ordered HbA1c Tests").result is not Decimal
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
