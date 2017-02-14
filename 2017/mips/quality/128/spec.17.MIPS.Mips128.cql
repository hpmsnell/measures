library MIPS_128_2017 version '1'

/*
 * Source: MIPS
 * ID: 128
 * Year: 2017
 * Version: 1
 * Clinical Lead: Calvin Newman
 * Engineer: TBD
 * Q/A Reviewer: TBD
 *
 * Status = Prototype
 * Clinical Validation:
 *
  */

using QDM

// Able Custom Value Sets

valueset "MIPS; MIPS 128 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Patient Not Eligible: G8422"
valueset "MIPS; Patient Not Eligible: G8938"
valueset "MIPS; Performance Met: G8420"
valueset "MIPS; Performance Met: G8417"
valueset "MIPS; Performance Met: G8418"
valueset "MIPS; Denominator Exception: G9716"
valueset "MIPS; Performance Not Met: G8421"
valueset "MIPS; Performance Not Met: G8419"

// VSAC Value Sets
valueset "VSAC; BMI LOINC Value"
valueset "VSAC; Above Normal Follow-up"
valueset "VSAC; Below Normal Follow up"

// VSAC Value Sets
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Pregnancy": '2.16.840.1.113883.3.600.1622'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  AgeInYearsAt(
    ["Encounter, Performed": "MIPS; MIPS 128 Encounter"] E
      where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier = "MIPS; Telehealth Modifier"
      and E.signingProvider.pqrsProvider = true
  )

define "Denominator":
  "Patient Age at Encounter" >= 18

define "Denominator Exclusion":
  /*
   * config_link_id: denominator_exclusion
   */
  exists(["Procedure, Performed": "MIPS; Patient Not Eligible: G8422"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; Patient Not Eligible: G8938"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod starts during "Measurement Period")
  or or exists(["Diagnosis": "VSAC; Pregnancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met: G8420":
  /*
   * config_link_id: G8420
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8420"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Assessment, Performed": "VSAC; BMI LOINC Value"] A
    where A.authorDateTime starts during "Measurement Period")
    and A.result >= 18.5
    and A.result < 25

 define "Numerator Performance Met: G8417":
   /*
    * config_link_id: G8417
    */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8417"] P
    where P.relevantPeriod starts during "Measurement Period")
  or (
    exists(["Assessment, Performed": "VSAC; BMI LOINC Value"] A
      where A.authorDateTime starts during "Measurement Period")
      and A.result >= 25
      with ["Intervention, Performed": "VSAC; Above Normal Follow-up"] I
        such that I.relevantPeriod starts 6 months or less before A.authorDateTime
  )

define "Numerator Performance Met: G8418":
  /*
   * config_link_id: G8418
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8418"] P
    where P.relevantPeriod starts during "Measurement Period")
  or (
    exists(["Assessment, Performed": "VSAC; BMI LOINC Value"] A
      where A.authorDateTime starts during "Measurement Period")
      and A.result < 18.5
      with ["Intervention, Performed": "VSAC; Below Normal Follow up"] I
        such that I.relevantPeriod starts 6 months or less before A.authorDateTime

define "Denominator Exception: G9716":
  /*
   * config_link_id: G9716
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9716"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G8419":
  /*
   * config_link_id: G8419
   */
   exists(["Procedure, Performed": "MIPS; Performance Not Met: G8419"] P
     where P.relevantPeriod starts during "Measurement Period")
   or (
     exists(["Assessment, Performed": "VSAC; BMI LOINC Value"] A
       where A.authorDateTime starts during "Measurement Period")
       and (
         A.result < 18.5
         or A.result >= 25
       )

define "Numerator Performance Not Met: G8421":
  /*
   * config_link_id: G8421
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G8420"
  and not "Numerator Performance Met: G8417"
  and not "Numerator Performance Met: G8418"
  and not "Denominator Exception: G9716"
  and not "Numerator Performance Not Met: G8421"
  and not "Numerator Performance Not Met: G8419"
