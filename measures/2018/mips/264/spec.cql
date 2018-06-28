library MIPS_264_2018 version '1'

/*
 * Source: MIPS
 * ID: 264
 * Year: 2018
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 264 Encounter"
valueset "MIPS; MIPS 264 Breast Cancer"
valueset "MIPS; Clinically Node Negative Invasive Breast Cancer"
valueset "MIPS; Performance Met: G8878"
valueset "MIPS; Denominator Exception: G8880"
valueset "MIPS; Performance Not Met: G8882"

// Able value sets

valueset "Able; Sentinel Lymph Node Biopsy"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 264 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; MIPS 264 Breast Cancer"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    with ["Procedure, Performed": "MIPS; Clinically Node Negative Invasive Breast Cancer"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G8878":
  /*
   * config_link_id: G8878
   */
  "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8878"] P
      such that P.relevantPeriod starts during E.relevantPeriod
   or "Denominator Encounter" E
     with ["Procedure, Performed": "Able; Sentinel Lymph Node Biopsy"] P
       such that P.relevantPeriod starts during E.relevantPeriod

 define "Denominator Exception: G8880":
   /*
    * config_link_id: G8880
    */
   "Denominator Encounter" E
     with ["Procedure, Performed": "MIPS; Denominator Exception: G8880"] P
       such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G8882":
  /*
   * config_link_id: G8882
   */
  not "Numerator Performance Met: G8878"
  and not "Denominator Exception: G8880"
