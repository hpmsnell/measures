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

// VSAC Value Sets

valueset "VSAC; Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001'

// Able Value Sets

valueset "Able; Performance Met: MIPS ACI PPA"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  exists(["Encounter, Performed": "VSAC; Office Visit"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.pqrsProvider = 1)

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "Able; Performance Met: MIPS ACI PPA"] P
      such that P.relevantPeriod starts during or 4 business days or less after end E.relevantPeriod)

define "Numerator Performance Not Met"
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
