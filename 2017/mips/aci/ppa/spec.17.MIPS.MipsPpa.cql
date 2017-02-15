library MIPS_PPA_2017 version '1'

/*
 * Source: MIPS
 * ID: PPA
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// Able Value Sets

valueset "Able; ACI Encounter"
valueset "Able; Patient Portal Notification"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  exists(["Encounter, Performed": "Able; ACI Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.pqrsProvider = 1)

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Encounter, Performed": "Able; ACI Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
    with  ["Procedure, Performed": "Able; Patient Portal Notification"] P
      such that P.relevantPeriod starts during or 36 hours or less after end E.relevantPeriod)

define "Numerator Performance Not Met"
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
