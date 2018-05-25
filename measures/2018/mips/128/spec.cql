library MIPS_128_2018 version '1'

/*
 * Source: MIPS
 * ID: 128
 * Year: 2018
 * Version: 1
 *
  */

using QDM

// Able Custom Value Sets

valueset "MIPS; MIPS 128 Encounter"
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

// Components used in measure statuses

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 128 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and not E.code.modifier in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true

define "Last BMI Before Encounter":
  Last(["Assessment, Performed": "VSAC; BMI LOINC Value"] A
    with "Denominator Encounter" E
      such that A.authorDateTime on or 12 months or less before start of E.relevantPeriod
    sort by A.authorDateTime asc)

define "Last BMI Before Encounter Result":
  "Last BMI Before Encounter"
    return A.result

define "Last BMI Before Encounter Is Normal":
  "Last BMI Before Encounter Result" >= 18.5
  and "Last BMI Before Encounter Result" < 25

define "Last BMI Before Encounter Is Abnormal":
  "Last BMI Before Encounter Result" >= 25
  or "Last BMI Before Encounter Result" < 18.5

define "Last BMI Before Encounter Is High With Follow-Up":
  exists("Denominator Encounter" E
    with "Last BMI Before Encounter" A
      such that A.result >= 25
        and A.authorDateTime on or 12 months or less before start of E.relevantPeriod
    with ["Procedure, Performed": "VSAC; Above Normal Follow-Up"] P
      such that P.relevantPeriod starts on or 12 months or less before start of E.relevantPeriod)

define "Last BMI Before Encounter Is Low With Follow-Up":
  exists("Denominator Encounter" E
    with "Last BMI Before Encounter" A
      such that A.result < 18.5
        and A.authorDateTime on or 12 months or less before start of E.relevantPeriod
    with ["Procedure, Performed": "VSAC; Below Normal Follow-Up"] P
      such that P.relevantPeriod starts on or 12 months or less before start of E.relevantPeriod)

// Measure statuses

define "Denominator":
  exists("Denominator Encounter")

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
  or exists(["Diagnosis": "VSAC; Pregnancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met: G8420":
  /*
   * config_link_id: G8420
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8420"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Last BMI Before Encounter Is Normal"

 define "Numerator Performance Met: G8417":
   /*
    * config_link_id: G8417
    */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8417"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Last BMI Before Encounter Is High With Follow-Up"

define "Numerator Performance Met: G8418":
  /*
   * config_link_id: G8418
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8418"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Last BMI Before Encounter Is Low With Follow-Up"

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
   or "Last BMI Before Encounter Is Abnormal"

define "Numerator Performance Not Met: G8421":
  /*
   * config_link_id: G8421
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G8420"
  and not "Numerator Performance Met: G8417"
  and not "Numerator Performance Met: G8418"
  and not "Denominator Exception: G9716"
  and not "Numerator Performance Not Met: G8419"
