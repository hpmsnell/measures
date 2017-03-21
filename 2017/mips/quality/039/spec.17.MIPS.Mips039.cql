library MIPS_039_2017 version '1'

/*
 * Source: MIPS
 * ID: 039
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 039 Encounter"
valueset "MIPS; Osteoporosis"
valueset "MIPS; Hospice Service"
valueset "MIPS; Performance Met: G8399"
valueset "MIPS; Performance Not Met: G8400"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// Able Value Sets

valueset "Able; Axial Dual-Energy X-Ray Absorptiometry (DXA)"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 039 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 65
      and AgeInYearsAt(start of E.relevantPeriod) < 85
      and "Patient Characteristic Sex" = "Female"
      and E.signingProvider.pqrsProvider = true

define "Denominator":
  exists("Denominator Encounter")
  and not exists(["Diagnosis": "MIPS; Osteoporosis"] D
    with "Denominator Encounter" E
      such that D.prevalencePeriod starts during E.relevantPeriod)

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; Hospice Service"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: G8399":
  /*
   * config_link_id: G8399
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8399"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Physical Exam, Performed": "Able; Axial Dual-Energy X-Ray Absorptiometry (DXA)"] P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Numerator Performance Not Met: G8400":
  /*
   * config_link_id: G8400
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: G8399"
