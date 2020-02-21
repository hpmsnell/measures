library MIPS_128_2019 version '1'

/*
 * Source: MIPS
 * ID: 128
 * Year: 2019
 * Version: 3
 *
  */

using QDM

// Able Custom Value Sets
valueset "Able; Above Normal BMI Follow-up"
valueset "Able; Below Normal BMI Follow up"
valueset "Able; Weight Management Referral"
valueset "Able; BMI Normal"
valueset "Able; BMI Above Normal"

// MIPS Value Sets
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
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Pregnancy": '2.16.840.1.113883.3.600.1622'

// HEDIS value sets
valueset "HEDIS; BMI"

parameter "Measurement Period" Interval<DateTime>
context Patient

// Components used in measure statuses

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 128 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
      and E.signingProvider.hasMeasureMembership = true

define "Exclusion Procedure":
  ["Procedure, Performed": "MIPS; Patient Not Eligible: G8422"]
  union ["Procedure, Performed": "MIPS; Patient Not Eligible: G8938"]
  union ["Procedure, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Last BMI Before Encounter":
  Last((["Assessment, Performed": "VSAC; BMI LOINC Value"
    union ["Diagnosis": "HEDIS; BMI"]) A
    with "Denominator Encounter" E
      such that A.authorDateTime on or 12 months or less before start of E.relevantPeriod
    sort by A.authorDateTime asc)

define "Last BMI Before Encounter Result":
  "Last BMI Before Encounter"
    return A.result

define "Last BMI Before Encounter Is Normal":
  (
    "Last BMI Before Encounter Result" >= 18.5
    and "Last BMI Before Encounter Result" < 25
  ) or exists ("Last BMI Before Encounter" A
    with ["Diagnosis": "Able; BMI Normal"] D
      such that D.prevelancePeriod starts during A.relevantPeriod)

define "Abnormal BMI Diagnosis":
  ["Diagnosis": "Able; BMI Above Normal"]

define "Last BMI Before Encounter Is Abnormal":
  (
    "Last BMI Before Encounter Result" >= 25
    or "Last BMI Before Encounter Result" < 18.5
  ) or exists ("Last BMI Before Encounter" A
   with "Abnormal BMI Diagnosis" D
     such that D.prevelancePeriod starts during A.relevantPeriod)

define "Above Normal BMI Follow Up":
  ["Procedure, Performed": "Able; Above Normal BMI Follow up"]
  union ["Procedure, Performed": "VSAC; Above Normal Follow-up"]
  union ["Diagnosis": "VSAC; Above Normal Follow-up"]
  union ["Procedure, Performed": "Able; Weight Management Referral"]

define "Below Normal BMI Follow Up":
  ["Procedure, Performed": "Able; Below Normal BMI Follow up"]
  union ["Procedure, Performed": "VSAC; Below Normal Follow up"]
  union ["Diagnosis": "VSAC; Below Normal Follow-up"]
  union ["Procedure, Performed": "Able; Weight Management Referral"]

define "Last BMI Before Encounter Is High With Follow-Up":
  exists("Denominator Encounter" E
    with "Last BMI Before Encounter" A
      such that A.result >= 25
    with "Above Normal BMI Follow Up" P
      such that P.relevantPeriod starts on or 12 months or less before start of E.relevantPeriod)
  or exists("Denominator Encounter" E
    with "Last BMI Before Encounter" A
    with ["Diagnosis": "Able; BMI Above Normal"] D
      such that D.prevalencePeriod during A.relevantPeriod
    with "Above Normal BMI Follow Up" P
      such that P.relevantPeriod starts on or 12 months or less before start of E.relevantPeriod)

define "Last BMI Before Encounter Is Low With Follow-Up":
  exists("Denominator Encounter" E
    with "Last BMI Before Encounter" A
      such that A.result < 18.5
    with "Below Normal BMI Follow Up" P
      such that P.relevantPeriod starts on or 12 months or less before start of E.relevantPeriod)

// Measure statuses

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: denominator_exclusion
   */
  exists("Exclusion Procedure" P
    where P.relevantPeriod starts during "Measurement Period"
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or before start of E.relevantPeriod)
  or exists(["Diagnosis": "VSAC; Pregnancy"] D
    where D.prevalencePeriod overlaps "Measurement Period"
    with "Denominator Encounter" E
      such that D.prevalencePeriod starts on or before start of E.relevantPeriod)

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
