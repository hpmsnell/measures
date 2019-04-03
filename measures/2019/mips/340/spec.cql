library MIPS_338_2018 version '1'

/*
 * Source: MIPS
 * ID: 338
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 338 Encounter"
valueset "MIPS; HIV/AIDS"
valueset "MIPS; Performance Met: G9247"
valueset "MIPS; Performance Not Met: G9246"

// VSAC value sets

valueset "VSAC; Outpatient": '2.16.840.1.113883.3.464.1003.101.12.1087'
valueset "VSAC; Expired": '2.16.840.1.113883.13.190.5.16'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 338 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true

define "Medical Visit":
  ["Encounter, Performed": "VSAC; Outpatient"]

define "Medical Visit 1":
  "Medical Visit" E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", 18 months before end of "Measurement Period"]

define "Medical Visit 2":
  "Medical Visit" E
    where E.relevantPeriod starts during [18 months before end of "Measurement Period", 12 months before end of "Measurement Period"]

define "Medical Visit 3":
  "Medical Visit" E
    where E.relevantPeriod starts during [12 months before end of "Measurement Period", 6 months before end of "Measurement Period"]

define "Medical Visit 4":
  "Medical Visit" E
    where E.relevantPeriod starts during [6 months before end of "Measurement Period", end of "Measurement Period"]

define "4 Medical Visits Exist":
  exists("Medical Visit 2" E2
    with "Medical Visit 1" E1
      such that E2.relevantPeriod starts 60 days or more after start of E2.relevantPeriod)
  and exists("Medical Visit 3" E2
    with "Medical Visit 2" E1
      such that E2.relevantPeriod starts 60 days or more after start of E2.relevantPeriod)
  and exists("Medical Visit 4" E2
    with "Medical Visit 3" E1
      such that E2.relevantPeriod starts 60 days or more after start of E2.relevantPeriod)

/* POPULATIONS */

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Diagnosis": "MIPS; HIV/AIDS"] D
    where D.prevalencePeriod starts before 21 months before the start of "Measurement Period")

define "Denominator Exclusion: G9751":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: G9751"] P
    where P.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
  or exists(["Diagnosis": "VSAC; Expired"] D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

define "Numerator Performance Met: G9247":
  /*
   * config_link_id: G9247
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9247"] P
    where P.relevantPeriod during "Measurement Period"
  or "4 Medical Visits Exist"

define "Numerator Performance Not Met: G9246":
 /*
  * config_link_id: G9246
  */
 not "Denominator Exclusion"
 and not "Numerator Performance Met: G9247"
