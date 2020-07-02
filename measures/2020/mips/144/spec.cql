library MIPS_144_2020 version '1'

/*
 * Source: MIPS
 * ID: 144
 * Year: 2020
 * Version: 1
 * Written By: Patrick Clark
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 144 Encounter"
valueset "MIPS; Chemotherapy"
valueset "MIPS; Cancer"
valueset "MIPS; Performance Met: 0521F"
valueset "MIPS; Performance Not Met: 0521F-8P"
valueset "MIPS; Performance Met: 1125F"

// VSAC value sets

valueset "VSAC; Standardized Pain Assessment Tool": '2.16.840.1.113883.3.526.3.1028'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Pain Present":
  ["Procedure, Performed": "MIPS; Performance Met: 1125F"]
    where not P.code.modifier = 8P
  union  ["Procedure, Performed": "VSAC; Standardized Pain Assessment Tool"] PainAssessment
    where PainAssessment.result > 0

define "Denominator Chemotherapy":
  ["Encounter, Performed": "MIPS; MIPS 144 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Procedure, Performed": "MIPS; Chemotherapy"] P
      such that P.relevantPeriod starts during "Measurement Period"

define "Denominator Radiation Therapy":
  ["Procedure, Performed": "MIPS; MIPS 144 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator Chemotherapy or Radiation Therapy":
  "Denominator Chemotherapy"
  union "Denominator Radiation Therapy"

define "Denominator Encounter":
  "Denominator Chemotherapy or Radiation Therapy" E
    with ["Diagnosis": "MIPS; Cancer"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    with "Pain Present" PainPresent
      such that PainPresent.relevantPeriod starts same day as start of E.relevantPeriod

/* Populations */

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: 0521F":
  /*
   * config_link_id: 0521F
   */
  "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: 0521F"] P
      where not P.code.modifier = 8P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 0521F-8P":
  /*
   * config_link_id: 0521F-8P
   */
  not "Numerator Performance Met: 0521F"
