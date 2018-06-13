library MIPS_131_2018 version '1'

/*
 * Source: MIPS
 * ID: 131
 * Year: 2018
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 131 Encounter"
valueset "MIPS; Performance Met: G8730"
valueset "MIPS; Performance Met: G8731"
valueset "MIPS; Denominator Exception: G8442"
valueset "MIPS; Denominator Exception: G8939"
valueset "MIPS; Performance Not Met: G8732"
valueset "MIPS; Performance Not Met: G8509"
valueset "MIPS; Telehealth Modifier"

// Able Value Sets

valueset "Able; Standardized Pain Assessment Tool"
valueset "Able; Pain Assessments"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 131 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}

define "Pain Assessment":
  ["Assessment, Performed": "Able; Standardized Pain Assessment Tool"]
  union ["Assessment, Performed": "Able; Pain Assessments"]

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G8730":
  /*
   * config_link_id: G8730
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8730"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G8731":
  /*
   * config_link_id: G8731
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8731"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  exists("Pain Assessment" A
    where A.result = 0
    with "Denominator Encounter" E
      such that A.relevantPeriod starts during E.relevantPeriod)

define "Denomiantor Exception: G8442":
  /*
   * config_link_id: G8442
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8442"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denomiantor Exception: G8939":
  /*
   * config_link_id: G8939
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8939"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8509":
  /*
   * config_link_id: G8509
   */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G8509"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  exists(["Procedure, Performed": "Able; Standardized Pain Assessment Tool"] P
    where P.result = 'negative'
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8732":
  /*
   * config_link_id: G8732
   */
   not "Numerator Performance Met: G8730"
   and not "Numerator Performance Met: G8731"
   and not "Denominator Exception: G8442"
   and not "Denominator Exception: G8939"
   and not "Numerator Performance Not Met: G8509"
