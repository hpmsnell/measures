library MIPS_418_2018 version '1'

/*
 * Source: MIPS
 * ID: 418
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 418 Encounter"
valueset "MIPS; MIPS 418 Procedure"
valueset "MIPS; Fracture"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Denominator Exclusion: G9769"
valueset "MIPS; Institutional Exclusion"
valueset "MIPS; Performance Met: 3095F"
valueset "MIPS; Performance Met: G8633"
valueset "MIPS; Performance Not Met: 3095F-8P"
valueset "MIPS; Performance Not Met: G8635"

// VSAC value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// Able Value Sets

valueset "Able; Axial Dual-Energy X-Ray Absorptiometry (DXA)"
valueset "Able; Osteoporosis Medication"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter or Procedure":
  ["Encounter, Performed": "MIPS; MIPS 418 Encounter"]
  union ["Procedure, Performed": "MIPS; MIPS 418 Procedure"]

define "Denominator Encounter":
  "Denominator Encounter or Procedure" E
    where E.relevantPeriod starts during [start of "Measurement Period", 6 months before end of "Measurement Period"]
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
      and AgeInYearsAt(start of E.relevantPeriod) < 85
      and PatientCharacteristicSex = 'Female'
      and E.signingProvider.hasMeasureMembership = true
      and not E.placeOfService in {'32','33','34','54','56'}
    with ["Diagnosis": "MIPS; Fracture"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Hospice Service":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Bone Density Scan":
  ["Procedure, Performed": "MIPS; Performance Met: 3095F"]
  union ["Assessment, Performed": "Able; Axial Dual-Energy X-Ray Absorptiometry (DXA)"]

define "Osteoporosis Medication":
  ["Procedure, Performed": "MIPS; Performance Met: G8633"]
  union ["Medication": "Able; Osteoporosis Medication"]

/* Populations */

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion: Hospice Service":
  /*
   * config_link_id: exclusion_1
   */
  exists("Hospice Service" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Osteoporosis Treatment":
  /*
   * config_link_id: exclusion_2
   */
  "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exclusion: G9769"] P
      such that P.relevantPeriod starts during E.relevantPeriod
  or "Denominator Encounter" E
    with ["Assessment, Performed": "Able; Axial Dual-Energy X-Ray Absorptiometry (DXA)"] A
      such that A.authorDateTime 24 months or less before start of E.relevantPeriod
  or "Denominator Encounter" E
    with ["Medication": "Able; Osteoporosis Medication"] M
      such that M.relevantPeriod overlaps [12 months before start of E.relevantPeriod, 1 day before start of E.relevantPeriod]

define "Denominator Exclusion 3":
  /*
   * config_link_id: exclusion_3
   */
  exists(["Procedure, Performed": "MIPS; Institutional Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period"
      and AgeInyearsAt(start of P.relevantPeriod) >= 65)
  exists(["Procedure, Performed": "VSAC; Care Services in Long-Term Residential Facility"] P
    where P.relevantPeriod starts during "Measurement Period"
      and P.placeOfService in {'32', '33', '34', '54', '56'}
      and AgeInyearsAt(start of P.relevantPeriod) >= 65)

define "Numerator Performance Met: 3095F":
  /*
   * config_link_id: 3095F
   */
  "Denominator Encounter" E
    with "Bone Density Scan" P
      such that P.relevantPeriod starts at or 6 months or less after start of E.relevantPeriod

define "Numerator Performance Met: G8633":
  /*
   * config_link_id: G8633
   */
  "Denominator Encounter" E
    with "Osteoporosis Medication" P
      such that P.relevantPeriod starts at or 6 months or less after start of E.relevantPeriod

define "Numerator Performance Not Met: G8635":
  /*
   * config_link_id: G8635
   */
  "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8635"] P
      such that P.relevantPeriod starts at or 6 months or less after start of E.relevantPeriod

define "Numerator Performance Not Met: 3095F-8P":
  /*
  * config_link_id: 3095F-8P
  */
  not "Denominator Exclusion: Hospice Service"
  and not "Denominator Exclusion: Osteoporosis Treatment"
  and not "Denominator Exclusion: Institutional"
  and not "Numerator Performance Met: 3095F"
  and not "Numerator Performance Met: G8633"
  and not "Numerator Performance Not Met: G8635"
