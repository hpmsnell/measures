library MIPS_397_2017 version '1'

/*
 * Source: MIPS
 * ID: 397
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 397 Encounter"
valueset "MIPS; Other Specimen Site"
valueset "MIPS; Malignant Cutaneous Melanoma"
valueset "MIPS; Performance Met: G9428"
valueset "MIPS; Denominator Exception: G9429"
valueset "MIPS; Performance Not Met: G9431"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 397 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Malignant Cutaneous Melanoma"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Other Specimen Site"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Met: G9428":
  /*
   * config_link_id: G9428
   */
  "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9428"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: G9429":
  /*
   * config_link_id: G9429
   */
   "Denominator Encounter" E
     with ["Procedure, Performed": "MIPS; Denominator Exception: G9429"] P
       such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G9431":
  /*
   * config_link_id: G8428
   */
  not "Numerator Performance Met: G9428"
  and not "Denominator Exception: G9429"
