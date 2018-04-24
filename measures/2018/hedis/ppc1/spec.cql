library HEDIS_PPC1_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: PPC1
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Deliveries": '2.16.840.1.113883.3.464.1004.1072'
valueset "HEDIS; Non-Live Births": '2.16.840.1.113883.3.464.1004.1187'
valueset "HEDIS; Prenatal Bundled Services": '2.16.840.1.113883.3.464.1004.1223'
valueset "HEDIS; Stand Alone Prenatal Visits": '2.16.840.1.113883.3.464.1004.1240'
valueset "HEDIS; Prenatal Visits": '2.16.840.1.113883.3.464.1004.1225'
valueset "HEDIS; Obstetric Panel": '2.16.840.1.113883.3.464.1004.1192'
valueset "HEDIS; Prenatal Ultrasound": '2.16.840.1.113883.3.464.1004.1224'
valueset "HEDIS; Toxoplasma Antibody": '2.16.840.1.113883.3.464.1004.1253'
valueset "HEDIS; Rubella Antibody": '2.16.840.1.113883.3.464.1004.1233'
valueset "HEDIS; Cytomegalovirus Antibody": '2.16.840.1.113883.3.464.1004.1069'
valueset "HEDIS; Herpes Simplex Antibody": '2.16.840.1.113883.3.464.1004.1119'
valueset "HEDIS; ABO": '2.16.840.1.113883.3.464.1004.1001'
valueset "HEDIS; Rh": '2.16.840.1.113883.3.464.1004.1228'
valueset "HEDIS; ABO and Rh": '2.16.840.1.113883.3.464.1004.1002'
valueset "HEDIS; Pregnancy Diagnosis": '2.16.840.1.113883.3.464.1004.1220'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Delivery":
  ["Procedure, Performed": "HEDIS; Deliveries"] P1
    where P1.relevantPeriod starts during [56 days before start of "Measurement Period", 57 days before end of "Measurement Period"]

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Delivery with Prenatal Visit":
  "Delivery" P
    with ["Encounter, Performed": "HEDIS; Prenatal Visits"] E
      such that E.relevantPeriod starts during [9 months before start of P.relevantPeriod, 6 months before start of P.relevantPeriod]

define "Complete Prenatal Service":
  ["Procedure, Performed": "HEDIS; Prenatal Bundled Services"]
  union ["Encounter, Performed": "HEDIS; Prenatal Visits"]

define "Prenatal Assessment":
  ["Assessment, Performed": "HEDIS; Obstetric Panel"]
  union ["Assessment, Performed": "HEDIS; Prenatal Ultrasound"]

define "Toxoplasma Antibody Test":
  ["Assessment, Performed": "HEDIS; Toxoplasma Antibody"]
  union ["Laboratory Test, Performed": "HEDIS; Toxoplasma Antibody"]

define "Rubella Antibody Test":
  ["Assessment, Performed": "HEDIS; Rubella Antibody"]
  union ["Laboratory Test, Performed": "HEDIS; Rubella Antibody"]

define "Cytomegalovirus Antibody Test":
  ["Assessment, Performed": "HEDIS; Cytomegalovirus Antibody"]
  union ["Laboratory Test, Performed": "HEDIS; Cytomegalovirus Antibody"]

define "Herpes Simplex Antibody Test":
  ["Assessment, Performed": "HEDIS; Herpes Simplex Antibody"]
  union ["Laboratory Test, Performed": "HEDIS; Herpes Simplex Antibody"]

define "ABO or Rh Test":
  ["Assessment, Performed": "HEDIS; ABO"]
  union ["Laboratory Test, Performed": "HEDIS; ABO"]
  union ["Assessment, Performed": "HEDIS; Rh"]
  union ["Laboratory Test, Performed": "HEDIS; Rh"]
  union ["Laboratory Test, Performed": "HEDIS; ABO and Rh"]

// Populations

define "Denominator":
  "Delivery" P1
    where "Patient Characteristic Sex" = 'Female'
    without ["Diagnosis": "HEDIS; Non-Live Births"] D
      such that D.prevalencePeriod starts during P1.relevantPeriod
    without "Delivery" P2
      such that P1.relevantPeriod starts during [6 months before start of P2.relevantPeriod, 6 months after start of P2.relevantPeriod]
    without "Hospice" I
      such that I.authorDateTime during [56 days before start of "Measurement Period", 57 days before end of "Measurement Period"]

define "Numerator Performance Met: Single Service":
  /*
   * config_link_id: single
   */
  "Delivery" P
    with "Complete Prenatal Service" E
      such that E.relevantPeriod starts during [9 months before start of P.relevantPeriod, 6 months before start of P.relevantPeriod]

define "Numerator Performance Met: Multiple Services":
  /*
   * config_link_id: multiple
   */
  "Delivery with Prenatal Visit" P
    with ["Diagnosis"; "HEDIS; Pregnancy Diagnosis"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
  or "Delivery with Prenatal Visit" P
    with "Prenatal Assessment" A
      such that A.authorDateTime during [9 months before start of P.relevantPeriod, 6 months before start of P.relevantPeriod]
  or "Delivery with Prenatal Visit" P
    with "Toxoplasma Antibody Test" A1
      such that A1.authorDateTime during [9 months before start of P.relevantPeriod, 6 months before start of P.relevantPeriod]
    with "Rubella Antibody Test" A2
      such that A2.authorDateTime during [9 months before start of P.relevantPeriod, 6 months before start of P.relevantPeriod]
    with "Cytomegalovirus Antibody Test" A3
      such that A3.authorDateTime during [9 months before start of P.relevantPeriod, 6 months before start of P.relevantPeriod]
    with "Herpes Simplex Antibody Test" A4
      such that A4.authorDateTime during [9 months before start of P.relevantPeriod, 6 months before start of P.relevantPeriod]
  or "Delivery with Prenatal Visit" P
    with "ABO or Rh Test" A1
      such that A1.authorDateTime during [9 months before start of P.relevantPeriod, 6 months before start of P.relevantPeriod]
    with "Rubella Antibody Test" A2
      such that A2.authorDateTime during [9 months before start of P.relevantPeriod, 6 months before start of P.relevantPeriod]

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
