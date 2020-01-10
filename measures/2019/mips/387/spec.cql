library MIPS_387_2019 version '1'

/*
 * Source: MIPS
 * ID: 387
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 387 Encounter"
valueset "MIPS; MIPS 387 Preventive Encounter"
valueset "MIPS; Active Drug Use"
valueset "MIPS; Chronic Hepatitis C"
valueset "MIPS; Performance Met: G9383"
valueset "MIPS; Denominator Exception: G9384"
valueset "MIPS; Denominator Exception: G9385"
valueset "MIPS; Performance Not Met: G9386"

// VSAC value sets

valueset "VSAC; HCV Antibody Test"
valueset "VSAC; HCV RNA Test"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 387 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in ['GQ', 'GT', '95']
      and not E.placeOfService = '02'
      and E.signingProvider.hasMeasureMembership = true

define "Denominator Preventive Encounter":
  ["Encounter, Performed": "MIPS; MIPS 387 Preventive Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in ['GQ', 'GT', '95']
      and not E.placeOfService = '02'
      and E.signingProvider.hasMeasureMembership = true

define "Denominator Encounter or Preventive Encounter":
  "Denominator Encounter"
  union "Denominator Preventive Encounter"

define "Most Recent Denominator Encounter":
  Last("Denominator Encounter or Preventive Encounter" E
    sort by start of E.relevantPeriod asc)

define "Denominator Encounter Exists":
  exists("Denominator Preventive Encounter")
  or count("Denominator Encounter") >= 2

define "HCV Test":
  ["Laboratory Test, Performed": "VSAC; HCV Antibody Test"]
  union ["Laboratory Test, Performed": "VSAC; HCV RNA Test"]

/* POPULATIONS */

define "Denominator":
  "Denominator Encounter Exists"
  and exists(["Procedure, Performed": "MIPS; Active Injection Drug Use"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Hepatitis C":
  /*
   * config_link_id: G9383
   */
  exists(["Diagnosis": "MIPS; Chronic Hepatitis C"] D
    where P.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met: G9383":
  /*
   * config_link_id: G9383
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9383"] P
    where P.relevantPeriod starts during "Measurement Period")
  exists("HCV Test" L
    where L.resultDateTime during "Measurement Period")

define "Denominator Exception: G9384":
  /*
   * config_link_id: G9384
   */
  exists("Most Recent Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9384"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G9385":
  /*
   * config_link_id: G9385
   */
  exists("Most Recent Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9385"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9386":
 /*
  * config_link_id: G9386
  */
 not "Denominator Exclusion: Hepatitis C"
 and not "Numerator Performance Met: G9383"
 and not "Denominator Exception: G9384"
 and not "Denominator Exception: G9385"
