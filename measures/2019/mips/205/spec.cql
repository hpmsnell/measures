library MIPS_205_2018 version '1'

/*
 * Source: MIPS
 * ID: 205
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 205 Encounter"
valueset "MIPS; HIV/AIDS"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: G9228"
valueset "MIPS; Denominator Exception: G9229"
valueset "MIPS; Performance Not Met: G9230"

// VSAC value sets

valueset "VSAC; Chlamydia Screening": '2.16.840.1.113883.3.464.1003.110.12.1052'
valueset "VSAC; Gonorrhea Tests and Chlamydia/Gonorrhea Combined Tests Value Set": '2.16.840.1.113762.1.4.1166.51'
valueset "VSAC; Syphilis (Tests for Treponema pallidum Nucleic Acid)": '2.16.840.1.113762.1.4.1146.550'
valueset "VSAC; Syphilis (Tests for Treponemal or Non Treponemal Antibody)": '2.16.840.1.113762.1.4.1146.705'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "HIV/AIDS":
  ["Diagnosis": "MIPS; HIV/AIDS"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 205 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 13
      and E.signingProvider.hasMeasureMembership = true
    with "HIV/AIDS" D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Syphilis Test":
  ["Laboratory Test, Performed": "VSAC; Syphilis (Tests for Treponema pallidum Nucleic Acid)"]
  union ["Laboratory Test, Performed": "VSAC; Syphilis (Tests for Treponemal or Non Treponemal Antibody)"]

define "Test Results Exist":
  exists(["Laboratory Test, Performed": "VSAC; Chlamydia Screening"] L
    with "HIV/AIDS" D
      such that L.resultDateTime during [start of D.prevalencePeriod, end of "Measurement Period"])
  and exists(["Laboratory Test, Performed": "VSAC; Gonorrhea Tests and Chlamydia/Gonorrhea Combined Tests Value Set"] L
    with "HIV/AIDS" D
      such that L.resultDateTime during [start of D.prevalencePeriod, end of "Measurement Period"])
  and exists("Syphilis Test" L
    with "HIV/AIDS" D
      such that L.resultDateTime during [start of D.prevalencePeriod, end of "Measurement Period"])

/* POPULATIONS */

define "Denominator":
  exists("Denominator Encounter" E1
    with "Denominator Encounter" E2
      such that E2.relevantPeriod starts 90 days or more after start of E1.relevantPeriod)

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod starts during "Denominator Period")

define "Numerator Performance Met: G9228":
  /*
   * config_link_id: G9228
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9228"] P
    with "HIV/AIDS" D
      such that P.relevantPeriod starts during [start of D.prevalencePeriod, end of "Measurement Period"])
  or "Test Results Exist"

define "Denominator Exception: G9229":
  /*
   * config_link_id: G9229
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9229"] P
    with "HIV/AIDS" D
      such that P.relevantPeriod starts during start of D.prevalencePeriod)

define "Numerator Performance Not Met: G9230":
 /*
  * config_link_id: G9230
  */
 not "Denominator Exclusion"
 and not "Numerator Performance Met: G9228"
 and not "Denominator Exception: G9229"
