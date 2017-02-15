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

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  ["Encounter, Performed": "Able; Transition of Care"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.pqrsProvider = 1

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Encounter, Performed": "Able; Transition of Care"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.pqrsProvider = 1
    with ["Procedure, Performed": "Able; Medication Reconciliation"] P1
      such that P1.relevantPeriod starts during E.relevantPeriod
    and with ["Procedure, Performed": "Able; Medication Allergy Reconciliation"] P2
      such that P2.relevantPeriod starts during E.relevantPeriod
    and with ["Procedure, Performed": "Able; Problem List Reconciliation"] P3
      such that P3.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met"
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
