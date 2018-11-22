library MIPS_400_2018 version '1'

/*
 * Source: MIPS
 * ID: 400
 * Year: 2018
 * Version: 1
 * Author: Becky Weber
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 400 Encounter"
valueset "MIPS; MIPS 400 Preventive Encounter"
valueset "MIPS; Blood Transfusions Before 1992"
valueset "MIPS; Maintenance Hemodialysis"
valueset "MIPS; History of Injection Drug Use"
valueset "MIPS; Chronic Hepatitis C"
valueset "MIPS; Performance Met: G9451"
valueset "MIPS; Denominator Exception: G9452"
valueset "MIPS; Denominator Exception: G9453"
valueset "MIPS; Performance Not Met: G9454"

// VSAC value sets

valueset "VSAC; HCV Antibody Test"
valueset "VSAC; HCV RNA Test"
valueset "VSAC; HCV RIBA Test"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 400 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in ['GQ', 'GT', '95']
      and not E.placeOfService = '02'
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Denominator Preventive Encounter":
  ["Encounter, Performed": "MIPS; MIPS 400 Preventive Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in ['GQ', 'GT', '95']
      and not E.placeOfService = '02'
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
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

define "Denominaor Option Exists":
  exists(["Procedure, Performed": "MIPS; Blood Transfusions Before 1992"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; History of Injection Drug Use"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; Maintenance Hemodialysis"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Patient Characteristic Date of Birth" during [1945-01-01, 1965-12-31]

define "HCV Test":
  ["Laboratory Test, Performed": "VSAC; HCV Antibody Test"]
  union ["Laboratory Test, Performed": "VSAC; HCV RNA Test"]
  union ["Laboratory Test, Performed": "VSAC; HCV RIBA Test"]

/* POPULATIONS */

define "Denominator":
  "Denominator Encounter Exists"
  and "Denominator Option Exists"

define "Denominator Exclusion: Hepatitis C":
  /*
   * config_link_id: G9451
   */
  exists(["Diagnosis": "MIPS; Chronic Hepatitis C"] D
    where P.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met: G9451":
  /*
   * config_link_id: G9451
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9451"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  exists("HCV Test" L
    where L.resultDateTime before end of "Measurement Period")

define "Denominator Exception: G9452":
  /*
   * config_link_id: G9452
   */
  exists("Most Recent Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9452"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G9453":
  /*
   * config_link_id: G9453
   */
  exists("Most Recent Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9453"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9454":
 /*
  * config_link_id: G9454
  */
 not "Denominator Exclusion: Hepatitis C"
 and not "Numerator Performance Met: G9451"
 and not "Denominator Exception: G9452"
 and not "Denominator Exception: G9453"
