library MIPS_VDT_2017 version '1'

/*
 * Source: MIPS
 * ID: VDT
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// Able Value Sets

valueset "Able; ACI Encounter"
valueset "Able; Patient Education"
valueset "Able; Performance Met: MIPS ACI PSE"

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
  exists(["Procedure, Performed": "Able; Performance Met: MIPS ACI PSE"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "Able; Patient Education"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met"
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
