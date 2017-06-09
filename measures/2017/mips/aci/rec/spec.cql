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
valueset "Able; Performance Met: ACI_TRANS_MR_1"

// VSAC Value Sets

valueset "VSAC; Preventive Care Services-Initial Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "VSAC; Preventive Care- Initial Office Visit, 0 to 17": '2.16.840.1.113883.3.464.1003.101.12.1022'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator-Eligible Visit"
  ["Encounter, Performed": "Able; Transition of Care"]
  union ["Encounter, Performed": "VSAC; Preventive Care Services-Initial Office Visit, 18 and Up"]
  union ["Encounter, Performed": "VSAC; Preventive Care- Initial Office Visit, 0 to 17"]

define "Denominator Episode"
  "Denominator-Eligible Visit" E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.pqrsProvider = 1

define "Denominator":
  "Denominator Episode"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Denominator Episode" E
    with ["Procedure, Performed": "Able; Performance Met: ACI_TRANS_MR_1"] P
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Denominator Episode" E
    with ["Procedure, Performed": "Able; Medication Reconciliation"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met"
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
