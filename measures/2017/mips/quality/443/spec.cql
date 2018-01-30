library MIPS_443_2017 version '1'

/*
 * Source: MIPS
 * ID: 443
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 443 Encounter"
valueset "MIPS; Cervical Cancer, HIV, or Immunodeficiency"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: G9820"
valueset "MIPS; Performance Not Met: G9821"

// VSAC Value Sets

valueset "VSAC; Pap Test": '2.16.840.1.113883.3.464.1003.108.12.1017'
valueset "VSAC; HPV Test": '	2.16.840.1.113883.3.464.1003.110.12.1059'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 443 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 16
      and AgeInYearsAt(start of E.relevantPeriod) < 20
      and E.signingProvider.hasMeasureMembership = true

define "Cervical Cancer Screening":
  ["Laboratory Test, Performed": "VSAC; Pap Test"]
  union ["Laboratory Test, Performed": "VSAC; HPV Test"]

define "Denominator":
  exists("Denominator Encounter")
  and "Patient Characteristic Sex" in 'Female'

define "Denominator Exclusion: Hospice Service":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Denominator Exclusion: Diagnosis":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Diagnosis": "MIPS; Cervical Cancer, HIV, or Immunodeficiency"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Numerator Performance Met: G9820":
  /*
   * config_link_id: G9820
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9820"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Cervical Cancer Screening" L
    where L.resultDateTime starts during "Measurement Period")

define "Numerator Performance Not Met: G9821":
  /*
   * config_link_id: G9821
   */
  not "Denominator Exclusion: Hospice Service"
  and not "Denominator Exclusion: Diagnosis"
  and not "Numerator Performance Met: G9820"
