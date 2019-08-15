library MIPS_275_2019 version '1'

/*
 * Source: MIPS
 * ID: 275
 * Year: 2019
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 275 Encounter"
valueset "MIPS; Inflammatory Bowel Disease"
valueset "MIPS; IPS 275 Anti-TNF Agent"
valueset "MIPS; Performance Met: G9912"
valueset "MIPS; Performance Met: G8869"
valueset "MIPS; Denominator Exception: G9504"
valueset "MIPS; Performance Not Met: G9913"
valueset "MIPS; Performance Not Met: G9915"

// VSAC value sets

valueset "VSAC; HBsAg"
valueset "VSAC; Hepatitis B Antibody"

// Able value sets

valueset "Able; Anti-TNF Agent"

parameter "Measurement Period" Interval<DateTime>

context Patient

/* Definitions */

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 275 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
    without ["Diagnosis": "MIPS; Inflammatory Bowel Disease"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Anti-TNF Agent":
  ["Procedure, Performed": "MIPS; MIPS 275 Anti-TNF Agent"] P
    where P.relevantPeriod starts during "Measurement Period"
  union ["Medication": "Able; Anti-TNF Agent"] M
    where M.relevantPeriod starts during "Measurement Period"

define "Earliest Anti-TNF Agent":
  First("Anti-TNF Agent" M
    sort by start of M.relevantPeriod asc)

define "Hepatitis B Screening":
  ["Laboratory Test, Performed": "VSAC; HBsAg"]
  union ["Procedure, Performed": "VSAC; HBsAg"]
  union ["Laboratory Test, Performed": "VSAC; Hepatitis B Antibody"]

/* Populations */

define "Denominator":
  exists("Denominator Encounter")
  and exists("Anti-TNF Agent")

define "Numerator Performance Met: G9912":
  /*
   * config_link_id: G9912
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9912"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Hepatitis B Screening" L
    with "Earliest Anti-TNF Agent" M
      such that L.resultDateTime on or before start of M.relevantPeriod)

define "Numerator Performance Met: G8869":
  /*
   * config_link_id: G8869
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8869"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: G9504":
/*
 * config_link_id: G9504
 */
exists(["Procedure, Performed": "MIPS; Denominator Exception: G9504"] P
  where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9913":
/*
* config_link_id: G8869
*/
exists(["Procedure, Performed": "MIPS; Performance Not Met: G9913"] P
where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9915":
  /*
   * config_link_id: G9915
   */
  not "Numerator Performance Met: G9912"
  and not "Numerator Performance Met: G8869"
  and not "Denominator Exception: G9504"
  and not "Numerator Performance Not Met: G9913"
