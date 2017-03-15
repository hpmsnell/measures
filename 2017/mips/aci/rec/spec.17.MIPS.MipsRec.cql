library MIPS_REC_2017 version '1'

/*
 * Source: MIPS
 * ID: REC
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// Able Value Sets

valueset "Able; Transition of Care"
valueset "Able; Medication Reconciliation"
valueset "Able; Medication Allergy Reconciliation"
valueset "Able; Problem List Reconciliation"
valueset "Able; Performance Met: MIPS ACI REC"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Episode"
  ["Encounter, Performed": "Able; Transition of Care"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.pqrsProvider = 1

define "Denominator":
  "Denominator Episode"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Denominator Episode" E
    with ["Procedure, Performed": "Able; Performance Met: MIPS ACI REC"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met"
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
