library MIPS_PSE_2017 version '1'

/*
 * Source: MIPS
 * ID: PSE
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

valueset "Able; Patient Education"
valueset "Able; Performance Met: MIPS ACI PSE"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  exists(["Encounter, Performed": "VSAC; Office Visit"] E
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
